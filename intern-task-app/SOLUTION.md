# Task 1 solution

The image uses the dependency-free Python app on `python:3.12-slim`. It sets
`PORT=8080`, runs as UID 10001, and is exposed as `intern-task-app:local`.
The Deployment uses `imagePullPolicy: Never` because the intended workflow
builds the image locally and loads it into Minikube; it never attempts a
registry pull. Readiness and liveness both call `/healthz`, while the Service
exposes port 80 and targets the named container port 8080.

## Previously verified result

Task 1 ran successfully on Minikube hosted on an Amazon Linux EC2:

- `GET /healthz` returned `ok`.
- `GET /` returned `hello from intern-task`.

Amazon Linux is the current Terraform/Minikube development host only. The
Terraform bootstrap remains Ubuntu-based and needs a valid Ubuntu AMI in the
selected AWS region. The example AMI is not claimed to be verified.

## Linux verification commands

From `intern-task-app/`, after Docker and Minikube are available:

```bash
docker build -t intern-task-app:local .
docker run --rm -d --name intern-task-app-check -p 8080:8080 \
  -e PORT=8080 intern-task-app:local
curl -fsS http://localhost:8080/healthz
curl -fsS http://localhost:8080/
docker rm -f intern-task-app-check

minikube image load intern-task-app:local
kubectl apply -f k8s/
kubectl rollout status deployment/intern-task-app --timeout=60s
kubectl port-forward svc/intern-task-app 8080:80 &
curl -fsS http://localhost:8080/healthz
curl -fsS http://localhost:8080/
```

`imagePullPolicy: Never` intentionally requires loading the image into the
cluster; no registry dependency is introduced.
