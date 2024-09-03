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

    pip install Flask qrcode[pil]
    if [ $? -ne 0 ]; then
        echo "[ERROR] Failed to install required packages. Please check your internet connection or pip configuration."
        exit 1
    fi

    echo "[INFO] Dependencies installed successfully."
}

# Create necessary directories
create_directories() {
    echo "[INFO] Creating necessary directories..."

    mkdir -p log
    if [ $? -ne 0 ]; then
        echo "[ERROR] Failed to create log directory. Please check your permissions."
        exit 1
    fi

    mkdir -p sites/site1/assets
    if [ $? -ne 0 ]; then
        echo "[ERROR] Failed to create site1/assets directory. Please check your permissions."
        exit 1
    fi

    mkdir -p sites/site2/assets
    if [ $? -ne 0 ]; then
        echo "[ERROR] Failed to create site2/assets directory. Please check your permissions."
        exit 1
    fi

    echo "[INFO] Directories created successfully."
}

# Check if the script is run as root (optional, but useful)
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "[WARNING] It's recommended to run this script as root or with sudo for proper permissions."
        read -p "Continue anyway? (y/n): " choice
        case "$choice" in
            y|Y ) echo "[INFO] Continuing without root...";;
            n|N ) echo "[INFO] Aborting script."; exit 1;;
            * ) echo "[ERROR] Invalid input. Aborting script."; exit 1;;
        esac
    fi
}

# Main installation process
main() {
    check_root
    install_dependencies
    create_directories
    echo "[INFO] Installation completed successfully."
}

# Handle unexpected errors globally
trap 'echo "[ERROR] An unexpected error occurred. Exiting..."; exit 1;' ERR

main
