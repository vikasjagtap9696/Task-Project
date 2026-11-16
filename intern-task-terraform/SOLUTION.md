# DevOps challenge solution

## Task 1

The app image uses `python:3.12-slim`, listens on port 8080, and runs as
UID 10001. Kubernetes uses `intern-task-app:local` with
`imagePullPolicy: Never`, HTTP readiness/liveness checks on `/healthz`, and a
ClusterIP Service on port 80 targeting the container's named port 8080.
The previously verified Minikube run was on an Amazon Linux EC2 host:
`GET /healthz` returned `ok` and `GET /` returned `hello from intern-task`.

## Task 2 architecture and design

The Terraform module describes a VPC, public subnet, Internet Gateway,
default route, route-table association, restricted security group, and an EC2
instance with a public address. The public route-table association is an
explicit dependency of the instance so bootstrap downloads do not race route
creation. SSH requires the caller to provide `ssh_cidr`; validation requires a
valid, non-world-open IPv4 CIDR. The application port is fixed at 8080 to
match the actual app and cannot be overridden independently.

User data embeds the real `intern-task-app/app/app.py` and Task 1 Dockerfile
as base64, installs Docker, builds the image, and runs it through an enabled
systemd unit. It also creates `appuser` with passwordless sudo. UFW denies
unexpected host input and allows only port 8080. SSH remains restricted in the
AWS security group, but the host firewall blocks new SSH connections. Because
Docker-published ports traverse forwarding rather than UFW's INPUT chain, the
`DOCKER-USER` chain permits established traffic, container-originated outbound
traffic, and only port 8080 inbound traffic, then drops other forwarded traffic.
The firewall rules are installed by a systemd unit ordered after Docker and
saved through `iptables-persistent` for reboot restoration.

The AWS provider is pinned to the tested `6.73.0` release and uses the
assignment-required fake-credential validation settings. The bootstrap uses
Ubuntu `apt` commands: Amazon Linux is only the current development host.
Deployment needs a valid Ubuntu AMI in the selected region; the example AMI is
plausible but has not been verified.

`user_data_replace_on_change = false` tells the pinned provider not to replace
the instance merely because the rendered user data changes. It does not cause
new user data to execute on an existing instance. Two fresh plans cannot prove
the state-based non-replacement behavior, and no state-based test was
performed.

## Verification status

Task 2 previously passed `terraform init`, `terraform validate`, and
`terraform plan`, with the tested AWS provider version `6.73.0`. The plan
showed `7 to add, 0 to change, 0 to destroy`. Those were configuration-only
checks; AWS deployment, reboot behavior, firewall persistence, and
state-based non-replacement were not tested.

Run these non-deploying checks from `intern-task-terraform/terraform`.
`terraform.tfvars.example` is documentation-only and uses a reserved
non-world-open CIDR:

```bash
export AWS_ACCESS_KEY_ID=fake
export AWS_SECRET_ACCESS_KEY=fake
export AWS_SESSION_TOKEN=
export AWS_EC2_METADATA_DISABLED=true
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform plan -input=false -var-file=terraform.tfvars.example
```

The plan uses a literal AMI variable and repository files, so it does not need
an AMI data lookup. Do not run `terraform apply` or `terraform destroy`.
Docker, Minikube, AWS deployment, reboot, firewall persistence, and state-based
lifecycle behavior remain unperformed here unless explicitly tested later.

## CI notes

The workflow fixes are structural: path filters include both task folders,
formatting runs from `intern-task-terraform/terraform`, and validation has an
initialization step and an explicit dependency on formatting. No GitHub
Actions run has been observed here, so CI must not be described as passed.

## Draft PR description

Implemented both challenge tasks. Task 1 preserves the verified local-image
Kubernetes deployment and app checks. Task 2 defines a reachable public VPC,
least-privilege AWS ingress, the real app bootstrap, systemd lifecycle, and
host/Docker forwarding firewall rules. The provider is pinned to `6.73.0`;
`user_data_replace_on_change = false` is documented without claiming that
updated bootstrap executes in place. Terraform checks and historical results
are separated from unperformed AWS runtime tests. CI workflow fixes are
described separately from Terraform implementation changes.
