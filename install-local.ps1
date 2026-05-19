#Requires -Version 5.1
# install-local.ps1 — Installs CCS from the LOCAL source code (with OmniRoute changes)

$INSTALL_DIR  = "$env:USERPROFILE\.local\bin"
$CCS_DIR      = "$env:USERPROFILE\.config\claude-profiles"
$PROFILES_DIR = "$CCS_DIR\profiles"
$SCRIPT_DIR   = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CCS — Local Installation (w/ OmniRoute)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Create directories
New-Item -ItemType Directory -Force -Path $INSTALL_DIR  | Out-Null
New-Item -ItemType Directory -Force -Path $PROFILES_DIR | Out-Null

# 2. Copy the main script
Write-Host "[1/4] Copying ccs.ps1 to $INSTALL_DIR..." -ForegroundColor Yellow
Copy-Item "$SCRIPT_DIR\src\ccs.ps1" "$INSTALL_DIR\ccs.ps1" -Force

# 3. Copy all profiles (anthropic, deepseek, omniroute) — skip existing to preserve API keys
Write-Host "[2/4] Copying profiles..." -ForegroundColor Yellow
Get-ChildItem "$SCRIPT_DIR\profiles\*.json" | ForEach-Object {
    $dest = "$PROFILES_DIR\$($_.Name)"
    if (-not (Test-Path $dest)) {
        Copy-Item $_.FullName $dest
        Write-Host "       -> $($_.Name)" -ForegroundColor Gray
    } else {
        Write-Host "       -> $($_.Name) (already exists, skipped)" -ForegroundColor DarkGray
    }
}

# 4. Create symlink for active profile — only if not already configured
Write-Host "[3/4] Setting up active profile..." -ForegroundColor Yellow
if (-not (Test-Path "$CCS_DIR\active")) {
    New-Item -ItemType SymbolicLink -Path "$CCS_DIR\active" -Target "$PROFILES_DIR\anthropic.json" | Out-Null
    Write-Host "       Active profile set to 'anthropic'" -ForegroundColor Green
} else {
    Write-Host "       Active profile unchanged (already configured)" -ForegroundColor Gray
}

# 5. Configure PowerShell Profile and interceptor wrapper
Write-Host "[4/4] Verifying alias in PowerShell..." -ForegroundColor Yellow
$aliasLine = "Set-Alias ccs `"$INSTALL_DIR\ccs.ps1`""

# Configure execution policy via Registry (required to run ccs.ps1)
$currentPolicy = (Get-ExecutionPolicy -Scope CurrentUser)
if ($currentPolicy -notin @('RemoteSigned', 'Unrestricted', 'Bypass')) {
    Write-Host ""
    Write-Host "⚠️  CCS needs to set PowerShell ExecutionPolicy to RemoteSigned" -ForegroundColor Yellow
    Write-Host "   This affects only HKCU (current user) and is required to run CCS." -ForegroundColor Yellow
    Write-Host "   Current ExecutionPolicy: $currentPolicy" -ForegroundColor Gray
    $confirm = Read-Host "Allow this change? [Y/n]"
    if ($confirm -eq "" -or $confirm.ToLower() -eq "y") {
        try {
            reg add "HKCU\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v ExecutionPolicy /t REG_SZ /d RemoteSigned /f | Out-Null
            Write-Host "   ExecutionPolicy set to RemoteSigned." -ForegroundColor Green
        } catch {}
    } else {
        Write-Host "   ExecutionPolicy unchanged. CCS may not work in future sessions." -ForegroundColor Red
    }
} else {
    Write-Host "   ExecutionPolicy is already '$currentPolicy' — no changes needed." -ForegroundColor Gray
}

$aliasBlock = @"
`n# CCS — Claude Code Switcher
$aliasLine
function claude {
    if (`$args -match "^(auth|login)[\s`$]") {
        # For auth and login commands, run directly to not mix settings with active profiles
        & claude.exe `$args
        return
    }

    `$activePath = `"$CCS_DIR\active`"
    if (Test-Path `$activePath) {
        & claude.exe --settings `$activePath `$args
    } else {
        & claude.exe `$args
    }
}
# CCS-END
"@

# Update standard profile (usually PS5 or whatever is running this script)
$profilePath = $PROFILE
if (-not (Test-Path $profilePath)) {
    try {
        $dir = Split-Path $profilePath
        if (-not (Test-Path $dir)) { New-Item -Path $dir -ItemType Directory -Force | Out-Null }
        New-Item -Path $profilePath -ItemType File -Force | Out-Null
    } catch {}
}

$profileContent = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
if ($profileContent -notmatch "function claude \{") {
    Add-Content -Path $profilePath -Value $aliasBlock
    Write-Host "       Alias 'ccs' and wrapper 'claude' added to current `$PROFILE" -ForegroundColor Green
} else {
    Write-Host "       Alias 'ccs' and wrapper 'claude' already exist in current `$PROFILE" -ForegroundColor Gray
}

# Update PowerShell 7 profile specifically if it exists
$ps7Profile = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
if (Test-Path (Split-Path $ps7Profile -Parent)) {
    if (-not (Test-Path $ps7Profile)) {
        try { New-Item -Path $ps7Profile -ItemType File -Force | Out-Null } catch {}
    }
    $ps7Content = Get-Content $ps7Profile -Raw -ErrorAction SilentlyContinue
    if ($ps7Content -notmatch "function claude \{") {
        Add-Content -Path $ps7Profile -Value $aliasBlock
        Write-Host "       Alias 'ccs' and wrapper 'claude' added to PowerShell 7 Profile" -ForegroundColor Green
    } else {
        Write-Host "       Alias 'ccs' and wrapper 'claude' already exist in PowerShell 7 Profile" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  INSTALLATION COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Installed profiles:" -ForegroundColor White
Get-ChildItem "$PROFILES_DIR\*.json" | ForEach-Object {
    Write-Host "  - $($_.BaseName)" -ForegroundColor Cyan
}
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "  1. Close and reopen PowerShell (or run: . `$PROFILE)" -ForegroundColor White
Write-Host "  2. Configure your OmniRoute key:   ccs key omniroute" -ForegroundColor White
Write-Host "  3. Activate OmniRoute:             ccs switch omniroute" -ForegroundColor White
Write-Host "  4. Test your connection:           ccs test" -ForegroundColor White
Write-Host "  5. Start using Claude Code:        claude" -ForegroundColor White
Write-Host ""
