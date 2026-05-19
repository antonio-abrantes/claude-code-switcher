#Requires -Version 5.1
# CCS Standalone Uninstaller — Windows (PowerShell)
# Usage: .\uninstall.ps1

$CCS_DIR     = "$env:USERPROFILE\.config\claude-profiles"
$INSTALL_DIR = "$env:USERPROFILE\.local\bin"
$CCS_SCRIPT  = "$INSTALL_DIR\ccs.ps1"

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Red
Write-Host "  ⚠️  CCS Uninstall" -ForegroundColor Red
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Red
Write-Host ""
Write-Host "The following will be removed:" -ForegroundColor Yellow
Write-Host "  • CCS script:   $CCS_SCRIPT"
Write-Host "  • PowerShell profile integrations (PS5 and PS7)"
Write-Host ""
Write-Host "You will also be asked separately whether to delete your" -ForegroundColor Yellow
Write-Host "  saved profiles ($CCS_DIR)."
Write-Host "  ⚠  Profiles contain your API keys — choose carefully." -ForegroundColor Yellow
Write-Host ""

$confirm = Read-Host "Uninstall CCS? [y/N]"
if ($confirm.ToLower() -ne "y") {
    Write-Host "Cancelled."
    exit 0
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host "  Profile deletion" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Your saved profiles are stored at:"
Write-Host "    $CCS_DIR"
Write-Host ""
Write-Host "  They contain your provider configurations and API keys."
Write-Host "  If you answer [Y], this folder will be PERMANENTLY deleted." -ForegroundColor Red
Write-Host "  If you answer [N], the folder is kept — you can reuse it later." -ForegroundColor Green
Write-Host ""

$delProfiles  = Read-Host "Permanently delete all saved profiles and API keys? [y/N]"
$keepProfiles = ($delProfiles.ToLower() -ne "y")

Write-Host ""

# ── Clean PowerShell profile integrations ────────────────────────────────
$psProfiles = @(
    "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1",
    "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
)
foreach ($pPath in $psProfiles) {
    if (Test-Path $pPath) {
        $content = Get-Content $pPath -Raw -ErrorAction SilentlyContinue
        if ($content -and $content -match '# CCS — Claude Code Switcher') {
            $cleaned = $content -replace '(?s)[\r\n]+# CCS — Claude Code Switcher[\r\n].*?# CCS-END', ''
            [System.IO.File]::WriteAllText($pPath, $cleaned)
            Write-Host "  Cleaned PowerShell profile: $pPath"
        }
    }
}

# ── Remove ccs.ps1 ────────────────────────────────────────────────────────
if (Test-Path $CCS_SCRIPT) {
    Remove-Item $CCS_SCRIPT -Force
    Write-Host "  Removed $CCS_SCRIPT"
}

# ── Handle profiles directory ─────────────────────────────────────────────
if (-not $keepProfiles) {
    if (Test-Path $CCS_DIR) {
        Remove-Item $CCS_DIR -Recurse -Force
        Write-Host "  Removed $CCS_DIR"
    }
} else {
    Write-Host "  Profiles kept at $CCS_DIR"
}

Write-Host ""
Write-Host "CCS has been uninstalled." -ForegroundColor Green
Write-Host "Open a new terminal to apply the changes." -ForegroundColor Yellow
Write-Host ""
