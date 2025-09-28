# FreedomGPT Installation Guide

This guide provides multiple ways to install FreedomGPT on your system.

## 🚀 Automatic Installation (Recommended)

The easiest way to install FreedomGPT is using our automated installation scripts that handle everything for you.

### Option 1: One-Command Installation

```bash
git clone --recursive https://github.com/ohmplatform/FreedomGPT.git freedom-gpt
cd freedom-gpt
node install.js
```

### Option 2: Platform-Specific Scripts

#### Linux/macOS
```bash
git clone --recursive https://github.com/ohmplatform/FreedomGPT.git freedom-gpt
cd freedom-gpt
chmod +x install.sh
./install.sh
```

#### Windows (Command Prompt)
```cmd
git clone --recursive https://github.com/ohmplatform/FreedomGPT.git freedom-gpt
cd freedom-gpt
install.bat
```

#### Windows (PowerShell)
```powershell
git clone --recursive https://github.com/ohmplatform/FreedomGPT.git freedom-gpt
cd freedom-gpt
.\install.bat
```

### Option 3: Using npm/yarn scripts

After cloning the repository:
```bash
git clone --recursive https://github.com/ohmplatform/FreedomGPT.git freedom-gpt
cd freedom-gpt
npm run setup
# or
yarn setup
```

## ✨ What the Automatic Installation Does

The automated installation scripts will:

1. **Detect your operating system** and install platform-specific dependencies
2. **Check for required tools** (Node.js, npm/yarn, git, make, cmake, etc.)
3. **Initialize git submodules** automatically
4. **Install Node.js dependencies** using your preferred package manager
5. **Build the llama.cpp server** binary for your platform
6. **Build the Electron application** with all optimizations
7. **Verify the installation** was successful
8. **Provide next steps** to start using FreedomGPT

## 🏃‍♂️ Quick Start After Installation

Once installation is complete, start FreedomGPT with:

```bash
yarn start
# or
npm start
```

## 📦 Building a Distribution Package

To create a distributable package:

```bash
yarn make
# or
npm run make
```

## 🛠️ Manual Installation (Advanced Users)

If you need to customize the installation or prefer to install manually, see the [manual installation instructions](README.md#manual-installation-advanced-users) in the README.

## ❗ Troubleshooting

### Common Issues

**Problem**: `git submodule` errors
- **Solution**: Make sure you cloned with `--recursive` flag, or run `git submodule update --init --recursive`

**Problem**: `node: command not found`
- **Solution**: Install Node.js from [nodejs.org](https://nodejs.org/)

**Problem**: `make: command not found` (Linux/macOS)
- **Solution**: Install build tools:
  - Linux: `sudo apt install build-essential` (Ubuntu/Debian) or equivalent
  - macOS: `xcode-select --install`

**Problem**: `cmake: command not found` (Windows)
- **Solution**: Install CMake from [cmake.org](https://cmake.org/download/)

**Problem**: Build fails with TypeScript errors
- **Solution**: The automated scripts handle this, but if building manually, ensure all dependencies are installed

### Getting Help

If you encounter issues:

1. Check the error messages carefully
2. Ensure all prerequisites are installed
3. Try the automated installation scripts
4. Check our [Discord community](https://discord.gg/h77wvJS4ga) for help
5. Open an issue on GitHub with detailed error information

## 🎯 System Requirements

### Minimum Requirements
- **OS**: Windows 10+, macOS 10.15+, or Linux (Ubuntu 18.04+, CentOS 7+)
- **RAM**: 4GB (8GB+ recommended for larger models)
- **Storage**: 10GB free space (more for model files)
- **CPU**: x64 processor with SSE4.1 support

### Recommended Requirements
- **RAM**: 16GB+ for optimal performance
- **Storage**: SSD with 50GB+ free space
- **CPU**: Modern multi-core processor
- **GPU**: Optional, but improves inference speed for supported models

---

**Ready to get started?** Use the automatic installation method above, and you'll be running FreedomGPT in just a few minutes! 🚀