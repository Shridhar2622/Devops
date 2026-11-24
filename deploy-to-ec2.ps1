# =============================================================================
# DOODLE-DASH AWS EC2 CONTAINER DEPLOYMENT SCRIPT
# Automatically detects EC2 IP or accepts it as parameter: .\deploy-to-ec2.ps1 <IP>
# =============================================================================
param(
    [string]$ec2Ip = ""
)

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectRoot

# Automatically read Public IP from Terraform state if not manually passed
if (-not $ec2Ip) {
    $tfState = Join-Path $projectRoot "terraform-aws\terraform.tfstate"
    if (Test-Path $tfState) {
        try {
            $state = Get-Content $tfState | ConvertFrom-Json
            $ec2Ip = $statwhe.outputs.ec2_public_ip.value
        }
        catch {}
    }
}   

if (-not $ec2Ip) {
    $ec2Ip = "3.108.58.68"
}

$keyFile = Join-Path $projectRoot "shridhar_key.pem"

Write-Host "`n🚀 Packaging and uploading Doodle-Dash to AWS EC2 ($ec2Ip)..." -ForegroundColor Cyan

tar.exe -czf upload.tar.gz --exclude="node_modules" --exclude=".git" --exclude="dist" --exclude=".terraform" backend frontend nagios docker-compose.yml
scp.exe -i $keyFile -o StrictHostKeyChecking=no upload.tar.gz ubuntu@${ec2Ip}:~/letsdraw.tar.gz
Remove-Item upload.tar.gz -Force

Write-Host "`n⏳ Building Docker containers on EC2 (Frontend, Backend, Nagios)..." -ForegroundColor Cyan
ssh.exe -i $keyFile -o StrictHostKeyChecking=no ubuntu@$ec2Ip "mkdir -p ~/letsdraw && tar -xzf ~/letsdraw.tar.gz -C ~/letsdraw && rm ~/letsdraw.tar.gz && cd ~/letsdraw && docker compose up -d --build"

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host "🎉 DOODLE-DASH IS LIVE ON AWS CLOUD! 🎉" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "🎮 Game Frontend:   http://${ec2Ip}:3001" -ForegroundColor Yellow
Write-Host "⚙️  Backend Health:  http://${ec2Ip}:5000/health" -ForegroundColor Yellow
Write-Host "📊 Nagios Monitor:  http://${ec2Ip}:8085/nagios/" -ForegroundColor Yellow
Write-Host "🔐 Nagios Login:    User: nagiosadmin | Pass: nagiosadmin" -ForegroundColor Gray
Write-Host "==========================================================`n" -ForegroundColor Cyan
