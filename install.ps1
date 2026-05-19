#Requires -Version 5.1

$INSTALL_DIR = "$env:USERPROFILE\.local\bin"
$CCS_DIR     = "$env:USERPROFILE\.config\claude-profiles"
$PROFILES_DIR = "$CCS_DIR\profiles"
$RAW_BASE    = "https://raw.githubusercontent.com/antonio-abrantes/claude-code-switcher/main"

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Installing Claude Code Switcher (Remote)   " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# 1. Criar diretorios
Write-Host "[1/4] Creating directories..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $INSTALL_DIR  | Out-Null
New-Item -ItemType Directory -Force -Path $PROFILES_DIR | Out-Null

# 2. Copiar script principal
Write-Host "[2/4] Downloading ccs to $INSTALL_DIR\ccs.ps1..." -ForegroundColor Yellow
Invoke-WebRequest -Uri "$RAW_BASE/src/ccs.ps1" -OutFile "$INSTALL_DIR\ccs.ps1"

# 3. Copiar profiles — skip existing to preserve API keys
Write-Host "[3/4] Downloading default profiles..." -ForegroundColor Yellow
@("anthropic", "deepseek", "anthropic-only-sonnet", "omniroute") | ForEach-Object {
    $destPath = "$PROFILES_DIR\$_.json"
    if (-not (Test-Path $destPath)) {
        try {
            Invoke-WebRequest -Uri "$RAW_BASE/profiles/$_.json" -OutFile $destPath
            Write-Host "       -> $_.json" -ForegroundColor Gray
        } catch {
            Write-Host "       -> Failed to download $_.json" -ForegroundColor Red
        }
    } else {
        Write-Host "       -> $_.json (already exists, skipped)" -ForegroundColor DarkGray
    }
}

# 4. Criar symlink — only if not already configured
Write-Host "[4/4] Setting up active profile..." -ForegroundColor Yellow
if (-not (Test-Path "$CCS_DIR\active")) {
    New-Item -ItemType SymbolicLink -Path "$CCS_DIR\active" -Target "$PROFILES_DIR\anthropic.json" | Out-Null
    Write-Host "       Active profile set to 'anthropic'" -ForegroundColor Green
} else {
    Write-Host "       Active profile unchanged (already configured)" -ForegroundColor Gray
}

# 5. Configurar PowerShell Profile e interceptador (Mesma logica robusta do install-local)
Write-Host "`nConfiguring PowerShell integration..." -ForegroundColor Yellow

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
        # Para comandos de autenticacao, rodar direto para nao misturar configuracoes de profiles com tokens
        & claude.exe `$args
        return
    }

    `$activePath = "$CCS_DIR\active"
    if (Test-Path `$activePath) {
        & claude.exe --settings `$activePath `$args
    } else {
        & claude.exe `$args
    }
}
# CCS-END
"@

# Injetar em todos os profiles relevantes (PS5 e PS7)
$profilesToUpdate = @(
    "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1",
    "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
)

foreach ($pPath in $profilesToUpdate) {
    if (-not (Test-Path $pPath)) {
        $dir = Split-Path $pPath
        if (-not (Test-Path $dir)) { New-Item -Path $dir -ItemType Directory -Force | Out-Null }
        New-Item -Path $pPath -ItemType File -Force | Out-Null
    }

    $currentContent = Get-Content $pPath -Raw -ErrorAction SilentlyContinue
    if ([string]::IsNullOrWhiteSpace($currentContent) -or $currentContent -notmatch "# CCS — Claude Code Switcher") {
        Add-Content -Path $pPath -Value $aliasBlock
        Write-Host "       -> Injected in $($pPath)" -ForegroundColor Green
    } else {
        Write-Host "       -> Already configured in $($pPath)" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  INSTALLATION SUCCESSFUL!                   " -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Please close this window and open a NEW PowerShell terminal to start using 'ccs'." -ForegroundColor White
Write-Host ""