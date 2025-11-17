#Requires -Version 5.1
<#
.SYNOPSIS
    Install Git hooks for automatic versioning
.DESCRIPTION
    This script runs once after chezmoi applies dotfiles on Windows.
    It installs git hooks from the git-hooks directory.
.NOTES
    Author: MeekoLab
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

#region Helper Functions

function Write-Step {
    param([string]$Message)
    Write-Host "==> " -ForegroundColor Cyan -NoNewline
    Write-Host $Message
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ " -ForegroundColor Green -NoNewline
    Write-Host $Message
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠ " -ForegroundColor Yellow -NoNewline
    Write-Host $Message
}

function Write-ErrorMsg {
    param([string]$Message)
    Write-Host "✗ " -ForegroundColor Red -NoNewline
    Write-Host $Message
}

#endregion

#region Main Logic

try {
    # Find the dotfiles repository root
    # This script is run from chezmoi, so we need to find the source directory
    $dotfilesSource = if ($env:DOTFILES_DIR) {
        $env:DOTFILES_DIR
    } elseif (Test-Path "$env:USERPROFILE\.local\share\chezmoi") {
        "$env:USERPROFILE\.local\share\chezmoi"
    } elseif (Test-Path "$env:USERPROFILE\.dotfiles") {
        "$env:USERPROFILE\.dotfiles"
    } else {
        Write-ErrorMsg "Cannot find dotfiles source directory"
        exit 1
    }

    $gitHooksSource = Join-Path $dotfilesSource "git-hooks"
    $gitHooksDest = Join-Path $dotfilesSource ".git\hooks"

    Write-Step "Installing Git hooks for automatic versioning..."

    # Check if we're in a git repository
    if (-not (Test-Path (Join-Path $dotfilesSource ".git"))) {
        Write-Warning "Not a git repository, skipping git hooks installation"
        exit 0
    }

    # Check if git-hooks directory exists
    if (-not (Test-Path $gitHooksSource)) {
        Write-Warning "git-hooks directory not found at $gitHooksSource"
        exit 0
    }

    # Create hooks directory if it doesn't exist
    if (-not (Test-Path $gitHooksDest)) {
        New-Item -ItemType Directory -Path $gitHooksDest -Force | Out-Null
    }

    # Install each hook
    $installedCount = 0
    Get-ChildItem -Path $gitHooksSource -File | ForEach-Object {
        $hookName = $_.Name
        $destHook = Join-Path $gitHooksDest $hookName

        # Copy hook
        Copy-Item -Path $_.FullName -Destination $destHook -Force

        # Note: Git for Windows handles the execution of bash scripts
        # No need to set executable permission on Windows

        Write-Success "Installed hook: $hookName"
        $installedCount++
    }

    if ($installedCount -eq 0) {
        Write-Warning "No git hooks found to install"
    } else {
        Write-Host ""
        Write-Success "Git hooks installed successfully! ($installedCount hook(s))"
        Write-Host ""
        Write-Host "Automatic versioning enabled:" -ForegroundColor Cyan
        Write-Host "  • Version will auto-increment on 'git push'"

        $versionFile = Join-Path $dotfilesSource "VERSION"
        $currentVersion = if (Test-Path $versionFile) {
            Get-Content $versionFile -Raw | ForEach-Object { $_.Trim() }
        } else {
            "not found"
        }
        Write-Host "  • Current version: $currentVersion"
        Write-Host "  • To manually bump version: edit VERSION file"
        Write-Host ""
    }

    exit 0

} catch {
    Write-ErrorMsg "Failed to install git hooks: $_"
    exit 1
}

#endregion
