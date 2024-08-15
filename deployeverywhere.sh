#!/bin/bash

# Function to run commands in parallel
run_parallel() {
    "$@" &
}

# Function to check if an emulator is running
is_emulator_running() {
    flutter devices | grep -q "$1"
}

# Function to launch an emulator and wait for it to be ready
launch_emulator() {
    local emulator_name="$1"
    local timeout=300  # 5 minutes timeout
    
    echo "Launching $emulator_name..."
    flutter emulators --launch "$emulator_name" &
    
    local start_time=$(date +%s)
    while ! is_emulator_running "$emulator_name"; do
        sleep 5
        if [ $(($(date +%s) - start_time)) -gt $timeout ]; then
            echo "Timeout waiting for $emulator_name to start"
            return 1
        fi
    done
    echo "$emulator_name is ready"
}

# Push changes to GitHub
git add .
git commit -m "Update application for web, macOS (arm64), iOS, and Android"
git push origin main

# Ensure Minikube is running
minikube status || minikube start

# Update Kotlin version in build.gradle files
find . -name "build.gradle" -exec sed -i '' 's/ext.kotlin_version = "1.6.0"/ext.kotlin_version = "1.8.22"/' {} +

# Build Flutter apps in parallel
echo "Building Flutter apps..."
run_parallel flutter build web
run_parallel flutter build macos --release --arch arm64
run_parallel flutter build ios --release --no-codesign
run_parallel flutter build apk --release

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

# Launch Android emulator if not running
if ! is_emulator_running "android"; then
    launch_emulator "Medium_Phone_API_35"
fi

# Install apps on devices/emulators
echo "Installing on iOS simulator..."
flutter install -d "iPhone 15 Pro Max"
echo "Installing on Android emulator..."
flutter install -d android

# Wait for all background processes to complete
wait

echo "iOS app installed on simulator. To run on a physical device, open the Xcode project in build/ios/Runner.xcworkspace and run from there."
echo "Android app installed on emulator. To install on a physical device, use: adb install build/app/outputs/flutter-apk/app-release.apk"

echo "Deployment complete!"