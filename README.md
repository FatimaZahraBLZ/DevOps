# Kubernetes Deployment: Rolling Updates & Blue-Green Strategy

## DevOps uni Project

This project demonstrates a Kubernetes deployment using:
- Rolling Updates
- Blue-Green Deployment
- Docker + Minikube + GitHub Actions CI/CD

---

## Tech Stack

- Windows 10 Pro
- Docker Desktop
- Minikube (Kubernetes)
- GitHub Actions (CI/CD)
- Docker Hub (Image registry)

---

## Docker Images

Images are pushed to Docker Hub under:

docker.io/20031114/myapp:v1
docker.io/20031114/myapp:v2


---

## Setup Instructions

1. **Start Minikube**
   ```bash
   minikube start

2. **Deploy app (v1)**

   ```bash
   kubectl apply -f deployment.yaml
   Access the app
   minikube service myapp-service

3. **Rolling Update**
    ```To update to v2
    image: 20031114/myapp:v2

    ```Apply again:
    kubectl apply -f deployment.yaml
    kubectl rollout status deployment myapp

    ```Rollback:
    kubectl rollout undo deployment myapp

4. **Blue-Green Deployment**
 
    ```Deploy myapp-green using:
    kubectl apply -f myapp-green.yaml

