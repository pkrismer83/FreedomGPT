#!/bin/bash

set -e

echo "Checking for Docker..."
if ! command -v docker &> /dev/null
then
    echo "Docker could not be found. Please install Docker and try again."
    exit 1
fi

echo "Pulling the latest MobSF Docker image..."
docker pull opensecurity/mobile-security-framework-mobsf

echo "Starting MobSF on http://localhost:8000 ..."
docker run -it -p 8000:8000 opensecurity/mobile-security-framework-mobsf:latest
