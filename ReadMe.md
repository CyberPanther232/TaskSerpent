# TaskSerpent 🐍

TaskSerpent is a lightweight, dual-mode task management application designed for flexibility. It functions as both a standalone web application and an embeddable widget for dashboards or other websites.

Built with Python and Flask, TaskSerpent creates a seamless experience where tasks are synchronized instantly between the main application and any embedded instances.

## Features

*   **Dual Interface**:
    *   **Standalone App**: A full-featured task manager with a dark-themed interface.
    *   **Embeddable Widget**: A compact, transparent-friendly view designed for iframes (`/embed`).
*   **Real-time Sync**: Tasks added or removed from the embedded widget are immediately updated in the main app (and vice-versa).
*   **Dark Mode**: sleek dark theme for comfortable viewing.
*   **Simple Storage**: Uses a lightweight text-file based storage system (`tasks.txt`), no complex database setup required.
*   **Docker Ready**: Includes Docker Compose configuration for easy containerization.
*   **Tailscale Integration**: Pre-configured environment setup for Tailscale users.

## Quick Start

### Prerequisites
*   Git
*   Docker & Docker Compose (optional, for containerized run)
*   Python 3.x (for local run)

### Installation & Setup

We provide automated setup scripts for both Windows and Linux/macOS environments to get you up and running quickly.

#### ⚡ One-Line Quick Install

You can run the setup script directly without manually downloading the repository first. **Note: Run this in the folder where you want to install TaskSerpent.**

**Windows (PowerShell):**
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/CyberPanther232/TaskSerpent/main/scripts/setup.ps1'))
```
*Or using the newer syntax:*
```powershell
irm https://raw.githubusercontent.com/CyberPanther232/TaskSerpent/main/scripts/setup.ps1 | iex
```

**Linux / macOS (Bash):**
```bash
curl -sSL https://raw.githubusercontent.com/CyberPanther232/TaskSerpent/main/scripts/setup.sh | bash
```

---

#### 🪟 Windows (Manual Script Run)

1.  Open PowerShell.
2.  Navigate to the project directory.
3.  Run the setup script:
    ```powershell
    .\scripts\setup.ps1
    ```
    *   The script will check for dependencies, help you configure your `.env` file for Tailscale/Docker, and optionally start the Docker containers for you.

#### 🐧 Linux / macOS (Bash)

1.  Open your terminal.
2.  Navigate to the project directory.
3.  Make the script executable and run it:
    ```bash
    chmod +x scripts/setup.sh
    ./scripts/setup.sh
    ```
    *   This will clone the repo (if needed), prompt for configuration variables, and set up your Docker environment.

### Manual Usage (Local Python)

If you prefer to run it without Docker:

1.  Create a virtual environment:
    ```bash
    python -m venv venv
    source venv/bin/activate  # On Windows: venv\Scripts\activate
    ```
2.  Install dependencies:
    ```bash
    pip install Flask
    ```
3.  Run the application:
    ```bash
    python main.py
    ```
4.  Open your browser to `http://127.0.0.1:5000`.

## Embedding

To embed TaskSerpent into another website, include the following iframe code:

```html
<iframe src="http://YOUR_HOST:5000/embed" width="400" height="500" frameborder="0"></iframe>
```

*Replace `YOUR_HOST` with your actual server IP or domain name.*
