#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Install dependencies
install_dependencies() {
    echo "[INFO] Installing required Python packages..."
    if ! command_exists pip; then
        echo "[ERROR] pip not found. Please install pip first."
        exit 1
    fi

    pip install Flask qrcode[pil] || {
        echo "[ERROR] Failed to install required packages."
        exit 1
    }

    echo "[INFO] Dependencies installed successfully."
}

# Create necessary directories
create_directories() {
    echo "[INFO] Creating necessary directories..."
    mkdir -p log || {
        echo "[ERROR] Failed to create log directory."
        exit 1
    }
    mkdir -p sites/site1/assets || {
        echo "[ERROR] Failed to create site1/assets directory."
        exit 1
    }
    mkdir -p sites/site2/assets || {
        echo "[ERROR] Failed to create site2/assets directory."
        exit 1
    }
    echo "[INFO] Directories created successfully."
}

# Main installation process
main() {
    install_dependencies
    create_directories
    echo "[INFO] Installation completed successfully."
}

main
