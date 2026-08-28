[CmdletBinding()]
param(
    [string]$OutputDirectory,
    [switch]$Sanitize
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

try {
    if (-not (Get-Command opencode -ErrorAction SilentlyContinue)) {
        throw "OpenCode CLI was not found. Install it or add it to PATH first."
    }

    $sessionOutput = opencode session list -n 1 --format json
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to list OpenCode sessions (exit code: $LASTEXITCODE)."
    }

    $sessionJson = [string]::Join(
        [Environment]::NewLine,
        [string[]]$sessionOutput
    )
    $sessions = @($sessionJson | ConvertFrom-Json)

    if ($sessions.Count -eq 0) {
        throw "No OpenCode session was found."
    }

    $idProperty = $sessions[0].PSObject.Properties["id"]
    if ($null -eq $idProperty -or [string]::IsNullOrWhiteSpace([string]$idProperty.Value)) {
        throw "The latest OpenCode session does not contain an id."
    }

    $sessionId = [string]$idProperty.Value
    $scriptRoot = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }

    if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
        $OutputDirectory = Join-Path $scriptRoot "runs\latest"
    }

    $outputPath = Join-Path $OutputDirectory "session.json"
    New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

    $exportArguments = @("export", $sessionId)
    if ($Sanitize) {
        $exportArguments += "--sanitize"
    }

    $exportOutput = opencode @exportArguments
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to export OpenCode session '$sessionId' (exit code: $LASTEXITCODE)."
    }

    $exportJson = [string]::Join(
        [Environment]::NewLine,
        [string[]]$exportOutput
    )

    [System.IO.File]::WriteAllText(
        $outputPath,
        $exportJson,
        [System.Text.UTF8Encoding]::new($false)
    )

    Write-Host "Saved session: $sessionId"
    Write-Host "-> $outputPath"
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
