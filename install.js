#!/usr/bin/env node

/**
 * FreedomGPT Automatic Installation Script
 * Cross-platform Node.js installer for FreedomGPT
 */

const fs = require('fs');
const path = require('path');
const { execSync, spawn } = require('child_process');
const os = require('os');

// Color codes for terminal output
const colors = {
    red: '\x1b[31m',
    green: '\x1b[32m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m',
    reset: '\x1b[0m'
};

// Logging functions
const log = {
    info: (msg) => console.log(`${colors.blue}[INFO]${colors.reset} ${msg}`),
    success: (msg) => console.log(`${colors.green}[SUCCESS]${colors.reset} ${msg}`),
    warning: (msg) => console.log(`${colors.yellow}[WARNING]${colors.reset} ${msg}`),
    error: (msg) => console.log(`${colors.red}[ERROR]${colors.reset} ${msg}`)
};

// Progress indicator
function showProgress(current, total, description) {
    const progress = Math.floor((current / total) * 100);
    process.stdout.write(`\r${colors.blue}[${current}/${total}] (${progress}%) ${description}${colors.reset}`);
}

// Check if command exists
function commandExists(command) {
    try {
        execSync(`which ${command}`, { stdio: 'ignore' });
        return true;
    } catch {
        try {
            execSync(`where ${command}`, { stdio: 'ignore' });
            return true;
        } catch {
            return false;
        }
    }
}

// Execute command with real-time output
function execCommand(command, options = {}) {
    return new Promise((resolve, reject) => {
        const child = spawn(command, { 
            shell: true, 
            stdio: options.silent ? 'pipe' : 'inherit',
            ...options 
        });
        
        child.on('close', (code) => {
            if (code === 0) {
                resolve();
            } else {
                reject(new Error(`Command failed with exit code ${code}: ${command}`));
            }
        });
    });
}

// Get package manager preference
function getPackageManager() {
    if (commandExists('yarn')) {
        return 'yarn';
    } else if (commandExists('npm')) {
        return 'npm';
    } else {
        throw new Error('Neither yarn nor npm is available');
    }
}

// Check Node.js version
function checkNodeVersion() {
    const version = process.version;
    const major = parseInt(version.slice(1).split('.')[0]);
    
    if (major < 16) {
        log.warning(`Node.js version ${version} detected. Version 16+ is recommended.`);
        return false;
    }
    
    log.success(`Node.js version ${version} is compatible.`);
    return true;
}

// Check if we're in the right directory
function checkProjectDirectory() {
    if (!fs.existsSync('package.json')) {
        throw new Error('package.json not found. Please run this script from the FreedomGPT repository root.');
    }
    
    const packageJson = JSON.parse(fs.readFileSync('package.json', 'utf8'));
    if (!packageJson.name || !packageJson.name.includes('freedomgpt')) {
        throw new Error('This doesn\'t appear to be the FreedomGPT project directory.');
    }
    
    log.success('Found FreedomGPT project directory.');
}

// Install system dependencies
async function installSystemDependencies() {
    const platform = os.platform();
    
    log.info(`Detected platform: ${platform}`);
    
    // Check for required tools
    const requiredTools = ['git', 'make'];
    const missingTools = requiredTools.filter(tool => !commandExists(tool));
    
    if (platform === 'win32') {
        requiredTools.push('cmake');
        if (!commandExists('cmake')) {
            missingTools.push('cmake');
        }
    }
    
    if (missingTools.length > 0) {
        log.error(`Missing required tools: ${missingTools.join(', ')}`);
        
        if (platform === 'darwin') {
            log.info('On macOS, you can install missing tools with Homebrew:');
            log.info(`  brew install ${missingTools.join(' ')}`);
        } else if (platform === 'linux') {
            log.info('On Linux, you can install missing tools with your package manager:');
            log.info(`  sudo apt install ${missingTools.join(' ')} # Debian/Ubuntu`);
            log.info(`  sudo yum install ${missingTools.join(' ')} # CentOS/RHEL`);
        } else if (platform === 'win32') {
            log.info('On Windows, please install the missing tools:');
            if (missingTools.includes('cmake')) {
                log.info('  - CMake: https://cmake.org/download/');
            }
            if (missingTools.includes('git')) {
                log.info('  - Git: https://git-scm.com/download/win');
            }
        }
        
        throw new Error('Please install missing tools and try again.');
    }
    
    log.success('All required system tools are available.');
}

// Initialize git submodules
async function initializeSubmodules() {
    if (!fs.existsSync('.git')) {
        log.warning('Not a git repository. Skipping submodule initialization.');
        return;
    }
    
    try {
        await execCommand('git submodule update --init --recursive');
        log.success('Git submodules initialized.');
    } catch (error) {
        log.warning('Failed to initialize git submodules. Some features may not work.');
    }
}

// Install Node.js dependencies
async function installNodeDependencies() {
    const packageManager = getPackageManager();
    log.info(`Using package manager: ${packageManager}`);
    
    await execCommand(`${packageManager} install`);
    log.success('Node.js dependencies installed.');
}

// Build llama.cpp
async function buildLlamaCpp() {
    if (!fs.existsSync('llama.cpp')) {
        log.warning('llama.cpp directory not found. Skipping llama.cpp build.');
        return;
    }
    
    const platform = os.platform();
    
    try {
        process.chdir('llama.cpp');
        
        if (platform === 'win32') {
            await execCommand('cmake .');
            await execCommand('cmake --build . --config Release');
        } else {
            await execCommand('make server');
        }
        
        process.chdir('..');
        log.success('llama.cpp server built successfully.');
    } catch (error) {
        process.chdir('..');
        throw new Error(`Failed to build llama.cpp: ${error.message}`);
    }
}

// Build application
async function buildApplication() {
    const packageManager = getPackageManager();
    
    try {
        await execCommand(`${packageManager} build`);
        log.success('Application built successfully.');
    } catch (error) {
        throw new Error(`Failed to build application: ${error.message}`);
    }
}

// Verify installation
function verifyInstallation() {
    let success = true;
    
    // Check for llama.cpp server binary
    const platform = os.platform();
    let serverBinary;
    
    if (platform === 'win32') {
        serverBinary = fs.existsSync('llama.cpp/bin/Release/server.exe') || 
                      fs.existsSync('llama.cpp/server.exe');
    } else {
        serverBinary = fs.existsSync('llama.cpp/server');
    }
    
    if (serverBinary) {
        log.success('llama.cpp server binary found.');
    } else {
        log.error('llama.cpp server binary not found.');
        success = false;
    }
    
    // Check for application build outputs
    if (fs.existsSync('main') && (fs.existsSync('renderer/out') || fs.existsSync('renderer/.next'))) {
        log.success('Application build outputs found.');
    } else {
        log.error('Application build outputs not found.');
        success = false;
    }
    
    return success;
}

// Main installation function
async function main() {
    console.log('============================================================');
    console.log(`${colors.green}FreedomGPT Automatic Installation Script${colors.reset}`);
    console.log('============================================================');
    console.log();
    
    const totalSteps = 8;
    let currentStep = 0;
    
    try {
        // Step 1: Check project directory
        currentStep++;
        showProgress(currentStep, totalSteps, 'Checking project directory');
        console.log();
        checkProjectDirectory();
        
        // Step 2: Check Node.js version
        currentStep++;
        showProgress(currentStep, totalSteps, 'Checking Node.js version');
        console.log();
        checkNodeVersion();
        
        // Step 3: Check system dependencies
        currentStep++;
        showProgress(currentStep, totalSteps, 'Checking system dependencies');
        console.log();
        await installSystemDependencies();
        
        // Step 4: Initialize git submodules
        currentStep++;
        showProgress(currentStep, totalSteps, 'Initializing git submodules');
        console.log();
        await initializeSubmodules();
        
        // Step 5: Install Node.js dependencies
        currentStep++;
        showProgress(currentStep, totalSteps, 'Installing Node.js dependencies');
        console.log();
        await installNodeDependencies();
        
        // Step 6: Build llama.cpp
        currentStep++;
        showProgress(currentStep, totalSteps, 'Building llama.cpp server');
        console.log();
        await buildLlamaCpp();
        
        // Step 7: Build application
        currentStep++;
        showProgress(currentStep, totalSteps, 'Building application');
        console.log();
        await buildApplication();
        
        // Step 8: Verify installation
        currentStep++;
        showProgress(currentStep, totalSteps, 'Verifying installation');
        console.log();
        const success = verifyInstallation();
        
        console.log();
        console.log('============================================================');
        
        if (success) {
            log.success('🎉 Installation completed successfully!');
            console.log();
            console.log(`${colors.green}You can now start FreedomGPT with:${colors.reset}`);
            console.log(`${colors.blue}  ${getPackageManager()} start${colors.reset}`);
            console.log();
            console.log(`${colors.green}Or package the application with:${colors.reset}`);
            console.log(`${colors.blue}  ${getPackageManager()} make${colors.reset}`);
        } else {
            log.error('❌ Installation completed with errors.');
            console.log();
            console.log('Please check the error messages above and try again.');
            process.exit(1);
        }
        
        console.log('============================================================');
        
    } catch (error) {
        console.log();
        log.error(`Installation failed: ${error.message}`);
        process.exit(1);
    }
}

// Handle Ctrl+C gracefully
process.on('SIGINT', () => {
    console.log('\n\nInstallation interrupted by user.');
    process.exit(1);
});

// Run main function
if (require.main === module) {
    main();
}