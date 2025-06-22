# setup.ps1
# part1: create config file
# part1: create config file
# part1: create config file
param (
    [string]$CLAIM_REWARD_ADDRESS
)

if (-not $CLAIM_REWARD_ADDRESS) {
    Write-Host "Error: Please provide the CLAIM_REWARD_ADDRESS parameter."
    exit 1
}

# Define the path for the config.yaml file
$configFilePath = "$HOME\cysic-verifier\config.yaml"

# Create the directory if it doesn't exist
if (-not (Test-Path -Path (Split-Path -Path $configFilePath -Parent))) {
    New-Item -ItemType Directory -Path (Split-Path -Path $configFilePath -Parent) -Force
}

# Define the content to be written to the config.yaml file
$content = @"
# Not Change
chain:
  # Not Change
  endpoint: "grpc-testnet.prover.xyz:80"
  # Not Change
  chain_id: "cysicmint_9001-1"
  # Not Change
  gas_coin: "CYS"
  # Not Change
  gas_price: 10
claim_reward_address: "$CLAIM_REWARD_ADDRESS"

server:
  # don't modify this
  cysic_endpoint: "https://ws-pre.prover.xyz"
  verify_endpoint: "http://verifier-rpc.prover.xyz:50052"
"@

# Write the content to the config.yaml file
Set-Content -Path $configFilePath -Value $content -Force
Write-Host "config.yaml has been created at $configFilePath"

$newPath = "$env:USERPROFILE\cysic-verifier"
$oldPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
# INFO: how to run: .\CreateConfig.ps1 -CLAIM_REWARD_ADDRESS "your_address_here"
# INFO: for example: .\CreateConfig.ps1 -CLAIM_REWARD_ADDRESS "0x1234567890abcdef1234567890abcdef12345678"

# Part2: Setup env PATH
# Part2: Setup env PATH
# Part2: Setup env PATH
if (-not ($oldPath -like "*$newPath*")) {
    $newPathValue = "$oldPath;$newPath"
    [Environment]::SetEnvironmentVariable("Path", $newPathValue, [EnvironmentVariableTarget]::User)
    Write-Host "Added $newPath to PATH."
} else {
    Write-Host "$newPath already exists in PATH."
}

# Output the new PATH for verification
[Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)

# Part 3: download verifier files
# Part 3: download verifier files
# Part 3: download verifier files
cd $env:USERPROFILE
New-Item -ItemType Directory -Force -Path "cysic-verifier"
Invoke-WebRequest -Uri "https://github.com/cysic-labs/cysic-phase3/releases/download/v1.0.0/verifier_win_x86_64.exe" -OutFile "cysic-verifier\verifier.exe"
Invoke-WebRequest -Uri "https://github.com/cysic-labs/cysic-phase3/releases/download/v1.0.0/run_win.ps1" -OutFile "cysic-verifier\start.ps1"
