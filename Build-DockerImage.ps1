#Requires -Version 7.0

<#
.SYNOPSIS
    Build and push copilot-api Docker image to Azure Container Registry.

.PARAMETER AcrName
    The name of the Azure Container Registry (without .azurecr.io).

.PARAMETER ImageName
    The Docker image name. Default: copilot-api.

.PARAMETER Tag
    The image tag. Default: latest.

.PARAMETER ResourceGroup
    The Azure resource group for the ACR (optional, for az acr login).

.EXAMPLE
    .\Build-DockerImage.ps1 -AcrName myregistry
    .\Build-DockerImage.ps1 -AcrName myregistry -Tag v1.0.0
    .\Build-DockerImage.ps1 -AcrName myregistry -ImageName copilot-api -Tag v1.0.0 -ResourceGroup my-rg
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$AcrName,

    [string]$ImageName = "copilot-api",

    [string]$Tag = "latest",

    [string]$ResourceGroup
)

$ErrorActionPreference = "Stop"

$acrLoginServer = "$AcrName.azurecr.io"
$fullImageName = "${acrLoginServer}/${ImageName}:${Tag}"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Copilot API - ACR Deploy" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "ACR:   $acrLoginServer" -ForegroundColor Yellow
Write-Host "Image: $fullImageName" -ForegroundColor Yellow
Write-Host ""

# Step 1: Login to ACR
Write-Host "[1/3] Logging in to ACR..." -ForegroundColor Green
if ($ResourceGroup) {
    az acr login --name $AcrName --resource-group $ResourceGroup
} else {
    az acr login --name $AcrName
}
if ($LASTEXITCODE -ne 0) { throw "Failed to login to ACR" }

# Step 2: Build the Docker image
Write-Host "[2/3] Building Docker image..." -ForegroundColor Green
docker build -t $fullImageName .
if ($LASTEXITCODE -ne 0) { throw "Failed to build Docker image" }

# Step 3: Push to ACR
Write-Host "[3/3] Pushing image to ACR..." -ForegroundColor Green
docker push $fullImageName
if ($LASTEXITCODE -ne 0) { throw "Failed to push image to ACR" }

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Build & Push Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Image pushed: $fullImageName" -ForegroundColor Yellow
