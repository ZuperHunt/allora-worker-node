#!/bin/bash

# Colors for the terminal
BOLD="\033[1m"
UNDERLINE="\033[4m"
DARK_YELLOW="\033[0;33m"
CYAN="\033[0;36m"
RESET="\033[0;32m"

# Function to execute a command with a prompt
execute_with_prompt() {
    echo -e "${BOLD}Executing: $1${RESET}"
    if eval "$1"; then
        echo "Command executed successfully."
    else
        echo -e "${BOLD}${DARK_YELLOW}Error executing command: $1${RESET}"
        exit 1
    fi
}

# Function to replace code in a file
replace_code() {
    local file_path="$1"
    local new_text="$2"
    local old_text= "$3"
    sed -i "s|$old_text|$new_text|g" "$file_path"
}

# Function to add code to a file
add_code() {
    local file_path="$1"
    local new_text="$2"
    echo "$new_text" >> "$file_path"
}

# Display the requirements for running the allora worker node
echo -e "${BOLD}${UNDERLINE}${DARK_YELLOW}Requirement for Running Allora Worker${RESET}"
echo
echo -e "${BOLD}${DARK_YELLOW}Operating System: Minimum Ubuntu 20.04${RESET}"
echo -e "${BOLD}${DARK_YELLOW}CPU: Minimum of 2 core${RESET}"
echo -e "${BOLD}${DARK_YELLOW}RAM: Minimum 4 GB${RESET}"
echo -e "${BOLD}${DARK_YELLOW}Storage: SSD or NVMe with at least 50GB of space${RESET}"
echo

# Prompt the user to confirm if they meet the requirements
echo -e "${CYAN}Do you meet all of these requirements? (Y/N):${RESET}"
read -p "" response
echo

# Check if the user meets the requirements, exit if not
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo -e "${BOLD}${DARK_YELLOW}Error: You do not meet the required specifications. Exiting...${RESET}"
    echo
    exit 1
fi

# Update APT package index
echo -e "${BOLD}${DARK_YELLOW}Updating APT package index...${RESET}"
execute_with_prompt "sudo apt update -y && sudo apt upgrade -y"
execute_with_prompt "sudo apt-get install apt-transport-https software-properties-common ca-certificates zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev curl git wget make jq build-essential pkg-config lsb-release libssl-dev libreadline-dev libffi-dev gcc screen unzip lz4 make -y"
echo

# Install Docker
echo -e "${BOLD}${DARK_YELLOW}Installing Docker...${RESET}"
execute_with_prompt 'sudo install -m 0755 -d /etc/apt/keyrings'
execute_with_prompt 'sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc'
execute_with_prompt 'sudo chmod a+r /etc/apt/keyrings/docker.asc'
execute_with_prompt 'echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null'
execute_with_prompt 'sudo apt-get update'
execute_with_prompt 'sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y'
if ! grep -q '^docker:' /etc/group; then
    execute_with_prompt 'sudo groupadd docker'
    echo
fi
execute_with_prompt 'sudo usermod -aG docker $USER'
echo
sleep 2
echo -e "${BOLD}${DARK_YELLOW}Checking docker version...${RESET}"
execute_with_prompt 'docker version'
echo

# Install Go
echo -e "${BOLD}${DARK_YELLOW}Installing Go...${RESET}"
execute_with_prompt 'cd $HOME'
execute_with_prompt 'ver="1.21.3" && wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"'
execute_with_prompt 'sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"'
execute_with_prompt 'rm "go$ver.linux-amd64.tar.gz"'
execute_with_prompt 'echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile'
execute_with_prompt 'source $HOME/.bash_profile'
echo
sleep 2
echo -e "${BOLD}${DARK_YELLOW}Checking Go version...${RESET}"
execute_with_prompt 'go version'
echo

# Install Python
echo -e "${BOLD}${DARK_YELLOW}Installing Python...${RESET}"
execute_with_prompt 'sudo apt install python3 -y'
echo
sleep 2
echo -e "${BOLD}${DARK_YELLOW}Checking Python version...${RESET}"
execute_with_prompt 'python3 --version'
echo

# Install pip
echo -e "${BOLD}${DARK_YELLOW}Installing pip...${RESET}"
execute_with_prompt 'sudo apt install python3-pip -y'
echo
sleep 2
echo -e "${BOLD}${DARK_YELLOW}Checking pip version...${RESET}"
execute_with_prompt 'pip3 --version'
echo

# Install Allocmd
echo -e "${BOLD}${DARK_YELLOW}Installing Allocmd...${RESET}"
execute_with_prompt 'pip install allocmd --upgrade'
echo
sleep 2
echo -e "${BOLD}${DARK_YELLOW}Checking Allocmd version...${RESET}"
execute_with_prompt 'allocmd --version'
echo

# Choose topic and name for worker node
echo -e "${BOLD}${DARK_YELLOW}Choose a Topic for the Worker Node:${RESET}"
echo
echo -e "${BOLD}${DARK_YELLOW}1. ETH 10min${RESET}"
echo -e "${BOLD}${DARK_YELLOW}2. ETH 24hour${RESET}"
echo -e "${BOLD}${DARK_YELLOW}3. BTC 10min${RESET}"
echo -e "${BOLD}${DARK_YELLOW}4. BTC 24hour${RESET}"
echo -e "${BOLD}${DARK_YELLOW}5. SOL 10min${RESET}"
echo -e "${BOLD}${DARK_YELLOW}6. SOL 24hour${RESET}"
echo -e "${BOLD}${DARK_YELLOW}7. ETH 20min${RESET}"
echo -e "${BOLD}${DARK_YELLOW}8. BNB 20min${RESET}"
echo -e "${BOLD}${DARK_YELLOW}9. ARB 20min${RESET}"
echo
echo -e "${CYAN}Enter the number of the topic you want to choose: ${RESET}"
read -p "" TOPIC
echo -e "${CYAN}Enter the name of the worker node: ${RESET}"
read -p "" WORKER_NAME
if [ "$TOPIC" == "1" ]; then
    TOPIC_TICKER="ETH"
    TOPIC_COIN="ethereum"
elif [ "$TOPIC" == "2" ]; then
    TOPIC_TICKER="ETH"
    TOPIC_COIN="ethereum"
elif [ "$TOPIC" == "3" ]; then
    TOPIC_TICKER="BTC"
    TOPIC_COIN="bitcoin"
elif [ "$TOPIC" == "4" ]; then
    TOPIC_TICKER="BTC"
    TOPIC_COIN="bitcoin"
elif [ "$TOPIC" == "5" ]; then
    TOPIC_TICKER="SOL"
    TOPIC_COIN="solana"
elif [ "$TOPIC" == "6" ]; then
    TOPIC_TICKER="SOL"
    TOPIC_COIN="solana"
elif [ "$TOPIC" == "7" ]; then
    TOPIC_TICKER="ETH"
    TOPIC_COIN="ethereum"
elif [ "$TOPIC" == "8" ]; then
    TOPIC_TICKER="BNB"
    TOPIC_COIN="binancecoin"
elif [ "$TOPIC" == "9" ]; then
    TOPIC_TICKER="ARB"
    TOPIC_COIN="arbitrum"
fi
echo

# Choose the model for the worker node
echo -e "${BOLD}${DARK_YELLOW}Choose a Model for the Worker Node:${RESET}"
echo
echo -e "${BOLD}${DARK_YELLOW}1. Chronos Tiny${RESET}"
echo -e "${BOLD}${DARK_YELLOW}2. Chronos Mini${RESET}"
echo -e "${BOLD}${DARK_YELLOW}3. Chronos Small${RESET}"
echo -e "${BOLD}${DARK_YELLOW}4. Chronos Base${RESET}"
echo -e "${BOLD}${DARK_YELLOW}5. Chronos Large${RESET}"
echo
echo -e "${CYAN}Enter the number of the model you want to choose: ${RESET}"
read -p "" MODEL
if [ "$MODEL" == "1" ]; then
    MODEL="chronos-t5-tiny"
elif [ "$MODEL" == "2" ]; then
    MODEL="chronos-t5-mini"
elif [ "$MODEL" == "3" ]; then
    MODEL="chronos-t5-small"
elif [ "$MODEL" == "4" ]; then
    MODEL="chronos-t5-base"
elif [ "$MODEL" == "5" ]; then
    MODEL="chronos-t5-large"
fi
echo

# Initialize Allora Worker Node directory
echo -e "${BOLD}${DARK_YELLOW}Initializing Allora Worker Node Directory...${RESET}"
execute_with_prompt "sudo mkdir -p $WORKER_NAME/worker/data/head"
execute_with_prompt "sudo mkdir -p $WORKER_NAME/worker/data/worker"
execute_with_prompt "sudo chmod -R 777 $WORKER_NAME/worker/data"
execute_with_prompt "sudo chmod -R 777 $WORKER_NAME/worker/data/head"
execute_with_prompt "sudo chmod -R 777 $WORKER_NAME/worker/data/worker"
echo

# Initialize Allora Worker Node with Allocmd
echo -e "${BOLD}${DARK_YELLOW}Initializing Allora Worker Node with Allocmd...${RESET}"
execute_with_prompt "allocmd generate worker --name $WORKER_NAME --topic $TOPIC --env dev --network allora-testnet-1"
echo

# Change directory to Allora Worker Node
echo -e "${BOLD}${DARK_YELLOW}Changing Directory to Allora Worker Node...${RESET}"
execute_with_prompt "cd $WORKER_NAME/worker"
echo

# Check if the user has seed phrase, exit if not
echo -e "${CYAN}Do you want to use your Wallet Seed Phrase? (Y/N):${RESET}"
read -p "" response_wallet
echo
if [[ "$response_wallet" =~ ^[Yy]$ ]]; then
    # Add wallet seed phrase to Allorad keyring backend
    echo -e "${BOLD}${DARK_YELLOW}Adding Wallet Seed Phrase to Allorad Keyring Backend...${RESET}"
    execute_with_prompt "allorad keys delete $WORKER_NAME --keyring-backend test -y"
    echo
    echo -e "${BOLD}${DARK_YELLOW}Enter the Wallet Seed Phrase:${RESET}"
    execute_with_prompt "allorad keys add --recover $WORKER_NAME --keyring-backend test"
    echo
elif [[ "$response_wallet" =~ ^[Nn]$ ]]; then
    # Show the default wallet seed phrase
    echo -e "${BOLD}${DARK_YELLOW}This is your default wallet, save the mnemonic phrase in a safe place and fill the wallet with ALLO on the faucet${RESET}"
    execute_with_prompt "allorad keys list --keyring-backend test"
    execute_with_prompt "sed -n '11,13p' config.yaml"
    echo -e "${CYAN}Press any key to continue deploying your node${RESET}"
    read -p "" response
fi

# Add app.py file to the worker node directory
echo -e "${BOLD}${DARK_YELLOW}Adding app.py File to the Worker Node...${RESET}"
execute_with_prompt "sudo rm -rf app.py"
execute_with_prompt "wget https://raw.githubusercontent.com/ZuperHunt/Allora-Worker-Node/main/app.py"
replace_code "app.py" "model_name = 'amazon/$MODEL'" "model_name = 'amazon/chronos-t5-tiny'"
replace_code "app.py" "    if not token or token != '$TOPIC_TICKER':" "    if not token or token != 'BTC':"
replace_code "app.py" "        url = 'https://api.coingecko.com/api/v3/coins/$TOPIC_COIN/market_chart?vs_currency=usd&days=30&interval=daily'" "        url = 'https://api.coingecko.com/api/v3/coins/bitcoin/market_chart?vs_currency=usd&days=30&interval=daily'"

# Add requirements.txt file to the worker node directory
echo -e "${BOLD}${DARK_YELLOW}Adding requirements.txt File to the Worker Node...${RESET}"
execute_with_prompt "sudo rm -rf requirements.txt"
execute_with_prompt "wget https://raw.githubusercontent.com/ZuperHunt/Allora-Worker-Node/main/requirements.txt"

# Add main.py file to the worker node directory
echo -e "${BOLD}${DARK_YELLOW}Adding main.py File to the Worker Node...${RESET}"
execute_with_prompt "sudo rm -rf main.py"
execute_with_prompt "wget https://raw.githubusercontent.com/ZuperHunt/Allora-Worker-Node/main/main.py"

# Add Dockerfile file to the worker node directory
echo -e "${BOLD}${DARK_YELLOW}Adding Dockerfile File to the Worker Node...${RESET}"
execute_with_prompt "sudo rm -rf Dockerfile"
execute_with_prompt "wget https://raw.githubusercontent.com/ZuperHunt/Allora-Worker-Node/main/Dockerfile"

# Add Dockerfile_inference file to the worker node directory
echo -e "${BOLD}${DARK_YELLOW}Adding Dockerfile_inference File to the Worker Node...${RESET}"
execute_with_prompt "sudo rm -rf Dockerfile_inference"
execute_with_prompt "wget https://raw.githubusercontent.com/ZuperHunt/Allora-Worker-Node/main/Dockerfile_inference"

if [[ "$response_wallet" =~ ^[Yy]$ ]]; then
    # Update wallet address and mnemonic config.yaml file
    echo -e "${BOLD}${DARK_YELLOW}Updating config.yaml File...${RESET}"
    WALLET_ADDRESS=$(allorad keys list --keyring-backend test | grep -oP '(?<=address: ).*')
    execute_with_prompt "sed -i '/  address:/c\\  address: $WALLET_ADDRESS' 'config.yaml'"
    HEX_KEY=$(allorad keys export $WORKER_NAME --keyring-backend test --unarmored-hex --unsafe)
    execute_with_prompt "sed -i '/  hex_coded_pk:/c\\  hex_coded_pk: $HEX_KEY' 'config.yaml'"
    echo -e "${BOLD}${DARK_YELLOW}Input your Mnemonic Phrase: {RESET}"
    read -p "" MNEMONIC_PHRASE
    execute_with_prompt "sed -i '/  mnemonic:/c\\  mnemonic: $MNEMONIC_PHRASE' 'config.yaml'"
elif [[ "$response_wallet" =~ ^[Nn]$ ]]; then
    # Update wallet address and mnemonic config.yaml file
    echo -e "${BOLD}${DARK_YELLOW}Updating config.yaml File...${RESET}"
    HEX_KEY=$(allorad keys export $WORKER_NAME --keyring-backend test --unarmored-hex --unsafe)
    sed -i "/  hex_coded_pk:/c\\  hex_coded_pk: '$HEX_KEY'" "config.yaml"
fi

# Update dev-docker-compose.yaml file
echo -e "${BOLD}${DARK_YELLOW}Updating dev-docker-compose.yaml File...${RESET}"
new_lines="  inference:\n    container_name: inference-hf\n    build:\n      context: .\n      dockerfile: Dockerfile_inference\n    command: python -u /app/app.py\n    ports:\n      - \"8000:8000\"\n    networks:\n      b7s-local:\n        aliases:\n          - inference\n        ipv4_address: 172.19.0.4"
sed -i "/services:/a\\
$new_lines" "dev-docker-compose.yaml"

# Move Worker Node to production mode
echo -e "${BOLD}${DARK_YELLOW}Move Worker Node to Production Mode...${RESET}"
execute_with_prompt "allocmd generate worker --env prod --network allora-testnet-1"
chmod -R +rx ./data/scripts
chmod +x ./update-node-ip.sh

# Update prod-docker-compose.yaml file
echo -e "${BOLD}${DARK_YELLOW}Updating prod-docker-compose.yaml File...${RESET}"
new_lines="  inference:\n    container_name: inference-hf\n    build:\n      context: .\n      dockerfile: Dockerfile_inference\n    command: python -u /app/app.py\n    ports:\n      - \"8000:8000\"\n"
sed -i "/services:/a\\
$new_lines" "prod-docker-compose.yaml"

echo -e "${BOLD}${DARK_YELLOW}Allora Worker Node Setup Completed...${RESET}"
echo
