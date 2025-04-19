#!/bin/bash

# USAGE:
# ./update-locally.sh <image_sha>

SHA=$1

if [ -z "$SHA" ]; then
  echo " You must provide the image SHA (from GitHub Docker build)"
  echo "Example: ./update-locally.sh 3d61d2e63da2f341c7e5ab68066ff67e491dbab3"
  exit 1
fi

IMAGE_TAG="20031114/myapp:$SHA"

echo " Pulling latest image: $IMAGE_TAG ..."
docker pull $IMAGE_TAG

echo " Updating Kubernetes deployment..."
kubectl set image deployment/myapp myapp=$IMAGE_TAG

echo " Waiting for rollout to complete..."
kubectl rollout status deployment/myapp

echo " Port-forwarding to localhost:8084 ..."
kubectl port-forward service/myapp-service 8084:80
