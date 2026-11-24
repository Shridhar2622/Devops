# =============================================================================
# AUTOMATED TERRAFORM AWS DEPLOYMENT RUNNER (MUMBAI: ap-south-1)
# Reads .env, sets AWS credentials in PowerShell, and applies Terraform
# =============================================================================

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$envFile = Join-Path $projectRoot ".env"

if (-not (Test-Path $envFile)) {
    Write-Host "❌ Error: .env file not found at $envFile" -ForegroundColor Red
    exit 1
}

Write-Host "`n🔑 Loading AWS credentials from .env..." -ForegroundColor Cyan
Get-Content $envFile | Where-Object { $_ -match '=' -and -not $_.Trim().StartsWith('#') } | ForEach-Object {
    $parts = $_.Split('=', 2)
    $key = $parts[0].Trim()
    $val = $parts[1].Trim()
    [System.Environment]::SetEnvironmentVariable($key, $val, "Process")
}

Write-Host "✅ AWS credentials loaded!" -ForegroundColor Green
Write-Host "🌍 Region: $env:AWS_DEFAULT_REGION" -ForegroundColor Yellow

$tfDir = Join-Path $projectRoot "terraform-aws"
Set-Location $tfDir

Write-Host "`n🚀 Initializing Terraform AWS provider..." -ForegroundColor Cyan
& "C:\Terraform\terraform.exe" init

Write-Host "`n📦 Applying Terraform Plan to launch EC2 in Mumbai (ap-south-1)..." -ForegroundColor Cyan
& "C:\Terraform\terraform.exe" apply -auto-approve

Write-Host "`n🎉 Terraform deployment complete! Check the outputs above." -ForegroundColor Green
Set-Location $projectRoot
