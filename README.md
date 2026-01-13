# XP Link Controllers Package - Auto Installer

![XP Controllers Logo](https://raw.githubusercontent.com/EODBruz/XP-Link-Download-Auto-Installer-/main/logo.png)

An automated installation script for XP Link Controllers software and all required dependencies.

## 🎮 What is XP Link?

XP Link is a controller configuration software from **XP Controllers (Budd's Controllers)** that allows you to use various gaming controllers on your PC with advanced customization options.

**Official Website**: [www.xpcontrollers.com](https://www.xpcontrollers.com)

## ✨ Features

- **Fully Automated Installation** - One-click setup of all required components
- **Smart Detection** - Automatically detects what's already installed and skips unnecessary downloads
- **Latest Versions** - Always downloads the most recent releases from GitHub
- **Modern UI** - Clean, branded installer window with progress tracking
- **Silent Installation** - Installs components quietly in the background
- **Auto-Restart** - Automatically restarts your PC if required (only when HidHide is newly installed)

## 📦 What Gets Installed

The installer automatically downloads and installs:

1. **XP Link Program** - Main controller configuration software (installed to Desktop)
2. **ViGEmBus Driver** - Virtual gamepad driver for controller emulation
3. **HidHide** - Device hiding utility to prevent double inputs
4. **Python 3.13** - Required runtime environment

## 💻 System Requirements

- **OS**: Windows 10 or Windows 11
- **Permissions**: Administrator access (UAC prompt)
- **Internet**: Active internet connection
- **Disk Space**: Approximately 100 MB free space

## 🚀 Installation Instructions

### Method 1: Download and Run (Recommended)

1. Go to the [Releases](https://github.com/EODBruz/XP-Link-Download-Auto-Installer-/releases/latest) page
2. Download the latest `installer.bat` or PowerShell script
3. Right-click and select **"Run as Administrator"**
4. Follow the on-screen prompts

### Method 2: Direct PowerShell Execution

1. Download `XP Link Installer.ps1`
2. Right-click on the file and select **"Run with PowerShell"**
3. Click "Yes" when prompted for administrator access

### Method 3: One-Line Command (Advanced)

Open PowerShell as Administrator and run:

```powershell
iwr -useb https://raw.githubusercontent.com/EODBruz/XP-Link-Download-Auto-Installer-/main/XP%20Link%20Installer.ps1 | iex
```

## 🔧 How It Works

The installer performs these steps automatically:

1. **Check Administrator Privileges** - Requests elevation if needed
2. **Verify Existing Components** - Detects what's already installed
3. **Download Missing Components** - Fetches only what's needed from official sources
4. **Silent Installation** - Installs everything in the background
5. **Restart (if needed)** - Only restarts if HidHide was newly installed

## 📝 Installation Process Details

- **Check Phase**: Scans your system for existing installations
- **Download Phase**: Downloads missing components from GitHub releases
- **Install Phase**: Silently installs all required software
- **Completion**: Shows success message or restart countdown

### Restart Behavior

- **No restart needed**: If only XP Link, ViGEmBus, or Python were installed
- **Restart required**: Only if HidHide is newly installed (5-second countdown)

## ⚠️ Important Notes

- The installer **requires administrator privileges** to install drivers
- **HidHide installation** requires a system restart to function properly
- All components are downloaded from their **official GitHub repositories**
- The installer creates a log file at: `%TEMP%\xplink_install.log`

## 🐛 Troubleshooting

### Installer Won't Run
- Right-click and select "Run as Administrator"
- Check that PowerShell execution policy allows scripts
- Temporarily disable antivirus if it blocks the installer

### Download Fails
- Verify you have an active internet connection
- Check firewall settings aren't blocking GitHub
- Check the log file at `%TEMP%\xplink_install.log`

### Installation Fails
- Check the log file for detailed error messages
- Ensure you have sufficient disk space (~100 MB)
- Try running Windows Update to ensure your system is current

### Python Not Recognized After Install
- Restart your computer or open a new command prompt
- Python is added to PATH during installation but may require a restart

## 📄 Log Files

Installation logs are saved to: `%TEMP%\xplink_install.log`

Check this file if you encounter any issues during installation.

## 🤝 Credits

- **XP Link Software**: [XP Controllers (Budd's Controllers)](https://www.xpcontrollers.com)
- **Auto Installer**: Created by **EODBruz**
- **ViGEmBus**: [Nefarius Software Solutions](https://github.com/nefarius/ViGEmBus)
- **HidHide**: [Nefarius Software Solutions](https://github.com/nefarius/HidHide)
- **Python**: [Python Software Foundation](https://www.python.org)

## 📜 License

All rights to XP Link software belong to **XP Controllers (Budd's Controllers)**.

This installer script is provided as-is for convenience in setting up the XP Link environment.

## 🔗 Links

- **XP Controllers Website**: [www.xpcontrollers.com](https://www.xpcontrollers.com)
- **Report Issues**: [GitHub Issues](https://github.com/EODBruz/XP-Link-Download-Auto-Installer-/issues)
- **Latest Release**: [Releases Page](https://github.com/EODBruz/XP-Link-Download-Auto-Installer-/releases)

---

**Made with ❤️ by EODBruz**
