# Dev Docker management script for Bessie
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("start", "stop", "restart", "logs", "status", "clean")]
    [string]$Action
)

$ErrorActionPreference = "Stop"

Write-Host "Bessie Docker Manager" -ForegroundColor Green
Write-Host "Action: $Action" -ForegroundColor Yellow

switch ($Action) {
    "start" {
        Write-Host "Starting Bessie development environment..." -ForegroundColor Blue
        docker-compose up --build -d
        Write-Host "Environment started! Access points:" -ForegroundColor Green
        Write-Host "  Bessie Web App: http://localhost:8080" -ForegroundColor White
        Write-Host "  Firebase Emulator: http://localhost:4000" -ForegroundColor White
    }
    "stop" {
        Write-Host "Stopping Bessie development environment..." -ForegroundColor Blue
        docker-compose down
        Write-Host "Environment stopped." -ForegroundColor Green
    }
    "restart" {
        Write-Host "Restarting Bessie development environment..." -ForegroundColor Blue
        docker-compose down
        docker-compose up --build -d
        Write-Host "Environment restarted!" -ForegroundColor Green
    }
    "logs" {
        Write-Host "Showing logs..." -ForegroundColor Blue
        docker-compose logs -f
    }
    "status" {
        Write-Host "Checking status..." -ForegroundColor Blue
        docker-compose ps
    }
    "clean" {
        Write-Host "Cleaning up containers and volumes..." -ForegroundColor Yellow
        docker-compose down -v
        docker system prune -f
        Write-Host "Cleanup complete." -ForegroundColor Green
    }
}
