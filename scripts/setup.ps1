# Windows Setup Script for TaskSerpent
# Based on the bash setup script logic

# Function to show a ASCII progress bar
function Show-ProgressBar {
    param (
        [string]$Activity,
        [int]$PercentComplete,
        [string]$Status
    )
    # Native Write-Progress for PowerShell visuals
    Write-Progress -Activity $Activity -Status $Status -PercentComplete $PercentComplete
    
    # ASCII Bar for terminal history
    $width = 50
    $completed = [math]::Floor($width * ($PercentComplete / 100))
    $remaining = $width - $completed
    $bar = "[" + ("#" * $completed) + ("." * $remaining) + "]"
    
    # Overwrite the previous line if possible, or just print
    # Write-Host "`r" -NoNewline
    Write-Host "$bar $PercentComplete% - $Status" -ForegroundColor Cyan
    if ($PercentComplete -eq 100) { Write-Host "" } # Newline at end
}

Write-Host "Downloading and setting up TaskSerpent environment..." -ForegroundColor Cyan
Show-ProgressBar -Activity "Setup TaskSerpent" -PercentComplete 10 -Status "Initializing..."

# 1. Check for Repository/Git
if (-not (Test-Path ".git")) {
    Write-Host "`nCloning TaskSerpent repository..." -ForegroundColor Yellow
    Show-ProgressBar -Activity "Setup TaskSerpent" -PercentComplete 20 -Status "Cloning Repository..."
    
    if (Get-Command git -ErrorAction SilentlyContinue) {
        git clone https://github.com/CyberPanther232/TaskSerpent.git .
        if ($LASTEXITCODE -eq 0) {
            Write-Host "TaskSerpent repository cloned successfully." -ForegroundColor Green
        } else {
             Write-Host "Failed to clone repository." -ForegroundColor Red
             exit 1
        }
    } else {
        Write-Host "Git is not installed. Please install Git and run this script again." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "`nTaskSerpent repository already exists. Skipping cloning." -ForegroundColor Gray
    Show-ProgressBar -Activity "Setup TaskSerpent" -PercentComplete 20 -Status "Repository Exists"
}

# 2. Setup Environment Variables
Write-Host "`nSetting up environment variables..." -ForegroundColor Cyan
Show-ProgressBar -Activity "Setup TaskSerpent" -PercentComplete 30 -Status "Checking .env Configuration..."

if (-not (Test-Path ".env")) {
    $defaultEnv = @"
TS_AUTHKEY=your-tailscale-auth-key
TS_NET_NAME=taskserpent_ts_net
TS_TAG=tag:docker
TS_HOSTNAME=taskserpent
TS_DOMAIN_NAME=ts.net
"@
    Set-Content -Path ".env" -Value $defaultEnv -Encoding UTF8
    Write-Host ".env file created. Please update it with your Tailscale auth key." -ForegroundColor Yellow
} else {
    Write-Host ".env file already exists. Please ensure it contains correct values." -ForegroundColor Gray
}

Show-ProgressBar -Activity "Setup TaskSerpent" -PercentComplete 40 -Status "Prompting User..."

$response = Read-Host "`nWould you like to add the environment variables step-by-step? (y/n)"
if ($response -eq 'y') {
    $TS_AUTHKEY = Read-Host "Enter Tailscale auth key"
    $TS_NET_NAME = Read-Host "Enter Tailscale network name"
    $TS_TAG = Read-Host "Enter Tailscale tag (e.g., tag:docker)"
    $TS_HOSTNAME = Read-Host "Enter hostname (e.g., taskserpent)"
    $TS_DOMAIN_NAME = Read-Host "Enter domain name (e.g., ts.net)"

    $newEnv = @"
TS_AUTHKEY=$TS_AUTHKEY
TS_NET_NAME=$TS_NET_NAME
TS_TAG=$TS_TAG
TS_HOSTNAME=$TS_HOSTNAME
TS_DOMAIN_NAME=$TS_DOMAIN_NAME
"@
    Set-Content -Path ".env" -Value $newEnv -Encoding UTF8
    Write-Host ".env file updated with your input." -ForegroundColor Green
} else {
    Write-Host "Skipping environment variable input step." -ForegroundColor Gray
}

Show-ProgressBar -Activity "Setup TaskSerpent" -PercentComplete 60 -Status "Environment Setup Complete"

# 3. Docker Compose Setup
Write-Host "`nBeginning Docker Compose setup..." -ForegroundColor Cyan

function Copy-IfMissing {
    param ($Source, $Dest)
    if (-not (Test-Path $Dest)) {
        if (Test-Path $Source) {
            Copy-Item -Path $Source -Destination $Dest
            Write-Host "$Dest created from $Source." -ForegroundColor Green
        } else {
            Write-Host "Warning: Example file $Source not found." -ForegroundColor Yellow
        }
    } else {
        Write-Host "$Dest already exists." -ForegroundColor Gray
    }
}

Show-ProgressBar -Activity "Setup TaskSerpent" -PercentComplete 70 -Status "Configuring Docker Files..."

Copy-IfMissing -Source "serve.json.example" -Dest "serve.json"
Copy-IfMissing -Source "docker-compose.example.yml" -Dest "docker-compose.yml"
Copy-IfMissing -Source "Dockerfile.example" -Dest "Dockerfile"

Write-Host "Docker Compose setup complete." -ForegroundColor Green
Show-ProgressBar -Activity "Setup TaskSerpent" -PercentComplete 80 -Status "Files Ready"

# 4. Start Docker
$startResponse = Read-Host "`nSetup complete. Start containers now with 'docker-compose up -d'? (y/n)"

if ($startResponse -eq 'y') {
    Write-Host "Starting Docker Compose..." -ForegroundColor Cyan
    Show-ProgressBar -Activity "Setup TaskSerpent" -PercentComplete 90 -Status "Launching Containers..."
    
    try {
        docker-compose up -d
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Docker Compose started successfully." -ForegroundColor Green
        } else {
            Write-Host "Docker Compose command failed. Check if Docker is running." -ForegroundColor Red
        }
    } catch {
        Write-Host "Error executing docker-compose." -ForegroundColor Red
    }
} else {
    Write-Host "Skipping start. Run 'docker-compose up -d' manually later." -ForegroundColor Gray
}

Show-ProgressBar -Activity "Setup TaskSerpent" -PercentComplete 100 -Status "Done!"
Start-Sleep -Seconds 1
Write-Host "`nSetup Finished! update .env/config files before starting if needed." -ForegroundColor Green
