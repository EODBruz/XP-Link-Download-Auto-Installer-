# ============================
# Hide PowerShell window
# ============================
$code = @'
[DllImport("kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
'@

$type = Add-Type -MemberDefinition $code -Name Win32 -Namespace Native -PassThru
$hwnd = $type::GetConsoleWindow()
$type::ShowWindow($hwnd, 0) | Out-Null

# ============================
# Admin check and elevation
# ============================
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

# ============================
# Force modern TLS
# ============================
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName presentationCore

# Global music player variable
$global:MusicPlayer = $null

$LogFile = "$env:TEMP\xplink_install.log"
Start-Transcript -Path $LogFile -Force | Out-Null

Write-Host "=== XP Link Installer Started ==="
Write-Host "Log file: $LogFile"

$Xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="XP Link Controllers Package Installer"
        Height="450" Width="450"
        WindowStartupLocation="CenterScreen"
        Background="Black"
        ResizeMode="NoResize"
        WindowStyle="None"
        BorderBrush="White"
        BorderThickness="2">
    <Grid Margin="15">
        <StackPanel VerticalAlignment="Center">
            <!-- XP Controllers Logo -->
            <Image x:Name="LogoImage"
                   Height="180"
                   Margin="0,0,0,15"
                   HorizontalAlignment="Center"
                   Stretch="Uniform"/>
            
            <TextBlock x:Name="TitleText"
                       Text="XP Link Controllers Package Installer"
                       Foreground="White"
                       FontSize="16"
                       FontWeight="Bold"
                       HorizontalAlignment="Center"
                       Margin="0,0,0,15"/>
            
            <TextBlock x:Name="StatusText"
                       Text="Preparing installer..."
                       Foreground="White"
                       FontSize="13"
                       HorizontalAlignment="Center"
                       Margin="0,0,0,8"/>
            
            <ProgressBar x:Name="ProgressBar"
                         Height="18"
                         Minimum="0"
                         Maximum="100"
                         Value="0"
                         Background="#222"
                         Foreground="White"/>
            
            <!-- ICE ICE BABY Banner -->
            <TextBlock x:Name="IceIceBabyText"
                       Text="ICE ICE BABY"
                       Foreground="Cyan"
                       FontSize="16"
                       FontWeight="Bold"
                       HorizontalAlignment="Center"
                       Margin="0,10,0,0"/>
            
            <TextBlock x:Name="CopyrightText"
                       Text="All Rights to XP Controllers (Budd's Controllers)"
                       Foreground="White"
                       FontSize="9"
                       HorizontalAlignment="Center"
                       Margin="0,12,0,0"/>
            
            <!-- Website URL above creator name -->
            <TextBlock x:Name="WebsiteText"
                       Text="www.xpcontrollers.com"
                       Foreground="Red"
                       FontSize="14"
                       FontWeight="Bold"
                       HorizontalAlignment="Center"
                       Margin="0,6,0,0"/>
            
            <TextBlock x:Name="CreatorText"
                       HorizontalAlignment="Center"
                       Margin="0,4,0,0">
                <Run Text="Auto Installer By " Foreground="#888" FontSize="10"/>
                <Run Text="EODBruz" Foreground="Red" FontSize="10" FontWeight="Bold"/>
            </TextBlock>
        </StackPanel>
    </Grid>
</Window>
"@

try {
    $Reader = New-Object System.Xml.XmlNodeReader ([xml]$Xaml)
    $Window = [Windows.Markup.XamlReader]::Load($Reader)
    Write-Host "Window loaded successfully"
} catch {
    Write-Host "ERROR: Failed to load window: $($_.Exception.Message)"
    throw
}

$StatusText  = $Window.FindName("StatusText")
$ProgressBar = $Window.FindName("ProgressBar")
$LogoImage   = $Window.FindName("LogoImage")
$IceIceBabyText = $Window.FindName("IceIceBabyText")

function Set-Status($text, $percent) {
    $Window.Dispatcher.Invoke([action]{
        $StatusText.Text = $text
        $ProgressBar.Value = $percent
    })
}

function Set-ProgressColor($color) {
    $Window.Dispatcher.Invoke([action]{
        if ($color -eq "Green") {
            $ProgressBar.Foreground = [System.Windows.Media.Brushes]::LimeGreen
        } elseif ($color -eq "Red") {
            $ProgressBar.Foreground = [System.Windows.Media.Brushes]::Red
        } else {
            $ProgressBar.Foreground = [System.Windows.Media.Brushes]::White
        }
    })
}

$temp = "$env:TEMP\XPLink"
New-Item -ItemType Directory -Force -Path $temp | Out-Null
Write-Host "Temp directory: $temp"

# ============================
# Detect OneDrive Desktop
# ============================
function Get-DesktopPath {
    $oneDriveDesktop = "$env:OneDrive\Desktop"
    $standardDesktop = "$env:USERPROFILE\Desktop"
    
    if ($env:OneDrive -and (Test-Path $oneDriveDesktop)) {
        Write-Host "OneDrive Desktop detected: $oneDriveDesktop"
        return $oneDriveDesktop
    } else {
        Write-Host "Standard Desktop detected: $standardDesktop"
        return $standardDesktop
    }
}

$DesktopPath = Get-DesktopPath
Write-Host "Desktop path: $DesktopPath"

# ============================
# XP Link GitHub settings
# ============================
$XPLinkRepo = "EODBruz/XP-Link-Download-Auto-Installer-"
$ProgramExe = "$DesktopPath\XP Link.exe"

$ViGEmExe   = "$temp\ViGEmBus.exe"
$HidHideExe = "$temp\HidHide.exe"
$PythonExe  = "$temp\Python.exe"

Write-Host "XP Link will be installed to: $ProgramExe"

# ============================
# Reliable downloader
# ============================
function DownloadFile($url, $out) {
    $ProgressPreference = 'SilentlyContinue'
    $wc = New-Object System.Net.WebClient
    $wc.Headers.Add("User-Agent", "Mozilla/5.0")
    $wc.DownloadFile($url, $out)

    if (!(Test-Path $out)) {
        throw "Download failed: $url"
    }
}

# ============================
# GitHub latest EXE finder
# ============================
function Get-LatestGitHubExe($repo) {
    $api = "https://api.github.com/repos/$repo/releases/latest"
    $wc = New-Object System.Net.WebClient
    $wc.Headers.Add("User-Agent", "Mozilla/5.0")

    $json = $wc.DownloadString($api) | ConvertFrom-Json
    $asset = $json.assets | Where-Object { $_.name -match "\.exe$" } | Select-Object -First 1

    if (!$asset) {
        throw "No EXE found for $repo"
    }

    return $asset.browser_download_url
}

# Use a timer to run the installation asynchronously
$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromMilliseconds(500)

$timer.Add_Tick({
    $timer.Stop()
    Write-Host "Timer triggered - starting background installation"
    
    # Run installation in background runspace
    $runspace = [runspacefactory]::CreateRunspace()
    $runspace.ApartmentState = "STA"
    $runspace.ThreadOptions = "ReuseThread"
    $runspace.Open()
    
    Write-Host "Runspace created and opened"
    
    # Pass all variables to runspace
    $runspace.SessionStateProxy.SetVariable("Window", $Window)
    $runspace.SessionStateProxy.SetVariable("StatusText", $StatusText)
    $runspace.SessionStateProxy.SetVariable("ProgressBar", $ProgressBar)
    $runspace.SessionStateProxy.SetVariable("temp", $temp)
    $runspace.SessionStateProxy.SetVariable("XPLinkRepo", $XPLinkRepo)
    $runspace.SessionStateProxy.SetVariable("ProgramExe", $ProgramExe)
    $runspace.SessionStateProxy.SetVariable("ViGEmExe", $ViGEmExe)
    $runspace.SessionStateProxy.SetVariable("HidHideExe", $HidHideExe)
    $runspace.SessionStateProxy.SetVariable("PythonExe", $PythonExe)
    $runspace.SessionStateProxy.SetVariable("LogFile", $LogFile)
    $runspace.SessionStateProxy.SetVariable("MusicPlayer", $global:MusicPlayer)
    
    Write-Host "Variables set in runspace"
    
    $ps = [powershell]::Create()
    $ps.Runspace = $runspace
    
    Write-Host "PowerShell instance created"
    
    [void]$ps.AddScript({
        Write-Host "=== Background installation script starting ==="
        
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        function Set-Status($text, $percent) {
            try {
                $Window.Dispatcher.Invoke([action]{
                    $StatusText.Text = $text
                    $ProgressBar.Value = $percent
                })
                Write-Host "Status: $text ($percent%)"
            } catch {
                Write-Host "ERROR updating status: $($_.Exception.Message)"
            }
        }
        
        function Set-ProgressColor($color) {
            try {
                $Window.Dispatcher.Invoke([action]{
                    if ($color -eq "Green") {
                        $ProgressBar.Foreground = [System.Windows.Media.Brushes]::LimeGreen
                    } elseif ($color -eq "Red") {
                        $ProgressBar.Foreground = [System.Windows.Media.Brushes]::Red
                    } else {
                        $ProgressBar.Foreground = [System.Windows.Media.Brushes]::White
                    }
                })
            } catch {
                Write-Host "ERROR updating color: $($_.Exception.Message)"
            }
        }
        
        function DownloadFile($url, $out) {
            Write-Host "Downloading: $url"
            Write-Host "To: $out"
            
            $wc = New-Object System.Net.WebClient
            $wc.Headers.Add("User-Agent", "Mozilla/5.0")
            $wc.Headers.Add("Accept", "*/*")
            
            $wc.DownloadFile($url, $out)
            if (!(Test-Path $out)) {
                throw "Download failed: $url"
            }
            
            $size = ((Get-Item $out).Length / 1MB).ToString('0.00')
            Write-Host "Downloaded: $out ($size MB)"
        }
        
        function Get-LatestGitHubExe($repo) {
            Write-Host "Fetching latest release: $repo"
            
            $api = "https://api.github.com/repos/$repo/releases/latest"
            $wc = New-Object System.Net.WebClient
            $wc.Headers.Add("User-Agent", "Mozilla/5.0")
            $json = $wc.DownloadString($api) | ConvertFrom-Json
            $asset = $json.assets | Where-Object { $_.name -match "\.exe$" } | Select-Object -First 1
            if (!$asset) { throw "No EXE found for $repo" }
            
            Write-Host "Found: $($asset.name)"
            return $asset.browser_download_url
        }
        
        try {
            Write-Host "Starting installation checks..."
            
            $installCount = 0
            $downloadCount = 0
            $hidHideWasInstalled = $false
            
            # Check what's already installed BEFORE downloading
            Set-Status "Checking installed components..." 5
            
            Write-Host "Installation path: $ProgramExe"
            
            $xpLinkInstalled = Test-Path $ProgramExe
            Write-Host "XP Link Check: $xpLinkInstalled"
            
            $vigemInstalled = Test-Path "C:\Program Files\Nefarius Software Solutions\ViGEm Bus Driver"
            Write-Host "ViGEmBus Check: $vigemInstalled"
            
            $hidHidePath = "$env:ProgramFiles\Nefarius Software Solutions\HidHide"
            $hidHideInstalled = Test-Path $hidHidePath
            Write-Host "HidHide Check: $hidHideInstalled"
            
            $pythonInstalled = $false
            try {
                $pythonVersion = & python --version 2>&1
                if ($pythonVersion -match "Python 3") {
                    $pythonInstalled = $true
                    Write-Host "Python Check: $pythonInstalled - Version: $pythonVersion"
                }
            } catch {
                Write-Host "Python Check: False - Not found in PATH"
            }
            
            # If everything is already installed, skip downloads
            if ($xpLinkInstalled -and $vigemInstalled -and $hidHideInstalled -and $pythonInstalled) {
                $checkmark = [char]0x2713
                Set-Status "All components up to date! $checkmark" 100
                Set-ProgressColor "Green"
                Write-Host "All components detected - skipping everything"
                Start-Sleep -Seconds 3
                
                # Stop Ice Ice Baby
                try {
                    if ($MusicPlayer) {
                        $MusicPlayer.Stop()
                        $MusicPlayer.Dispose()
                    }
                } catch {}
                
                $Window.Dispatcher.Invoke([action]{
                    $Window.Close()
                })
                return
            }
            
            # Build list of what needs to be installed
            $needsInstall = @()
            if (-not $xpLinkInstalled) { $needsInstall += "XP Link Program" }
            if (-not $vigemInstalled) { $needsInstall += "ViGEmBus" }
            if (-not $hidHideInstalled) { $needsInstall += "HidHide" }
            if (-not $pythonInstalled) { $needsInstall += "Python 3.13" }
            
            Write-Host "Components needed: $($needsInstall -join ', ')"
            
            # Download XP Link from GitHub releases
            if (-not $xpLinkInstalled) {
                Set-Status "Fetching latest XP Link..." 8
                Write-Host "Fetching latest XP Link from GitHub: $XPLinkRepo"
                
                try {
                    $XPLinkUrl = Get-LatestGitHubExe $XPLinkRepo
                    Write-Host "Latest XP Link URL: $XPLinkUrl"
                    
                    Set-Status "Downloading XP Link..." 10
                    DownloadFile $XPLinkUrl $ProgramExe
                    Write-Host "XP Link Program downloaded successfully!"
                    $downloadCount++
                }
                catch {
                    Write-Host "ERROR downloading XP Link Program: $($_.Exception.Message)"
                    throw "Failed to download XP Link Program from GitHub releases."
                }
            } else {
                Set-Status "XP Link already exists..." 10
                Write-Host "XP Link Program already exists, skipping download..."
            }
            
            if (-not $vigemInstalled) {
                Set-Status "Fetching latest ViGEmBus..." 20
                $ViGEmUrl = Get-LatestGitHubExe "nefarius/ViGEmBus"
                Set-Status "Downloading ViGEmBus..." 25
                DownloadFile $ViGEmUrl $ViGEmExe
                $downloadCount++
            } else {
                Set-Status "ViGEmBus already installed..." 25
                Write-Host "ViGEmBus already installed, skipping download..."
            }

            if (-not $hidHideInstalled) {
                Set-Status "Fetching latest HidHide..." 35
                $HidHideUrl = Get-LatestGitHubExe "nefarius/HidHide"
                Set-Status "Downloading HidHide..." 40
                DownloadFile $HidHideUrl $HidHideExe
                $downloadCount++
            } else {
                Set-Status "HidHide already installed..." 40
                Write-Host "HidHide already installed, skipping download..."
            }

            if (-not $pythonInstalled) {
                Write-Host "Python not found - will download and install"
                $PythonUrl = "https://www.python.org/ftp/python/3.13.1/python-3.13.1-amd64.exe"
                Set-Status "Downloading Python 3.13..." 55
                DownloadFile $PythonUrl $PythonExe
                Write-Host "Python download completed"
                $downloadCount++
            } else {
                Set-Status "Python already installed..." 55
                Write-Host "Python already installed, skipping download..."
            }

            Set-Status "Installing ViGEmBus..." 65
            
            if ($vigemInstalled) {
                Write-Host "ViGEmBus already installed, skipping installation..."
            } else {
                Write-Host "Installing ViGEmBus..."
                $p1 = Start-Process $ViGEmExe -ArgumentList "/quiet /norestart" -Wait -PassThru
                Write-Host "ViGEmBus exit code: $($p1.ExitCode)"
                
                if ($p1.ExitCode -notin 0,3010,1641) {
                    throw "ViGEmBus installation failed with exit code: $($p1.ExitCode)"
                }
                $installCount++
                Write-Host "ViGEmBus installation completed"
            }

            Set-Status "Installing HidHide..." 75
            
            if ($hidHideInstalled) {
                Write-Host "HidHide already installed, skipping installation..."
            } else {
                Write-Host "Installing HidHide..."
                $hidhideArgs = @(
                    "/quiet /norestart",
                    "/qn /norestart",
                    "/VERYSILENT /SP- /NORESTART",
                    "/S /NORESTART"
                )
                
                $installed = $false
                foreach ($arg in $hidhideArgs) {
                    try {
                        Write-Host "Trying HidHide with args: $arg"
                        $p2 = Start-Process -FilePath $HidHideExe -ArgumentList $arg -Wait -PassThru -WindowStyle Hidden
                        Write-Host "HidHide exit code: $($p2.ExitCode)"
                        
                        if ($p2.ExitCode -in 0,3010,1641) {
                            $installed = $true
                            break
                        }
                    } catch {
                        Write-Host "HidHide attempt failed: $($_.Exception.Message)"
                        continue
                    }
                }
                
                if (-not $installed) {
                    Write-Host "Silent install failed, launching interactive"
                    Start-Process -FilePath $HidHideExe -Wait
                }
                
                if (-not (Test-Path $hidHidePath)) {
                    throw "HidHide installation failed - installation directory not found"
                }
                $installCount++
                $hidHideWasInstalled = $true
                Write-Host "HidHide installation completed - restart will be required"
            }

            Set-Status "Installing Python 3.13..." 90
            
            if ($pythonInstalled) {
                Write-Host "Python already installed, skipping installation..."
            } else {
                Write-Host "Installing Python..."
                $p3 = Start-Process $PythonExe -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1 /norestart" -Wait -PassThru
                Write-Host "Python exit code: $($p3.ExitCode)"
                
                if ($p3.ExitCode -notin 0,3010,1641) {
                    Write-Host "Python installation returned exit code: $($p3.ExitCode)"
                    throw "Python installation failed with exit code: $($p3.ExitCode)"
                }
                
                Start-Sleep -Seconds 2
                try {
                    $pythonCheck = & python --version 2>&1
                    Write-Host "Python installed: $pythonCheck"
                } catch {
                    Write-Host "Warning: Python may require a restart to be accessible in PATH"
                }
                $installCount++
                Write-Host "Python installation completed"
            }

            Set-Status "Install complete!" 100
            Set-ProgressColor "Green"
            
            Write-Host "Installation complete - Downloaded: $downloadCount, Installed: $installCount"
            
            Start-Sleep -Seconds 2
            
            if (-not $hidHideWasInstalled) {
                Write-Host "HidHide was not installed - restart not needed"
                $Window.Dispatcher.Invoke([action]{
                    $StatusText.Text = "Installation complete! No restart needed."
                    $ProgressBar.Value = 100
                })
                Set-ProgressColor "Green"
                
                Start-Sleep -Seconds 3
                
                # Stop Ice Ice Baby
                try {
                    if ($MusicPlayer) {
                        $MusicPlayer.Stop()
                        $MusicPlayer.Dispose()
                    }
                } catch {}
                
                $Window.Dispatcher.Invoke([action]{
                    $Window.Close()
                })
                return
            }
            
            Write-Host "HidHide was installed - restart required"
            
            for ($i = 5; $i -ge 1; $i--) {
                $percent = ((5 - $i) / 5) * 100
                Set-Status "Restarting in $i seconds..." $percent
                Start-Sleep -Seconds 1
            }
            
            Set-Status "Restarting now..." 100
            
            # Stop Ice Ice Baby before restart
            try {
                if ($MusicPlayer) {
                    $MusicPlayer.Stop()
                    $MusicPlayer.Dispose()
                }
            } catch {}
            
            $Window.Dispatcher.Invoke([action]{
                $Window.Close()
            })
            
            Write-Host "Initiating restart..."
            Start-Process "shutdown.exe" -ArgumentList "/r /t 0 /f" -NoNewWindow -Wait
        }
        catch {
            Write-Host "FATAL ERROR: $($_.Exception.Message)"
            Write-Host "Stack trace: $($_.ScriptStackTrace)"
            
            $Window.Dispatcher.Invoke([action]{
                $errorMsg = $_.Exception.Message
                $StatusText.Text = "Installation failed!"
                $ProgressBar.Value = 100
            })
            Set-ProgressColor "Red"
            
            Start-Sleep -Seconds 2
            
            # Stop Ice Ice Baby on error
            try {
                if ($MusicPlayer) {
                    $MusicPlayer.Stop()
                    $MusicPlayer.Dispose()
                }
            } catch {}
            
            $Window.Dispatcher.Invoke([action]{
                [System.Windows.MessageBox]::Show("Installation failed:`n`n$errorMsg`n`nCheck the log at: $LogFile","Installer Error")
                $Window.Close()
            })
        }
        
        Write-Host "=== Background installation script ending ==="
    })
    
    Write-Host "Starting background PowerShell execution..."
    $asyncResult = $ps.BeginInvoke()
    Write-Host "Background execution started"
})

$Window.Add_Loaded({
    Write-Host "Window Loaded event fired"
    
    try {
        # Logo from GitHub repository
        $LogoURL = "https://raw.githubusercontent.com/EODBruz/XP-Link-Download-Auto-Installer-/main/logo.png"
        
        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("User-Agent", "Mozilla/5.0")
        $wc.Proxy = [System.Net.WebRequest]::GetSystemWebProxy()
        $wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
        
        $logoBytes = $wc.DownloadData($LogoURL)
        
        if ($logoBytes.Length -gt 0) {
            $bitmap = New-Object System.Windows.Media.Imaging.BitmapImage
            $bitmap.BeginInit()
            $bitmap.StreamSource = New-Object System.IO.MemoryStream(,$logoBytes)
            $bitmap.EndInit()
            $bitmap.Freeze()
            
            $LogoImage.Source = $bitmap
            Write-Host "Logo loaded successfully"
        } else {
            Write-Host "Logo download returned empty data"
        }
        
        # 🎵 ICE ICE BABY SURPRISE 🧊
        try {
            Write-Host "Loading Ice Ice Baby..."
            $musicUrl = "https://raw.githubusercontent.com/EODBruz/XP-Link-Download-Auto-Installer-/main/ice.wav"
            $musicPath = "$temp\ice.wav"
            
            $wc.DownloadFile($musicUrl, $musicPath)
            
            if (Test-Path $musicPath) {
                $fileSize = (Get-Item $musicPath).Length
                Write-Host "Music file downloaded: $fileSize bytes"
                
                if ($fileSize -gt 0) {
                    $global:MusicPlayer = New-Object System.Media.SoundPlayer($musicPath)
                    $global:MusicPlayer.Load()
                    $global:MusicPlayer.PlayLooping()
                    Write-Host "🧊 ICE ICE BABY PLAYING! 🧊"
                }
            }
        } catch {
            Write-Host "Music failed to load (continuing anyway): $($_.Exception.Message)"
            # Silent fail - installer continues without music
        }
        
    } catch {
        Write-Host "Logo failed to load: $($_.Exception.Message)"
    } finally {
        if ($wc) { $wc.Dispose() }
    }
    
    Write-Host "Starting timer for background installation"
    $timer.Start()
})

Write-Host "About to show window..."
$Window.ShowDialog() | Out-Null
Write-Host "Window closed"

Stop-Transcript
