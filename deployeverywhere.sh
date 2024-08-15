#!/bin/bash

# Ensure Minikube is running
minikube status || minikube start

# Build Flutter web app
flutter build web

# Build and load Docker image
eval $(minikube docker-env)
docker build -t flutter-hello-world:v1 .

# Deploy to local Kubernetes
kubectl apply -f flutter-app-deployment.yaml
kubectl set image deployment/flutter-hello-world flutter-hello-world=flutter-hello-world:v1

# Wait for deployment to be ready
kubectl rollout status deployment/flutter-hello-world

# Open the service in the default browser
minikube service flutter-hello-world-service

# Push changes to GitHub
git add .
git commit -m "Update application"
git push origin main