$ErrorActionPreference = 'Stop'

$vmName = 'Ubuntu-Samba-Host'
$vmPath = 'D:\VMs\Ubuntu-Samba-Host'
$isoPath = 'D:\VMs\ubuntu-22.04.5-live-server-amd64.iso'
$memory = 4096MB
$cpu = 2
$startupMemory = 4096MB
$minMemory = 2048MB
$switchName = 'Default Switch'

New-Item -Path $vmPath -ItemType Directory -Force | Out-Null

if (-not (Test-Path $isoPath)) {
    throw "ISO do Ubuntu nao encontrado em $isoPath. Baixe antes: https://releases.ubuntu.com/jammy/ubuntu-22.04.5-live-server-amd64.iso"
}

if (Get-VM -Name $vmName -ErrorAction SilentlyContinue) {
    Write-Host "VM ja existe: $vmName"
    exit 0
}

New-VM -Name $vmName -MemoryStartupBytes $startupMemory -Generation 2 -SwitchName $switchName -Path $vmPath | Out-Null
Set-VM -Name $vmName -ProcessorCount $cpu -DynamicMemory -MemoryMinimumBytes $minMemory -MemoryMaximumBytes $memory -MemoryStartupBytes $startupMemory | Out-Null
Set-VMProcessor -VMName $vmName -ExposeVirtualizationExtensions $true | Out-Null

# Cria disco novo e monta o ISO
$diskPath = Join-Path $vmPath "$vmName.vhdx"
Remove-Item -Path $diskPath -ErrorAction SilentlyContinue
New-VHD -Path $diskPath -SizeBytes 60GB -Dynamic | Out-Null
Add-VMHardDiskDrive -VMName $vmName -Path $diskPath | Out-Null

$dvdController = Get-VMDvdDrive -VMName $vmName -ErrorAction SilentlyContinue
if (-not $dvdController) { Add-VMDvdDrive -VMName $vmName | Out-Null }
Set-VMDvdDrive -VMName $vmName -Path $isoPath | Out-Null

Start-VM -Name $vmName

Write-Host "VM criada e iniciada: $vmName"
Write-Host "Acesse a console da VM e instale Ubuntu Server 22.04 LTS."
Write-Host "Depois, rode na VM:"
Write-Host "sudo apt update && sudo apt install -y docker.io docker-compose-plugin"
Write-Host "sudo usermod -aG docker \$USER"
Write-Host "newgrp docker"
Write-Host "docker pull dperson/samba:latest"
Write-Host "sudo mkdir -p /dados/ti && sudo chown -R 1000:1000 /dados/ti"
Write-Host "docker run -d --name samba -p 445:445 -v /dados:/dados dperson/samba:latest -u '49684;Senha@123' -s 'TI;/dados/ti;yes;no;no;user'"
