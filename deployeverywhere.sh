#!/bin/bash

# Function to run commands in parallel
run_parallel() {
    "$@" &
}

# Push changes to GitHub
git add .
git commit -m "Update application for web, macOS, iOS, and Android"
git push origin main

# Ensure Minikube is running
minikube status || minikube start

# Build Flutter apps in parallel
echo "Building Flutter apps..."
run_parallel flutter build web
run_parallel flutter build macos --debug
run_parallel flutter build ios --simulator
run_parallel flutter build apk -d emulator-5554 --debug

# Build and load Docker image for web
echo "Building Docker image for web..."
eval $(minikube docker-env)
docker build -t flutter-hello-world:v1 .

# Deploy web app to local Kubernetes
echo "Deploying web app to local Kubernetes..."
kubectl apply -f flutter-app-deployment.yaml
kubectl set image deployment/flutter-hello-world flutter-hello-world=flutter-hello-world:v1

# Wait for deployment to be ready in the background
kubectl rollout status deployment/flutter-hello-world &

# Open platforms in parallel
echo "Opening applications..."
run_parallel minikube service flutter-hello-world-service
run_parallel open build/macos/Build/Products/Release/hello_world_app.app

# For iOS: Start simulator and install app
run_parallel flutter emulators --launch apple_ios_simulator
run_parallel flutter install -d A8E21C36-386D-4696-9342-B0D548DBD9E7

# For Android: Start emulator and install app
run_parallel flutter emulators --launch Medium_Phone_API_35
run_parallel flutter install -d emulator-5554

# Wait for all background processes to complete
wait

echo "iOS app installed on simulator. To run on a physical device, open the Xcode project in build/ios/Runner.xcworkspace and run from there."
echo "Android app installed on emulator. To install on a physical device, use: adb install build/app/outputs/flutter-apk/app-release.apk"

echo "Deployment complete!"