
# Quishing Tool

A user-friendly, automated phishing toolkit featuring 30+ pre-built templates for a variety of platforms.

## Disclaimer

The **Quishing Tool** is provided for educational purposes only. Any misuse of this tool for unlawful activities is your sole responsibility. The developers and contributors of this tool do not accept liability for any legal consequences arising from its inappropriate use.

This tool can potentially be harmful or disruptive to social media platforms. Before using the tool, please ensure compliance with your local laws and regulations.

This tool is designed to showcase **how phishing works** to promote awareness. **Do not use this tool for unauthorized access** to others' social media accounts or private information. You assume all risks if you decide to proceed.

## Key Features

- A wide range of updated phishing templates
- Simple and beginner-friendly interface
- Multiple tunneling methods available:
  - Localhost
  - Cloudflared
  - LocalXpose
- Custom URL masking support
- Docker support for easy deployment

## Installation

Clone the repository to get started:

```bash
git clone https://github.com/m13hack/quishing-tool.git
```

Once cloned, navigate to the tool's directory and execute the script:

```bash
cd quishing-tool
bash quishing.sh
```

Upon the first run, the tool will automatically install all necessary dependencies.

### Installation on Termux

To set up Quishing Tool on Termux, follow these commands:

```bash
pkg install tur-repo
pkg install quishing-tool
quishing-tool
```

> **Note**: Termux discourages discussions about hacking. Please avoid discussing Quishing Tool in Termux forums or groups. For more details, refer to the [wiki](https://github.com/m13hack/quishing-tool/wiki).

### Installing via `.deb` Package

You can also install Quishing Tool using a `.deb` file. Download the latest `.deb` package from the release page. If you're on Termux, make sure to download the `_termux.deb` file.

Install the package using:

```bash
apt install <path-to-deb-file>
```

Or, alternatively:

```bash
dpkg -i <path-to-deb-file>
apt install -f
```

### Running with Docker

Quishing Tool can also be run in a Docker container. You can pull the Docker image from DockerHub or GHCR:

- **DockerHub**:
  ```bash
  docker pull m13hack/quishing-tool
  ```

- **GHCR**:
  ```bash
  docker pull ghcr.io/m13hack/quishing-tool:latest
  ```

To simplify the Docker setup, use the following wrapper script:

```bash
curl -LO https://raw.githubusercontent.com/m13hack/quishing-tool/master/docker.sh
bash docker.sh
```

To run a temporary container:

```bash
docker run --rm -ti m13hack/quishing-tool
```

Make sure to mount the `auth` directory to preserve captured data.

## Requirements

- PHP
- Curl
- Cloudflared or LocalXpose for tunneling services

## Tested Platforms

- Kali Linux
- Ubuntu
- Termux
- Docker

