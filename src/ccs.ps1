#Requires -Version 5.1

$CCS_DIR = "$HOME\.config\claude-profiles"
$PROFILES_DIR = "$CCS_DIR\profiles"
$ACTIVE_LINK = "$CCS_DIR\active"

function _ProfilePath([string]$name) {
    return Join-Path $PROFILES_DIR "$name.json"
}

function _ActiveName {
    if (-not (Test-Path $ACTIVE_LINK)) { return "(none)" }
    $item = Get-Item $ACTIVE_LINK -ErrorAction SilentlyContinue
    if (-not $item) { return "(none)" }
    return [System.IO.Path]::GetFileNameWithoutExtension($item.Target)
}

function _ReadEnvField([string]$path, [string]$field) {
    $json = Get-Content $path -Raw | ConvertFrom-Json
    $val = $json.env.$field
    if ($null -eq $val) { return "" }
    return $val
}

function Cmd-List {
    $active = _ActiveName
    $profiles = @(Get-ChildItem $PROFILES_DIR -Filter "*.json" -ErrorAction SilentlyContinue)
    if ($profiles.Count -eq 0) {
        Write-Host "No profiles found. Run: ccs add <name>"
        return
    }
    foreach ($f in $profiles) {
        $name = $f.BaseName
        if ($name -eq $active) {
            Write-Host "* $name (active)"
        } else {
            Write-Host "  $name"
        }
    }
}

function Cmd-Switch([string]$name) {
    if ([string]::IsNullOrEmpty($name)) {
        Write-Host "Available profiles:"
        Cmd-List
        Write-Host ""
        Write-Host "Usage: ccs switch <name>"
        exit 1
    }
    $path = _ProfilePath $name
    if (-not (Test-Path $path)) {
        Write-Error "error: profile '$name' not found"
        exit 1
    }

    $baseUrl = _ReadEnvField $path "ANTHROPIC_BASE_URL"
    $token   = _ReadEnvField $path "ANTHROPIC_AUTH_TOKEN"

    if (-not [string]::IsNullOrEmpty($baseUrl)) {
        if ([string]::IsNullOrEmpty($token) -or $token -eq '""') {
            Write-Error "error: profile '$name' has no API key set"
            Write-Host "Set it with: ccs key $name" -ForegroundColor Red
            exit 1
        }
    }

    if (Test-Path $ACTIVE_LINK) { Remove-Item $ACTIVE_LINK -Force }
    New-Item -ItemType SymbolicLink -Path $ACTIVE_LINK -Target $path | Out-Null
    Write-Host "Switched to $name"
}

function Cmd-Current {
    $active = _ActiveName
    if ($active -eq "(none)") {
        Write-Host "No active profile. Run: ccs switch <name>"
        return
    }
    Write-Host "Active: $active"
    $json = Get-Content $ACTIVE_LINK -Raw | ConvertFrom-Json
    if ($json.env.PSObject.Properties["ANTHROPIC_AUTH_TOKEN"]) {
        $json.env.PSObject.Properties.Remove("ANTHROPIC_AUTH_TOKEN")
    }
    $json | ConvertTo-Json -Depth 10
}

function Cmd-Add([string]$name) {
    if ([string]::IsNullOrEmpty($name)) {
        Write-Error "usage: ccs add <name>"
        exit 1
    }
    $path = _ProfilePath $name
    if (Test-Path $path) {
        Write-Error "error: profile '$name' already exists (use: ccs edit $name)"
        exit 1
    }
    New-Item -ItemType Directory -Force -Path $PROFILES_DIR | Out-Null

    Write-Host "Criando novo perfil: $name" -ForegroundColor Cyan
    Write-Host "(Deixe em branco e aperte Enter para ignorar um campo)`n" -ForegroundColor Gray

    $baseUrl    = Read-Host "BASE URL (ex: https://omniroute... ou vazio)"
    $authToken  = Read-Host "AUTH TOKEN (Sua API Key)"
    $model      = Read-Host "MAIN MODEL (ex: cx/gpt-5.5 ou vazio)"
    $smallModel = Read-Host "FAST MODEL (ex: cx/gpt-5.4-mini ou vazio)"

    $envBlock = [ordered]@{}
    
    if (-not [string]::IsNullOrWhiteSpace($baseUrl)) { $envBlock["ANTHROPIC_BASE_URL"] = $baseUrl }
    if (-not [string]::IsNullOrWhiteSpace($authToken)) { $envBlock["ANTHROPIC_AUTH_TOKEN"] = $authToken }
    
    if (-not [string]::IsNullOrWhiteSpace($model)) { 
        $envBlock["ANTHROPIC_MODEL"] = $model 
        $envBlock["ANTHROPIC_DEFAULT_OPUS_MODEL"] = $model 
        $envBlock["ANTHROPIC_DEFAULT_SONNET_MODEL"] = $model 
    }
    if (-not [string]::IsNullOrWhiteSpace($smallModel)) { 
        $envBlock["ANTHROPIC_DEFAULT_HAIKU_MODEL"] = $smallModel 
        $envBlock["CLAUDE_CODE_SUBAGENT_MODEL"] = $smallModel 
    }

    $envBlock["CLAUDE_CODE_EFFORT_LEVEL"] = "default"

    [ordered]@{ env = $envBlock } | ConvertTo-Json -Depth 10 | Set-Content $path
    Write-Host "`nPerfil '$name' criado com sucesso!" -ForegroundColor Green
    Write-Host "Dica: Voce pode editar manualmente com 'ccs edit $name'" -ForegroundColor Yellow
}

function Cmd-Edit([string]$name) {
    if ([string]::IsNullOrEmpty($name)) {
        Write-Error "usage: ccs edit <name>"
        exit 1
    }
    $path = _ProfilePath $name
    if (-not (Test-Path $path)) {
        Write-Error "error: profile '$name' not found"
        exit 1
    }
    $editor = if ($env:EDITOR) { $env:EDITOR } else { "notepad" }
    & $editor $path
}

function Cmd-Key([string]$name) {
    if ([string]::IsNullOrEmpty($name)) {
        Write-Error "usage: ccs key <name>"
        exit 1
    }
    $path = _ProfilePath $name
    if (-not (Test-Path $path)) {
        Write-Error "error: profile '$name' not found"
        exit 1
    }
    $secureKey = Read-Host -AsSecureString "New API key for '$name'"
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureKey)
    $newKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)

    $json = Get-Content $path -Raw | ConvertFrom-Json
    $json.env.ANTHROPIC_AUTH_TOKEN = $newKey
    $json | ConvertTo-Json -Depth 10 | Set-Content $path
    Write-Host "Updated API key for $name"
}

function Cmd-Remove([string]$name) {
    if ([string]::IsNullOrEmpty($name)) {
        Write-Error "usage: ccs remove <name>"
        exit 1
    }
    $path = _ProfilePath $name
    if (-not (Test-Path $path)) {
        Write-Error "error: profile '$name' not found"
        exit 1
    }
    if (Test-Path $ACTIVE_LINK) {
        $target = (Get-Item $ACTIVE_LINK).Target
        if ($target -eq $path) { Remove-Item $ACTIVE_LINK -Force }
    }
    Remove-Item $path -Force
    Write-Host "Removed: $name"
}

function Cmd-Test {
    if (-not (Test-Path $ACTIVE_LINK)) {
        Write-Error "error: no active profile (run: ccs switch <name>)"
        exit 1
    }

    $baseUrl   = _ReadEnvField $ACTIVE_LINK "ANTHROPIC_BASE_URL"
    $authToken = _ReadEnvField $ACTIVE_LINK "ANTHROPIC_AUTH_TOKEN"
    $model     = _ReadEnvField $ACTIVE_LINK "ANTHROPIC_MODEL"

    Write-Host -NoNewline "Testing $(_ActiveName) ($model)... "

    $body = ConvertTo-Json -Depth 5 @{
        model      = $model
        max_tokens = 1
        messages   = @(@{ role = "user"; content = "hi" })
    }

    try {
        Invoke-RestMethod -Uri "$baseUrl/messages" `
            -Method POST `
            -Headers @{
                "x-api-key"          = $authToken
                "anthropic-version"  = "2023-06-01"
                "content-type"       = "application/json"
            } `
            -Body $body `
            -ErrorAction Stop | Out-Null
        Write-Host "OK"
    } catch {
        $status = $_.Exception.Response.StatusCode.value__
        $msg = ""
        try { $msg = ($_.ErrorDetails.Message | ConvertFrom-Json).error.message } catch {}
        $suffix = if ($msg) { ": $msg" } else { "" }
        Write-Host "FAIL (HTTP $status$suffix)"
        exit 1
    }
}

function Cmd-Run([string[]]$runArgs) {
    $provider = ""; $model = ""; $key = ""; $smallModel = ""; $customUrl = ""
    $remaining = @()

    # Parse flags manually
    $i = 0
    $doneFlags = $false
    while (($i -lt $runArgs.Count) -and (-not $doneFlags)) {
        $flag = $runArgs[$i]
        if ($flag -eq "--provider" -and ($i+1) -lt $runArgs.Count)    { $provider   = $runArgs[$i+1]; $i += 2 }
        elseif ($flag -eq "--model" -and ($i+1) -lt $runArgs.Count)   { $model      = $runArgs[$i+1]; $i += 2 }
        elseif ($flag -eq "--key" -and ($i+1) -lt $runArgs.Count)     { $key        = $runArgs[$i+1]; $i += 2 }
        elseif ($flag -eq "--small-model" -and ($i+1) -lt $runArgs.Count) { $smallModel = $runArgs[$i+1]; $i += 2 }
        elseif ($flag -eq "--url" -and ($i+1) -lt $runArgs.Count)     { $customUrl  = $runArgs[$i+1]; $i += 2 }
        else { $doneFlags = $true }
    }

    # Collect remaining args
    if ($i -lt $runArgs.Count) {
        $remaining = $runArgs[$i..($runArgs.Count-1)]
    }

    # Profile-name mode (backward compatible)
    if ([string]::IsNullOrEmpty($provider)) {
        $name = ""
        if ($remaining.Count -gt 0) { $name = $remaining[0] }
        if ([string]::IsNullOrEmpty($name)) {
            Write-Error "usage: ccs run <name> [claude args...]"
            exit 1
        }
        $path = _ProfilePath $name
        if (-not (Test-Path $path)) {
            Write-Error "error: profile '$name' not found"
            exit 1
        }
        $extra = @()
        if ($remaining.Count -gt 1) { $extra = $remaining[1..($remaining.Count-1)] }
        & claude --settings $path @extra
        return
    }

    # Ephemeral mode
    if ([string]::IsNullOrEmpty($model)) {
        Write-Error "error: --model is required"
        exit 1
    }

    # Resolve base URL
    $baseUrl = ""
    if (-not [string]::IsNullOrEmpty($customUrl)) {
        $baseUrl = $customUrl
    } else {
        $providerUrls = @{
            "deepseek"   = "https://api.deepseek.com/anthropic"
            "openrouter" = "https://openrouter.ai/api"
            "fireworks"  = "https://api.fireworks.ai/inference"
        }
        # OmniRoute: use env var or default
        if ($env:OMNIROUTE_BASE_URL) {
            $providerUrls["omniroute"] = $env:OMNIROUTE_BASE_URL
        } else {
            $providerUrls["omniroute"] = "http://localhost:20128/v1"
        }

        if ($providerUrls.ContainsKey($provider)) {
            $baseUrl = $providerUrls[$provider]
        } else {
            Write-Error "error: unknown provider '$provider' - use --url to specify a custom URL"
            exit 1
        }
    }

    # Resolve API key
    if ([string]::IsNullOrEmpty($key)) {
        $providerEnvVars = @{
            "deepseek"   = "DEEPSEEK_API_KEY"
            "openrouter" = "OPENROUTER_API_KEY"
            "fireworks"  = "FIREWORKS_API_KEY"
            "omniroute"  = "OMNIROUTE_API_KEY"
        }
        $envVar = $providerEnvVars[$provider]
        if ($envVar) { $key = [Environment]::GetEnvironmentVariable($envVar) }
        if ([string]::IsNullOrEmpty($key)) {
            Write-Error "error: no API key - pass --key or set $envVar"
            exit 1
        }
    }

    # Create ephemeral profile and run
    $tmpPath = Join-Path $env:TEMP "ccs-ephemeral-$(Get-Random).json"
    try {
        $envObj = [ordered]@{
            ANTHROPIC_BASE_URL  = $baseUrl
            ANTHROPIC_AUTH_TOKEN = $key
            ANTHROPIC_MODEL     = $model
        }
        if (-not [string]::IsNullOrEmpty($smallModel)) {
            $envObj["ANTHROPIC_DEFAULT_HAIKU_MODEL"] = $smallModel
            $envObj["CLAUDE_CODE_SUBAGENT_MODEL"] = $smallModel
        }
        @{ env = $envObj } | ConvertTo-Json -Depth 10 | Set-Content $tmpPath
        & claude --settings $tmpPath @remaining
    } finally {
        Remove-Item $tmpPath -Force -ErrorAction SilentlyContinue
    }
}

function Cmd-Uninstall {
    $installDir = "$env:USERPROFILE\.local\bin"
    $ccsScript  = "$installDir\ccs.ps1"

    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Red
    Write-Host "  ⚠️  CCS Uninstall" -ForegroundColor Red
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Red
    Write-Host ""
    Write-Host "The following will be removed:" -ForegroundColor Yellow
    Write-Host "  • CCS script:   $ccsScript"
    Write-Host "  • PowerShell profile integrations (PS5 and PS7)"
    Write-Host ""
    Write-Host "You will also be asked separately whether to delete your" -ForegroundColor Yellow
    Write-Host "  saved profiles ($CCS_DIR)."
    Write-Host "  ⚠  Profiles contain your API keys — choose carefully." -ForegroundColor Yellow
    Write-Host ""

    $confirm = Read-Host "Uninstall CCS? [y/N]"
    if ($confirm.ToLower() -ne "y") {
        Write-Host "Cancelled."
        return
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

    # ── Clean PowerShell profile integrations ──────────────────────────────
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

    # ── Remove ccs.ps1 ─────────────────────────────────────────────────────
    if (Test-Path $ccsScript) {
        Remove-Item $ccsScript -Force
        Write-Host "  Removed $ccsScript"
    }

    # ── Handle profiles directory ───────────────────────────────────────────
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
}

function Show-Help {
    Write-Host @"
ccs — Claude Code Switcher

Usage: ccs <command> [args]

Commands:
  list                 List all profiles (default)
  switch <name>        Set active profile
  switch off/disable   Disable CCS routing and use native global credentials
  current              Show active profile configuration
  add <name>           Add a new profile interactively
  edit <name>          Edit a profile in notepad / editor
  key <name>           Update the API key for a profile
  remove <name>        Delete a profile
  test                 Test the active profile connection (real API call)
  run <name> [...]     Run Claude once with a specific profile
  run --provider <p> --model <m> --key <k> [...]  Run Claude in ephemeral mode without saving a profile
  uninstall            Remove CCS, aliases, and (optionally) saved profiles
  help                 Show this help message
"@
}

New-Item -ItemType Directory -Force -Path $PROFILES_DIR | Out-Null

$cmd  = if ($args.Count -gt 0) { $args[0] } else { "" }
$arg1 = if ($args.Count -gt 1) { $args[1] } else { "" }
$rest = if ($args.Count -gt 2) { $args[2..($args.Count - 1)] } else { @() }

switch ($cmd) {
    { $_ -eq "" -or $_ -eq "list" } { Cmd-List }
    "switch"  {
        if ($arg1 -eq "off" -or $arg1 -eq "disable") {
            if (Test-Path "$CCS_DIR\active") { Remove-Item "$CCS_DIR\active" -Force }
            Write-Host "CCS disabled. Using default global variables."
        } else {
            Cmd-Switch $arg1
        }
    }
    "disable" {
        if (Test-Path "$CCS_DIR\active") { Remove-Item "$CCS_DIR\active" -Force }
        Write-Host "CCS disabled. Using default global variables."
    }
    "off"     {
        if (Test-Path "$CCS_DIR\active") { Remove-Item "$CCS_DIR\active" -Force }
        Write-Host "CCS disabled. Using default global variables."
    }
    "current" { Cmd-Current }
    "add"     { Cmd-Add $arg1 }
    "edit"    { Cmd-Edit $arg1 }
    "key"     { Cmd-Key $arg1 }
    "remove"  { Cmd-Remove $arg1 }
    "test"    { Cmd-Test }
    "run"       { Cmd-Run $(if ($args.Count -gt 1) { $args[1..($args.Count-1)] } else { @() }) }
    "uninstall" { Cmd-Uninstall }
    { $_ -in @("help", "--help", "-h") } { Show-Help }
    default {
        Write-Host "Unknown command: $cmd"
        Write-Host ""
        Cmd-List
    }
}
