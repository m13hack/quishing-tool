_PACKAGE="quishing-tool"         # Updated package name
_VERSION="1.0.0"                 # Version number
_ARCH="all"                      # Architecture type
PKG_NAME="${_PACKAGE}_${_VERSION}_${_ARCH}.deb"  # Name of the output .deb file

# Check if the `launch.sh` exists in the `scripts/` directory
if [[ ! -e "scripts/launch.sh" ]]; then
    echo "[!] Error: 'launch.sh' should be in the 'scripts' directory. Exiting..."
    exit 1
fi

# If termux or Android system is detected, use different paths and dependencies
if [[ ${1,,} == "termux" || $(uname -o) == *'Android'* ]]; then
    _depend="ncurses-utils, proot, resolv-conf, "
    _bin_dir="data/data/com.termux/files/"
    _opt_dir="data/data/com.termux/files/usr/"
fi

# Default dependencies for all environments
_depend+="curl, php, unzip"
_bin_dir+="usr/bin"                          # Set binary directory
_opt_dir+="opt/${_PACKAGE}"                  # Set option directory

# Clean any previous build environment if it exists
if [[ -d "build_env" ]]; then 
    echo "[+] Removing old build environment..."
    rm -rf build_env
fi

# Create necessary directories for building the package
echo "[+] Setting up build environment..."
mkdir -p ./build_env/${_bin_dir}            # For binary files
mkdir -p ./build_env/${_opt_dir}            # For other files like scripts
mkdir -p ./build_env/DEBIAN                 # DEBIAN folder for control files

# Create the `control` file which holds package information
echo "[+] Creating control file..."
cat <<- CONTROL_EOF > ./build_env/DEBIAN/control
Package: ${_PACKAGE}
Version: ${_VERSION}
Architecture: ${_ARCH}
Maintainer: @m13hack
Depends: ${_depend}
Homepage: https://github.com/m13hack/quishing-tool
Description: Quishing Tool is an automated QR code phishing tool designed to help users learn about phishing techniques.
             This tool is intended for educational purposes only. Use it responsibly!
CONTROL_EOF

# Create `prerm` script that runs before the package is removed
echo "[+] Creating prerm script..."
cat <<- PRERM_EOF > ./build_env/DEBIAN/prerm
#!/bin/bash
echo "[!] Removing ${_PACKAGE} files..."
rm -rf ${_opt_dir}
exit 0
PRERM_EOF

# Set correct permissions for DEBIAN control and prerm files
chmod 755 ./build_env/DEBIAN
chmod 755 ./build_env/DEBIAN/control
chmod 755 ./build_env/DEBIAN/prerm

# Copy the necessary files into the build environment
echo "[+] Copying files to build environment..."
cp -fr scripts/launch.sh ./build_env/${_bin_dir}/${_PACKAGE}  # Copy launch script to the bin directory
chmod 755 ./build_env/${_bin_dir}/${_PACKAGE}                # Ensure executable permissions

# Copy other files (LICENSE, README.md, etc.)
cp -fr .github/ .sites/ LICENSE README.md zphisher.sh ./build_env/${_opt_dir}

# Build the .deb package
echo "[+] Building Debian package..."
dpkg-deb --build ./build_env ${PKG_NAME}

# Clean up build environment
echo "[+] Cleaning up..."
rm -rf ./build_env

echo "[+] Package ${PKG_NAME} has been built successfully!"
