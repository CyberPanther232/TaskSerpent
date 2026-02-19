#!/usr/bin/env bash

# This script sets up the TaskSerpent environment by creating necessary files and directories.

# Function to show a progress bar
# Usage: show_progress [current_step] [total_steps] [task_description]
show_progress() {
    local current=$1
    local total=$2
    local task=$3
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))
    
    # Build the bar string
    local bar="["
    for ((i=0; i<completed; i++)); do bar+="#"; done
    for ((i=0; i<remaining; i++)); do bar+="."; done
    bar+="]"
    
    # Print the progress bar (carriage return \r overwrites the line)
    printf "\r%-70s\n" "$task"
    printf "%s %3d%%" "$bar" "$percentage"
    echo "" # New line for cleanliness between steps
}

echo "Downloading and setting up TaskSerpent environment..."
show_progress 1 10 "Initializing setup..."

if [ ! -d .git ]; then
    echo "Cloning TaskSerpent repository..."
    show_progress 2 10 "Cloning repository..."

    if git --version > /dev/null 2>&1; then
        git clone https://github.com/CyberPanther232/TaskSerpent.git .
        echo "TaskSerpent repository cloned successfully."
    else
        echo "Git is not installed. Please install Git and run this script again."
        exit 1
    fi
else
    echo "TaskSerpent repository already exists. Skipping cloning."
    show_progress 2 10 "Repository check skipped (already exists)"
fi

# Setup environment variables
echo "Setting up environment variables..."
show_progress 3 10 "Checking environment configuration..."

# Create a .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "TS_AUTHKEY=your-tailscale-auth-key" > .env
    echo "TS_NET_NAME=taskserpent_ts_net" >> .env
    echo "TS_TAG=tag:docker" >> .env
    echo "TS_HOSTNAME=taskserpent" >> .env
    echo "TS_DOMAIN_NAME=ts.net" >> .env
    echo ".env file created. Please update it with your Tailscale auth key and desired settings."
else
    echo ".env file already exists. Please ensure it contains the correct values."
fi

show_progress 4 10 "Environment check complete"

echo "Would you like to add the environment variables step-by-step? (y/n)"
read -r response

if [[ $response == "y" ]]; then
    echo "Please enter your Tailscale auth key:"
    read -r TS_AUTHKEY
    echo "Please enter your desired Tailscale network name:"
    read -r TS_NET_NAME
    echo "Please enter your desired Tailscale tag (e.g., tag:docker):"
    read -r TS_TAG
    echo "Please enter your desired hostname (e.g., taskserpent):"
    read -r TS_HOSTNAME
    echo "Please enter your desired domain name (e.g., ts.net):"
    read -r TS_DOMAIN_NAME
    echo "TS_AUTHKEY=$TS_AUTHKEY" > .env
    echo "TS_NET_NAME=$TS_NET_NAME" >> .env
    echo "TS_TAG=$TS_TAG" >> .env
    echo "TS_HOSTNAME=$TS_HOSTNAME" >> .env
    echo "TS_DOMAIN_NAME=$TS_DOMAIN_NAME" >> .env
    echo ".env file created with your input."
else
    echo "Skipping environment variable setup. Please ensure your .env file is correctly configured."
fi

show_progress 6 10 "Environment variables configured"

echo "Environment Variables setup complete."

echo "Meaning Docker Compose setup..."
show_progress 7 10 "Configuring Docker files..."

if [ ! -f serve.json ]; then
    mv serve.example.json serve.json
    echo "serve.json file created from serve.example.json. Please review and update it as needed."
else
    echo "serve.json file already exists. Please review it to ensure it contains the correct configuration."
fi

if [ ! -f docker-compose.yml ]; then
    mv docker-compose.example.yml docker-compose.yml
    echo "docker-compose.yml file created from docker-compose.example.yml. Please review and update it as needed."
else
    echo "docker-compose.yml file already exists. Please review it to ensure it contains the correct configuration."
fi

if [ ! -f Dockerfile ]; then
    mv Dockerfile.example Dockerfile
    echo "Dockerfile created from Dockerfile.example. Please review and update it as needed."
else
    echo "Dockerfile already exists. Please review it to ensure it contains the correct configuration."
fi

echo "Docker Compose setup complete."
show_progress 8 10 "Docker configuration ready"

echo "Setup complete. You can now run 'docker-compose up -d' or I can start it for you. Would you like me to start the containers now? (y/n)"
read -r response

if [[ $response == "y" ]]; then
    echo "Starting Docker Compose..."
    show_progress 9 10 "Starting containers..."
    docker-compose up -d

    if [ $? -eq 0 ]; then
        echo "Docker Compose started successfully."
    else
        echo "Failed to start Docker Compose. Please check the error messages above and try again."
    fi

else
    echo "Skipping Docker Compose startup. You can start it later by running 'docker-compose up -d'."
fi

show_progress 10 10 "Setup finished successfully!"
echo "Setup complete. Please ensure you have updated the .env, serve.json, docker-compose.yml, and Dockerfile with the correct values for your environment before starting the containers."