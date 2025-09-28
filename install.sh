#!/bin/bash

# FreedomGPT Automatic Installation Script
# This script automatically installs and sets up FreedomGPT on Linux/macOS systems

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Progress indicator
show_progress() {
    local current=$1
    local total=$2
    local desc=$3
    local progress=$((current * 100 / total))
    printf "\r${BLUE}[%d/%d] (%d%%) %s${NC}" "$current" "$total" "$progress" "$desc"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect operating system
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Install dependencies for Linux
install_linux_dependencies() {
    log_info "Detecting Linux distribution..."
    
    if command_exists apt; then
        log_info "Installing dependencies using apt..."
        sudo apt update
        sudo apt install -y nodejs npm git make g++ cmake build-essential curl
        
        # Install yarn
        if ! command_exists yarn; then
            log_info "Installing Yarn package manager..."
            curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
            echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
            sudo apt update && sudo apt install -y yarn
        fi
    elif command_exists yum; then
        log_info "Installing dependencies using yum..."
        sudo yum install -y nodejs npm git make gcc-c++ cmake curl
        
        # Install yarn
        if ! command_exists yarn; then
            log_info "Installing Yarn package manager..."
            curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
            sudo yum install -y yarn
        fi
    elif command_exists dnf; then
        log_info "Installing dependencies using dnf..."
        sudo dnf install -y nodejs npm git make gcc-c++ cmake curl
        
        # Install yarn
        if ! command_exists yarn; then
            log_info "Installing Yarn package manager..."
            curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
            sudo dnf install -y yarn
        fi
    elif command_exists pacman; then
        log_info "Installing dependencies using pacman..."
        sudo pacman -S --noconfirm nodejs npm git make gcc cmake curl yarn
    else
        log_error "Unsupported Linux distribution. Please install dependencies manually:"
        echo "  - Node.js (16+ recommended)"
        echo "  - npm"
        echo "  - git"
        echo "  - make"
        echo "  - g++ or gcc"
        echo "  - cmake"
        echo "  - yarn"
        exit 1
    fi
}

# Install dependencies for macOS
install_macos_dependencies() {
    log_info "Installing dependencies for macOS..."
    
    # Check for Homebrew
    if ! command_exists brew; then
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    # Install dependencies
    brew install node git cmake make yarn
}

# Install dependencies
install_dependencies() {
    local os=$(detect_os)
    
    log_info "Detected operating system: $os"
    
    case $os in
        "linux")
            install_linux_dependencies
            ;;
        "macos")
            install_macos_dependencies
            ;;
        "windows")
            log_error "Windows is not supported by this script. Please use manual installation or WSL."
            exit 1
            ;;
        *)
            log_error "Unsupported operating system. Please install dependencies manually."
            exit 1
            ;;
    esac
}

# Verify dependencies
verify_dependencies() {
    log_info "Verifying installed dependencies..."
    
    local missing_deps=()
    
    if ! command_exists node; then
        missing_deps+=("node")
    fi
    
    if ! command_exists npm; then
        missing_deps+=("npm")
    fi
    
    if ! command_exists yarn; then
        missing_deps+=("yarn")
    fi
    
    if ! command_exists git; then
        missing_deps+=("git")
    fi
    
    if ! command_exists make; then
        missing_deps+=("make")
    fi
    
    if ! command_exists cmake; then
        missing_deps+=("cmake")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        exit 1
    fi
    
    # Check Node.js version
    local node_version=$(node --version | sed 's/v//')
    local node_major=$(echo $node_version | cut -d. -f1)
    
    if [[ $node_major -lt 16 ]]; then
        log_warning "Node.js version $node_version detected. Version 16+ is recommended."
    else
        log_success "Node.js version $node_version is compatible."
    fi
    
    log_success "All dependencies are available."
}

# Main installation function
main() {
    echo "============================================================"
    echo -e "${GREEN}FreedomGPT Automatic Installation Script${NC}"
    echo "============================================================"
    echo
    
    local total_steps=8
    local current_step=0
    
    # Step 1: Check if we're in the right directory
    current_step=$((current_step + 1))
    show_progress $current_step $total_steps "Checking installation directory"
    echo
    
    if [[ ! -f "package.json" ]] || ! grep -q "freedomgpt" "package.json"; then
        log_error "Please run this script from the FreedomGPT repository root directory."
        exit 1
    fi
    log_success "Found FreedomGPT project directory."
    
    # Step 2: Install system dependencies
    current_step=$((current_step + 1))
    show_progress $current_step $total_steps "Installing system dependencies"
    echo
    
    install_dependencies
    log_success "System dependencies installed."
    
    # Step 3: Verify dependencies
    current_step=$((current_step + 1))
    show_progress $current_step $total_steps "Verifying dependencies"
    echo
    
    verify_dependencies
    
    # Step 4: Initialize git submodules
    current_step=$((current_step + 1))
    show_progress $current_step $total_steps "Initializing git submodules"
    echo
    
    if [[ -d ".git" ]]; then
        git submodule update --init --recursive
        log_success "Git submodules initialized."
    else
        log_warning "Not a git repository. Skipping submodule initialization."
    fi
    
    # Step 5: Install Node.js dependencies
    current_step=$((current_step + 1))
    show_progress $current_step $total_steps "Installing Node.js dependencies"
    echo
    
    yarn install
    log_success "Node.js dependencies installed."
    
    # Step 6: Build llama.cpp
    current_step=$((current_step + 1))
    show_progress $current_step $total_steps "Building llama.cpp server"
    echo
    
    if [[ -d "llama.cpp" ]]; then
        cd llama.cpp
        make server
        cd ..
        log_success "llama.cpp server built successfully."
    else
        log_warning "llama.cpp directory not found. Skipping llama.cpp build."
    fi
    
    # Step 7: Build application
    current_step=$((current_step + 1))
    show_progress $current_step $total_steps "Building application"
    echo
    
    yarn build
    log_success "Application built successfully."
    
    # Step 8: Final verification
    current_step=$((current_step + 1))
    show_progress $current_step $total_steps "Final verification"
    echo
    
    # Check if all necessary files are present
    local success=true
    
    if [[ -f "llama.cpp/server" ]]; then
        log_success "llama.cpp server binary found."
    else
        log_error "llama.cpp server binary not found."
        success=false
    fi
    
    if [[ -d "main" ]] && ([[ -d "renderer/out" ]] || [[ -d "renderer/.next" ]]); then
        log_success "Application build outputs found."
    else
        log_error "Application build outputs not found."
        success=false
    fi
    
    echo
    echo "============================================================"
    
    if [[ "$success" == true ]]; then
        log_success "🎉 Installation completed successfully!"
        echo
        echo -e "${GREEN}You can now start FreedomGPT with:${NC}"
        echo -e "${BLUE}  yarn start${NC}"
        echo
        echo -e "${GREEN}Or package the application with:${NC}"
        echo -e "${BLUE}  yarn make${NC}"
    else
        log_error "❌ Installation completed with errors."
        echo
        echo "Please check the error messages above and try again."
        exit 1
    fi
    
    echo "============================================================"
}

# Run main function
main "$@"