<#
.SYNOPSIS
    Chezmoi post-install script for Windows applications
.DESCRIPTION
    Automatically executed by chezmoi after applying dotfiles.
    Installs essential programs via winget with categorized packages.
.NOTES
    This script runs only once (run_once_ prefix)
    Author: MeekoLab
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue' # Continue on package errors

#region Helper Functions

function Write-Success {
    param([string]$Message)
    Write-Host "✓" -ForegroundColor Green -NoNewline
    Write-Host " $Message" -ForegroundColor White
}

function Write-WarningMsg {
    param([string]$Message)
    Write-Host "⚠" -ForegroundColor Yellow -NoNewline
    Write-Host " $Message" -ForegroundColor Yellow
}

function Write-ErrorMsg {
    param([string]$Message)
    Write-Host "✗" -ForegroundColor Red -NoNewline
    Write-Host " $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "==>" -ForegroundColor Cyan -NoNewline
    Write-Host " $Message" -ForegroundColor White
}

function Write-Category {
    param([string]$Category)
    Write-Host ""
    Write-Host "━━━ $Category ━━━" -ForegroundColor Magenta
}

function Test-WingetAvailable {
    $wingetCmd = Get-Command winget -ErrorAction SilentlyContinue
    if (-not $wingetCmd) {
        Write-ErrorMsg "winget is not available. Please install it first."
        return $false
    }
    return $true
}

function Install-WingetPackage {
    param(
        [string]$PackageId,
        [string]$Description
    )

    Write-Info "Installing $Description..."

    try {
        # Check if already installed
        $installed = winget list --id $PackageId --exact 2>&1
        if ($installed -match $PackageId -and $LASTEXITCODE -eq 0) {
            Write-Success "$Description is already installed"
            return $true
        }

        # Install package
        $output = winget install --id $PackageId --silent --accept-package-agreements --accept-source-agreements 2>&1

        if ($LASTEXITCODE -eq 0 -or $output -match "successfully installed") {
            Write-Success "$Description installed successfully"
            return $true
        }
        elseif ($output -match "already installed" -or $output -match "No applicable upgrade found") {
            Write-Success "$Description is already up to date"
            return $true
        }
        else {
            Write-WarningMsg "$Description installation returned code: $LASTEXITCODE"
            return $false
        }
    }
    catch {
        Write-ErrorMsg "Failed to install $Description : $_"
        return $false
    }
}

#endregion

#region Main Installation

Write-Info "Starting Windows application installation..."
Write-Host ""

# Verify winget is available
if (-not (Test-WingetAvailable)) {
    Write-ErrorMsg "Cannot proceed without winget. Exiting."
    exit 1
}

# Track installation results
$results = @{
    Success = @()
    Failed = @()
    Skipped = @()
}

# Define packages by category
$packageCategories = @{
    "Development Tools" = @(
        @{ Id = "Microsoft.PowerShell"; Name = "PowerShell Core" },
        @{ Id = "Microsoft.VisualStudioCode"; Name = "Visual Studio Code" },
        @{ Id = "Microsoft.WindowsTerminal"; Name = "Windows Terminal" },
        @{ Id = "wez.wezterm"; Name = "WezTerm" },
        @{ Id = "Neovim.Neovim"; Name = "Neovim" }
    )
    "Fonts" = @(
        @{ Id = "DEVCOM.JetBrainsMonoNerdFont"; Name = "JetBrains Mono Nerd Font" }
    )
    "Browsers" = @(
        @{ Id = "Google.Chrome"; Name = "Google Chrome" }
    )
    "Productivity" = @(
        @{ Id = "Notion.Notion"; Name = "Notion" }
    )
    "Communication" = @(
        @{ Id = "9NKSQGP7F2NH"; Name = "WhatsApp" },
        @{ Id = "Telegram.TelegramDesktop"; Name = "Telegram" },
        @{ Id = "Discord.Discord"; Name = "Discord" }
    )
    "Gaming" = @(
        @{ Id = "Valve.Steam"; Name = "Steam" },
        @{ Id = "EpicGames.EpicGamesLauncher"; Name = "Epic Games Launcher" }
    )
    "Hardware & Utilities" = @(
        @{ Id = "Logitech.GHUB"; Name = "Logitech G HUB" },
        @{ Id = "Rem0o.FanControl"; Name = "Fan Control" },
        @{ Id = "DeepCool.DeepCool"; Name = "DeepCool" }
    )
    "VR & Streaming" = @(
        @{ Id = "Meta.Oculus"; Name = "Meta Oculus" },
        @{ Id = "VirtualDesktop.Streamer"; Name = "Virtual Desktop Streamer" }
    )
    "System Tools" = @(
        @{ Id = "FilesCommunity.Files"; Name = "Files App" },
        @{ Id = "qBittorrent.qBittorrent"; Name = "qBittorrent" },
        @{ Id = "Starship.Starship"; Name = "Starship Prompt" }
    )
}

# Install packages by category
foreach ($category in $packageCategories.Keys) {
    Write-Category $category

    foreach ($package in $packageCategories[$category]) {
        $success = Install-WingetPackage -PackageId $package.Id -Description $package.Name

        if ($success) {
            $results.Success += $package.Name
        } else {
            $results.Failed += $package.Name
        }
    }
}

#endregion

#region Summary

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "          Installation Summary           " -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

if ($results.Success.Count -gt 0) {
    Write-Host "✓ Successfully installed: " -ForegroundColor Green -NoNewline
    Write-Host "$($results.Success.Count) packages" -ForegroundColor White
}

if ($results.Failed.Count -gt 0) {
    Write-Host "✗ Failed: " -ForegroundColor Red -NoNewline
    Write-Host "$($results.Failed.Count) packages" -ForegroundColor White
    Write-Host "  Failed packages:" -ForegroundColor Red
    foreach ($pkg in $results.Failed) {
        Write-Host "    - $pkg" -ForegroundColor Red
    }
}

if ($results.Skipped.Count -gt 0) {
    Write-Host "⊘ Skipped: " -ForegroundColor Yellow -NoNewline
    Write-Host "$($results.Skipped.Count) packages" -ForegroundColor White
}

Write-Host ""
Write-Host "All essential programs installation completed!" -ForegroundColor Green
Write-Host ""

# Exit with error code if there were failures
if ($results.Failed.Count -gt 0) {
    Write-WarningMsg "Some packages failed to install. You may want to install them manually."
    exit 1
}

#endregion
