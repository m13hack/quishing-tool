#!/bin/bash

# Docker Setup Script for Quishing Tool
# Note: Contributions are welcome if you're familiar with Docker :)

# Ensure the script is executed from the correct directory
BASE_DIR=$(realpath "$(dirname "$BASH_SOURCE")")

# Create the auth directory if it doesn't exist
if [[ ! -d "$BASE_DIR/auth" ]]; then
    echo "[+] Creating 'auth' directory..."
    mkdir -p "$BASE_DIR/auth"
fi

# Set the container and image details
CONTAINER="quishing-tool"
IMAGE="m13hack/quishing-tool:latest"
IMG_MIRROR="ghcr.io/m13hack/quishing-tool:latest"
MOUNT_LOCATION="${BASE_DIR}/auth"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "[!] Docker is not installed. Please install Docker and try again."
    exit 1
fi

# Check if the container already exists
check_container=$(docker ps --all --format "{{.Names}}" | grep -w "$CONTAINER")

if [[ -z "$check_container" ]]; then
    echo "[+] No existing container found. Creating a new container for Quishing Tool..."
    # Attempt to pull the image (use mirror if pull fails)
    if ! docker pull "$IMAGE"; then
        echo "[!] Failed to pull from the default repository. Trying the mirror image..."
        if ! docker pull "$IMG_MIRROR"; then
            echo "[!] Unable to pull image from both sources. Please check your internet connection."
            exit 1
        else
            IMAGE="$IMG_MIRROR"
        fi
    fi

    # Create the container
    docker create \
        --interactive --tty \
        --volume "${MOUNT_LOCATION}:/quishing-tool/auth/" \
        --network host \
        --name "${CONTAINER}" \
        "${IMAGE}"

    echo "[+] Container '${CONTAINER}' created successfully."
else
    echo "[+] Container '${CONTAINER}' already exists."
fi

# Start the container interactively
echo "[+] Starting the container '${CONTAINER}'..."
docker start --interactive "${CONTAINER}"

# Option to run the container with --rm to clean up after the run (commented)
# docker run --rm -ti --network="host" -v ${MOUNT_LOCATION}:/quishing-tool/auth/ --name "$CONTAINER" "$IMAGE"
