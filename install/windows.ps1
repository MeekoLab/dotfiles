#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Windows 11 dotfiles installer for MeekoLab
.DESCRIPTION
    Automatically installs winget, essential dependencies (git, chezmoi, curl) and initializes dotfiles
    Run from PowerShell (Administrator): irm https://raw.githubusercontent.com/MeekoLab/dotfiles/main/install/windows.ps1 | iex
.NOTES
    Author: MeekoLab
    Requires: PowerShell 5.1+ and Administrator privileges
#>

[CmdletBinding()]
param(
    [string]$DotfilesRepo = "https://github.com/MeekoLab/dotfiles",
    [switch]$SkipChezmoi
)

# Strict mode for better error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

#region Helper Functions

function Write-Banner {
    Write-Host @'
+-------------------------------------------------------+
| $$\      $$\                     $$\                  |
| $$$\    $$$ |                    $$ |                 |
| $$$$\  $$$$ | $$$$$$\   $$$$$$\  $$ |  $$\  $$$$$$\   |
| $$\$$\$$ $$ |$$  __$$\ $$  __$$\ $$ | $$  |$$  __$$\  |
| $$ \$$$  $$ |$$$$$$$$ |$$$$$$$$ |$$$$$$  / $$ /  $$ | |
| $$ |\$  /$$ |$$   ____|$$   ____|$$  _$$<  $$ |  $$ | |
| $$ | \_/ $$ |\$$$$$$$\ \$$$$$$$\ $$ | \$$\ \$$$$$$  | |
| \__|     \__| \_______| \_______|\__|  \__| \______/  |
|                                                       |
|                  @MeekoLab/dotfiles                   |
+-------------------------------------------------------+
'@ -ForegroundColor Magenta
    Write-Host ""
}

function Write-Step {
    param([string]$Message)
    Write-Host "==>" -ForegroundColor Cyan -NoNewline
    Write-Host " $Message" -ForegroundColor White
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓" -ForegroundColor Green -NoNewline
    Write-Host " $Message" -ForegroundColor White
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠" -ForegroundColor Yellow -NoNewline
    Write-Host " $Message" -ForegroundColor Yellow
}

function Write-ErrorMsg {
    param([string]$Message)
    Write-Host "✗" -ForegroundColor Red -NoNewline
    Write-Host " $Message" -ForegroundColor Red
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-CommandExists {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

function Install-WinGet {
    Write-Step "Checking winget installation..."

    if (Test-CommandExists "winget") {
        Write-Success "winget is already installed"
        return
    }

    Write-Step "Installing winget (App Installer)..."

    try {
        # Method 1: Try installing via Microsoft Store
        $progressPreference = 'SilentlyContinue'

        # Download and install App Installer from Microsoft Store
        $releases = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
        $downloadUrl = ((Invoke-RestMethod $releases).assets | Where-Object { $_.name -match "msixbundle" }).browser_download_url

        if ($downloadUrl) {
            $downloadPath = "$env:TEMP\Microsoft.DesktopAppInstaller.msixbundle"
            Write-Step "Downloading winget from: $downloadUrl"
            Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath

            Write-Step "Installing winget package..."
            Add-AppxPackage -Path $downloadPath

            Remove-Item $downloadPath -ErrorAction SilentlyContinue

            # Refresh PATH
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

            Write-Success "winget installed successfully"
        } else {
            throw "Could not find winget download URL"
        }
    }
    catch {
        Write-ErrorMsg "Failed to install winget automatically"
        Write-Host "Please install winget manually from: https://aka.ms/getwinget" -ForegroundColor Yellow
        Write-Host "Error: $_" -ForegroundColor Red
        exit 1
    }

    # Verify installation
    Start-Sleep -Seconds 2
    if (-not (Test-CommandExists "winget")) {
        Write-ErrorMsg "winget installation verification failed"
        exit 1
    }
}

function Install-Package {
    param(
        [string]$PackageId,
        [string]$DisplayName
    )

    Write-Step "Installing $DisplayName..."

    try {
        $result = winget install --id $PackageId --silent --accept-package-agreements --accept-source-agreements 2>&1

        if ($LASTEXITCODE -eq 0 -or $result -match "successfully installed" -or $result -match "already installed") {
            Write-Success "$DisplayName installed successfully"
            return $true
        } else {
            Write-Warning "$DisplayName installation returned code: $LASTEXITCODE"
            return $false
        }
    }
    catch {
        Write-ErrorMsg "Failed to install $DisplayName : $_"
        return $false
    }
}

function Update-EnvironmentPath {
    Write-Step "Refreshing environment PATH..."

    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machinePath;$userPath"

    Write-Success "PATH refreshed"
}

function Initialize-Chezmoi {
    param([string]$Repository)

    Write-Step "Initializing chezmoi with dotfiles..."

    try {
        $chezmoiPath = Get-Command chezmoi -ErrorAction SilentlyContinue
        if (-not $chezmoiPath) {
            Update-EnvironmentPath
            Start-Sleep -Seconds 2
        }

        # Initialize and apply dotfiles
        $output = chezmoi init --apply $Repository 2>&1

        if ($LASTEXITCODE -eq 0) {
            Write-Success "Dotfiles initialized successfully"
            Write-Host ""
            Write-Host "Your dotfiles have been applied!" -ForegroundColor Green
            Write-Host "Location: $env:USERPROFILE\.local\share\chezmoi" -ForegroundColor Cyan
        } else {
            Write-Warning "Chezmoi initialization completed with warnings"
            Write-Host $output
        }
    }
    catch {
        Write-ErrorMsg "Failed to initialize chezmoi: $_"
        Write-Host "You can manually run: chezmoi init --apply $Repository" -ForegroundColor Yellow
    }
}

#endregion

#region Main Installation

try {
    Clear-Host
    Write-Banner

    # Check administrator privileges
    Write-Step "Checking administrator privileges..."
    if (-not (Test-Administrator)) {
        Write-ErrorMsg "This script requires Administrator privileges"
        Write-Host "Please run PowerShell as Administrator and try again" -ForegroundColor Yellow
        exit 1
    }
    Write-Success "Running with Administrator privileges"
    Write-Host ""

    # Install winget if needed
    Install-WinGet
    Write-Host ""

    # Install essential dependencies
    Write-Step "Installing essential dependencies..."
    Write-Host ""

    $dependencies = @(
        @{ Id = "Git.Git"; Name = "Git" },
        @{ Id = "twpayne.chezmoi"; Name = "chezmoi" },
        @{ Id = "cURL.cURL"; Name = "curl" }
    )

    $failedPackages = @()
    foreach ($dep in $dependencies) {
        $success = Install-Package -PackageId $dep.Id -DisplayName $dep.Name
        if (-not $success) {
            $failedPackages += $dep.Name
        }
    }

    Write-Host ""

    if ($failedPackages.Count -gt 0) {
        Write-Warning "Some packages failed to install: $($failedPackages -join ', ')"
        Write-Host "You may need to install them manually" -ForegroundColor Yellow
    }

    # Update PATH to include newly installed tools
    Update-EnvironmentPath
    Write-Host ""

    # Initialize chezmoi with dotfiles
    if (-not $SkipChezmoi) {
        Initialize-Chezmoi -Repository $DotfilesRepo
    } else {
        Write-Warning "Skipping chezmoi initialization (SkipChezmoi flag set)"
        Write-Host "Run manually: chezmoi init --apply $DotfilesRepo" -ForegroundColor Cyan
    }

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  Installation completed successfully!  " -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Restart your terminal to load new PATH" -ForegroundColor White
    Write-Host "  2. Additional packages will be installed via chezmoi scripts" -ForegroundColor White
    Write-Host "  3. Edit dotfiles: chezmoi edit <file>" -ForegroundColor White
    Write-Host "  4. Apply changes: chezmoi apply" -ForegroundColor White
    Write-Host ""

}
catch {
    Write-Host ""
    Write-ErrorMsg "Installation failed with error:"
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    exit 1
}

#endregion
