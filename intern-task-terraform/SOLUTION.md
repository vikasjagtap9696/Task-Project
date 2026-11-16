# DevOps challenge solution

## Task 1

The app image uses `python:3.12-slim`, listens on port 8080, and runs as
UID 10001. Kubernetes uses `intern-task-app:local` with
`imagePullPolicy: Never`, HTTP readiness/liveness checks on `/healthz`, and a
ClusterIP Service on port 80 targeting the container's named port 8080.

## Task 2

The Terraform module describes a VPC, public subnet, Internet Gateway,
default route, route-table association, restricted security group, and an EC2
instance with a public address. SSH requires the caller to provide
`ssh_cidr`; validation rejects any `/0` network. The application port defaults
to 8080 and is the only public application ingress.

User data embeds the real `intern-task-app/app/app.py` and Task 1 Dockerfile
as base64, installs Docker, builds the image, and runs it through an enabled
systemd unit. It also creates `appuser` with passwordless sudo. UFW denies
unexpected host input, allows SSH only from `ssh_cidr`, and allows port 8080.
Because Docker-published ports traverse forwarding rather than UFW's INPUT
chain, the `DOCKER-USER` chain permits established traffic and port 8080, then
drops other forwarded traffic before Docker's accept rules.

`user_data_replace_on_change = false` prevents an unrelated plan change from
replacing a running instance solely because its bootstrap text changed. This
avoids destructive replacement, but also means changed bootstrap content is
not retroactively executed; a deliberate image or instance replacement is
needed when bootstrap changes must be applied.

## Verification

Run Terraform from `intern-task-terraform/terraform` with fake credentials.
Terraform automatically loads the supplied `terraform.tfvars`; replace its
documentation-only `ssh_cidr` value with your own public IP/CIDR before using
AWS:

```powershell
$env:AWS_ACCESS_KEY_ID = "fake"
$env:AWS_SECRET_ACCESS_KEY = "fake"
$env:AWS_DEFAULT_REGION = "us-east-1"
terraform fmt -check
terraform init
terraform validate
terraform plan
```

The plan uses a literal AMI variable and repository files, so it does not
need an AMI data lookup. No AWS apply is required or permitted.

## Draft PR description

Implemented both challenge tasks. The container runs the supplied Python app
as a non-root user on port 8080; Kubernetes uses a local-only image policy,
resource bounds, and HTTP readiness/liveness probes. The Terraform module
creates a reachable public VPC layout and an EC2 instance with least-privilege
SSH/application ingress, embeds the actual app and Dockerfile, and manages the
container with systemd. Host and Docker forwarding firewall paths are both
covered. `user_data_replace_on_change = false` avoids replacement caused only
by bootstrap changes.

The Terraform CI workflow was corrected to run formatting and validation from
`intern-task-terraform/terraform`, and validation now follows initialization
with an explicit job dependency. Verification evidence and any unavailable
Docker, Kubernetes, or AWS checks are listed separately rather than inferred
from static files.
