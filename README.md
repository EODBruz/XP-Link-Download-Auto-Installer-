╔═══════════════════════════════════════════════════════════════╗
║                    XP Link Auto Installer                     ║
║                    www.xpcontrollers.com                      ║
╚═══════════════════════════════════════════════════════════════╝

INSTALLATION INSTRUCTIONS:
==========================
1. Extract ALL files to the same folder
2. Double-click "Installer.bat"
3. Click "Yes" when Windows asks for administrator permission
4. The installer will automatically:
   - Check what's already installed
   - Download only missing components
   - Install everything silently in the background
   - Restart only if HidHide driver was installed

SYSTEM REQUIREMENTS:
====================
- Windows 10 or Windows 11
- Active internet connection
- Administrator access (UAC prompt)
- Approximately 100 MB free disk space

WHAT GETS INSTALLED:
====================
✓ XP Link Program
  → Installed to: Desktop\XP Link.exe
  → Main controller configuration software

✓ ViGEmBus Driver
  → Virtual gamepad driver
  → Allows controller emulation
  → No restart required

✓ HidHide Driver  
  → Device hiding utility
  → Prevents controller conflicts
  → **RESTART REQUIRED** (only if newly installed)

✓ Python 3.13
  → Required dependency for XP Link
  → Installed system-wide with PATH
  → No restart required

HOW THE INSTALLER WORKS:
=========================
The PowerShell script performs these steps:

1. VERIFICATION PHASE
   - Checks if you have administrator rights
   - Elevates automatically if needed
   - Verifies what components are already installed

2. SMART DOWNLOAD PHASE
   - Downloads ONLY missing components
   - XP Link: from Dropbox (private link)
   - ViGEmBus: Latest from GitHub releases
   - HidHide: Latest from GitHub releases
   - Python: Official Python.org installer

3. SILENT INSTALLATION PHASE
   - Installs all components without user interaction
   - Skips components that are already installed
   - Shows progress in real-time GUI window

4. COMPLETION
   - If HidHide was installed: Automatic restart in 5 seconds
   - If only other components: No restart needed
   - All installations logged to: %TEMP%\xplink_install.log

FEATURES:
=========
✓ Fully automated installation
✓ Smart detection - skips already installed components
✓ No unnecessary restarts
✓ Clean, modern GUI with progress tracking
✓ Detailed logging for troubleshooting
✓ Downloads latest versions from official sources

TROUBLESHOOTING:
================
If installation fails:
1. Check the log file at: C:\Users\[YourName]\AppData\Local\Temp\xplink_install.log
2. Ensure you have stable internet connection
3. Verify you clicked "Yes" on the UAC prompt
4. Try running as administrator manually (right-click Installer.bat)

If Windows Defender blocks the installer:
- Click "More info" → "Run anyway"
- This is normal for unsigned PowerShell scripts

SUPPORT:
========
For bugs, issues, or questions:
- Contact: EODBruz / XP Controllers
- Website: www.xpcontrollers.com

╔═══════════════════════════════════════════════════════════════╗
║           All Rights To XP Controllers                        ║
║           (Budd's Controllers)                                ║
║                                                               ║
║   Auto Installer Created By: EODBruz                          ║
║   Made to simplify installing programs silently               ║
╚═══════════════════════════════════════════════════════════════╝
