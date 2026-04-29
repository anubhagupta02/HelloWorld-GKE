#!/bin/bash

# Deploy script for HelloWorld Spring Boot application to Google Cloud GKE
# This script automates the entire deployment process

set -e  # Exit on error

# Configuration
PROJECT_ID="gen-lang-client-0016379173"
CLUSTER_NAME="helloworld-cluster"
CLUSTER_ZONE="us-central1-a"
IMAGE_NAME="helloworld"
REGISTRY="gcr.io"
DEPLOYMENT_NAME="helloworld-deployment"

# Step 1: Build the JAR
./gradlew bootJar > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Error: Failed to build JAR"
    exit 1
fi

# Step 2: Build the Docker image for x86-64 (linux/amd64)
docker build --platform linux/amd64 -t ${REGISTRY}/${PROJECT_ID}/${IMAGE_NAME}:latest . > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Error: Failed to build Docker image"
    exit 1
fi

# Step 3: Authenticate with Google Cloud
gcloud auth configure-docker > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Error: Failed to authenticate with Google Cloud"
    exit 1
fi

# Step 4: Push the image to GCR
docker push ${REGISTRY}/${PROJECT_ID}/${IMAGE_NAME}:latest > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Error: Failed to push image to GCR"
    exit 1
fi

# Step 5: Get GKE cluster credentials
gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${CLUSTER_ZONE} --project=${PROJECT_ID} > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Error: Failed to get cluster credentials"
    exit 1
fi

# Step 6: Apply deployment
kubectl apply -f deployment.yaml > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Error: Failed to apply deployment"
    exit 1
fi

# Step 7: Rollout restart (force pods to pull new image)
kubectl rollout restart deployment/${DEPLOYMENT_NAME} > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Error: Failed to restart deployment"
    exit 1
fi

# Step 8: Wait for rollout to complete
kubectl rollout status deployment/${DEPLOYMENT_NAME} --timeout=5m > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Error: Rollout failed or timed out"
    exit 1
fi

# Step 9: Get service info and display
SERVICE_IP=$(kubectl get service helloworld-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
if [ -z "$SERVICE_IP" ]; then
    SERVICE_IP="<pending>"
fi

echo "Deployment Completed Successfully!"
echo ""
echo "Project ID:      ${PROJECT_ID}"
echo "Cluster:         ${CLUSTER_NAME}"
echo "Image:           ${REGISTRY}/${PROJECT_ID}/${IMAGE_NAME}:latest"
echo "Service URL:     http://${SERVICE_IP}/test"

