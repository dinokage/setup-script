# Ensure script runs as administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Run this script as Administrator!" -ForegroundColor Red
    exit
}

# Set execution policy for the session
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Enable WSL2 and update system
Write-Host "Enabling necessary Windows features and installing WSL2..."

# Enable Windows features required for WSL2
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Download and install the WSL2 kernel update
Write-Host "Installing WSL2 kernel update..." -ForegroundColor Yellow
$wslUpdateUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
$wslUpdateInstaller = "$env:TEMP\wsl_update_x64.msi"
Invoke-WebRequest -Uri $wslUpdateUrl -OutFile $wslUpdateInstaller
Start-Process msiexec.exe -ArgumentList "/i $wslUpdateInstaller /quiet /norestart" -Wait

# Set WSL2 as the default version
wsl --set-default-version 2

# Install Ubuntu for WSL2
Write-Host "Installing Ubuntu for WSL2..." -ForegroundColor Yellow
wsl --install -d Ubuntu-24.04

# Install Chocolatey package manager
Write-Host "Installing Chocolatey package manager..." -ForegroundColor Yellow
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Refresh environment to include choco
$env:Path += ";$env:ProgramData\chocolatey\bin"

# Install development tools via Chocolatey
Write-Host "Installing essential development tools via Chocolatey..." -ForegroundColor Yellow
choco install -y git vscode nodejs-lts python golang rustup docker-compose mkcert

# Install Elixir and Erlang via Chocolatey
Write-Host "Installing Elixir and Erlang..." -ForegroundColor Yellow
choco install -y elixir

# Set up Rust environment
Write-Host "Configuring Rust environment..." -ForegroundColor Yellow
rustup-init -y

# Install global npm packages for Next.js development
Write-Host "Installing global npm packages for Next.js development..." -ForegroundColor Yellow
npm install -g create-next-app pnpm yarn

# Install PostgreSQL and Redis (optional for full-stack development)
Write-Host "Installing PostgreSQL and Redis for backend support..." -ForegroundColor Yellow
choco install -y postgresql redis

# Install Docker Desktop
Write-Host "Installing Docker Desktop..." -ForegroundColor Yellow
choco install -y docker-desktop
Start-Process -Wait -FilePath "C:\Program Files\Docker\Docker\Docker Desktop.exe"
[System.Threading.Thread]::Sleep(5000)

# Configure system paths and environment variables
Write-Host "Configuring system paths and environment variables..." -ForegroundColor Yellow
[System.Environment]::SetEnvironmentVariable("GO111MODULE", "on", [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("PATH", $env:Path + ";C:\Program Files\Git\bin", [System.EnvironmentVariableTarget]::Machine)

# Final steps
Write-Host "Setup complete! Please restart your system to finalize installation." -ForegroundColor Green
