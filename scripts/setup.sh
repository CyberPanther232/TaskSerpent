#!/usr/bin/env bash

# This script sets up the TaskSerpent environment.
# It can be run directly via curl, or from within a cloned repository.

# --- Helper Functions ---

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

# Function to read user input safely, even when piped
read_user_input() {
    local -n a_variable_name=$1
    if [ -t 0 ]; then
        read -r a_variable_name
    else
        read -r a_variable_name < /dev/tty
    fi
}


# --- Main Setup Logic ---
main_setup() {
    echo "Running TaskSerpent setup in the current directory..."
    show_progress 2 10 "Repository check passed"

    # Setup environment variables
    echo "Setting up environment variables..."
    show_progress 3 10 "Checking environment configuration..."

    # Create a .env file if it doesn't exist
    if [ ! -f .env ]; then
        if [ -f .env.example ]; then
            cp .env.example .env
            echo ".env file created from example. Please update it with your Tailscale auth key."
        else
            echo "TS_AUTHKEY=your-tailscale-auth-key" > .env
            echo "TS_NET_NAME=taskserpent_ts_net" >> .env
            echo "TS_TAG=tag:docker" >> .env
            echo "TS_HOSTNAME=taskserpent" >> .env
            echo "TS_DOMAIN_NAME=ts.net" >> .env
            echo ".env file created. Please update it with your Tailscale auth key and desired settings."
        fi
    else
        echo ".env file already exists. Please ensure it contains the correct values."
    fi

    show_progress 4 10 "Environment check complete"

    echo "Would you like to add the environment variables step-by-step? (y/n)"
    read_user_input response

    if [[ $response == "y" ]] || [[ $response == "Y" ]]; then
        echo "Please enter your Tailscale auth key:"
        read_user_input TS_AUTHKEY
        
        echo "Please enter your desired Tailscale network name (default: taskserpent_ts_net):"
        read_user_input TS_NET_NAME
        TS_NET_NAME=${TS_NET_NAME:-taskserpent_ts_net}
        
        echo "Please enter your desired Tailscale tag (e.g., tag:docker, default: tag:docker):"
        read_user_input TS_TAG
        TS_TAG=${TS_TAG:-tag:docker}

        echo "Please enter your desired hostname (e.g., taskserpent, default: taskserpent):"
        read_user_input TS_HOSTNAME
        TS_HOSTNAME=${TS_HOSTNAME:-taskserpent}
        
        echo "Please enter your desired domain name (e.g., ts.net, default: ts.net):"
        read_user_input TS_DOMAIN_NAME
        TS_DOMAIN_NAME=${TS_DOMAIN_NAME:-ts.net}

        {
            echo "TS_AUTHKEY=$TS_AUTHKEY"
            echo "TS_NET_NAME=$TS_NET_NAME"
            echo "TS_TAG=$TS_TAG"
            echo "TS_HOSTNAME=$TS_HOSTNAME"
            echo "TS_DOMAIN_NAME=$TS_DOMAIN_NAME"
        } > .env
        
        echo ".env file updated with your input."
    else
        echo "Skipping environment variable setup. Please ensure your .env file is correctly configured."
    fi

    show_progress 6 10 "Environment variables configured"

    echo "Environment Variables setup complete."

    echo "Beginning configuration file setup..."
    show_progress 7 10 "Configuring files..."

    # Create serve.json from its example if it doesn't exist
    if [ ! -f serve.json ]; then
        if [ -f serve.json.example ]; then
            cp serve.json.example serve.json
            echo "serve.json file created from serve.json.example."
        else
            echo "Warning: serve.json.example not found. Skipping creation of serve.json."
        fi
    else
        echo "serve.json file already exists."
    fi

    # docker-compose.yml and Dockerfile are tracked in git, so no need to create them.

    echo "Configuration file setup complete."
    show_progress 8 10 "Docker configuration ready"

    echo "Setup complete. You can now run 'docker-compose up -d' or I can start it for you. Would you like me to start the containers now? (y/n)"
    read_user_input response

    if [[ $response == "y" ]] || [[ $response == "Y" ]]; then
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
    echo "Setup complete. Please ensure you have updated the .env and serve.json with the correct values for your environment before starting the containers."
}


# --- Script Entrypoint ---

# Are we being run via curl? Or are we already in the repo?
# A simple check for the .git directory and the script's own path is enough.
if [ -d ".git" ] && [ -f "scripts/setup.sh" ]; then
    # We are in the root of the repository. Just run the setup.
    main_setup
    exit 0
fi


# If we've reached here, we're not in the repo.
# This part of the script acts as the "installer".

echo "TaskSerpent repository not found. Starting installer..."
show_progress 1 10 "Initializing installer..."

# 1. Check for git
if ! git --version > /dev/null 2>&1; then
    echo "Error: Git is not installed. Please install Git to continue."
    exit 1
fi

# 2. Check if the target directory already exists
if [ -d "TaskSerpent" ]; then
    echo "Error: Directory 'TaskSerpent' already exists in the current location."
    echo "Please remove it, or 'cd TaskSerpent' and run './scripts/setup.sh' manually."
    exit 1
fi

# 3. Clone the repository
echo "Cloning TaskSerpent repository into a new 'TaskSerpent' directory..."
git clone https://github.com/CyberPanther232/TaskSerpent.git TaskSerpent
if [ $? -ne 0 ]; then
    echo "Error: Failed to clone repository."
    exit 1
fi

# 4. Enter the new directory and run the main setup
cd TaskSerpent
echo "Repository cloned successfully."

main_setup

exit 0
