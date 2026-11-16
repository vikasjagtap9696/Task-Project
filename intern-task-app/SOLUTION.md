# Task 1 solution

The image uses the dependency-free Python app on `python:3.12-slim`. It sets
`PORT=8080`, runs as UID 10001, and is exposed as `intern-task-app:local`.
The Deployment uses `imagePullPolicy: Never` because the intended workflow
builds the image locally and loads it into kind; it never attempts a registry
pull. Readiness and liveness both call `/healthz`, while the Service exposes
port 80 and targets the named container port 8080.

## Local verification

From `intern-task-app/`:

```powershell
docker build -t intern-task-app:local .
docker run --rm -d --name intern-task-app-check -p 8080:8080 intern-task-app:local
curl.exe -fsS http://localhost:8080/healthz
curl.exe -fsS http://localhost:8080/
docker rm -f intern-task-app-check
```

For kind, use a dedicated cluster and load the local image before applying
`k8s/`:

```powershell
kind create cluster --name intern-task
kind load docker-image intern-task-app:local --name intern-task
kubectl apply -f k8s/
kubectl rollout status deployment/intern-task-app --timeout=60s
kubectl port-forward svc/intern-task-app 8080:80
```

Then request `/healthz` and `/`. Delete only the dedicated cluster when done:
`kind delete cluster --name intern-task`.
