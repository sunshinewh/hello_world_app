#!/bin/bash

# Start SSH agent and add key
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa  # You'll be prompted for the passphrase here

# Ensure Minikube is running
minikube status || minikube start

# Build Flutter web app
echo "Building Flutter web app..."
flutter build web

# Build Flutter macOS app
echo "Building Flutter macOS app..."
flutter build macos --release --arch arm64

# Build Flutter iOS app
echo "Building Flutter iOS app..."
flutter build ios --release --no-codesign

# Build and load Docker image for web
echo "Building Docker image for web..."
eval $(minikube docker-env)
docker build -t flutter-hello-world:v1 .

# Deploy web app to local Kubernetes
echo "Deploying web app to local Kubernetes..."
kubectl apply -f flutter-app-deployment.yaml
kubectl set image deployment/flutter-hello-world flutter-hello-world=flutter-hello-world:v1

# Wait for deployment to be ready
kubectl rollout status deployment/flutter-hello-world

# Open the web service in the default browser
minikube service flutter-hello-world-service

# For macOS: Open the built app
echo "Opening macOS app..."
open build/macos/Build/Products/Release/hello_world_app.app

# For iOS: Instructions to run on simulator or device
echo "iOS app built. To run on simulator, use: flutter run -d <simulator_id>"
echo "To get a list of available simulators, use: flutter devices"
echo "To deploy to a physical device, open the Xcode project in build/ios/Runner.xcworkspace and run from there."

# Push changes to GitHub
git add .
git commit -m "Update application for web, macOS, and iOS"
git push origin main

# Kill the SSH agent when done
ssh-agent -k

echo "Deployment complete!"