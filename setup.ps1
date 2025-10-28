# ===================================================
# ⚙️  Dev Config Installer for Windows PowerShell
# Copies dev-config files from ~/dev-config into current project
# ===================================================

# Define your dev-config directory
$ConfigDir = Join-Path $env:USERPROFILE "dev-config"

Write-Host ""
Write-Host "🚀  Copying dev configuration files from $ConfigDir" -ForegroundColor Cyan
Write-Host "==================================================="

# Check if dev-config folder exists
if (-not (Test-Path $ConfigDir)) {
    Write-Host "❌  Config directory not found at $ConfigDir" -ForegroundColor Red
    Write-Host "💡  Make sure your dev-config repo is cloned to your user folder." -ForegroundColor Yellow
    exit 1
}

# Confirm before overwriting
$answer = Read-Host "⚠️  This will overwrite local config files if they exist. Continue? (y/n)"
if ($answer -ne 'y') {
    Write-Host "❌  Aborted by user." -ForegroundColor Red
    exit 0
}

# Helper: Copy with overwrite and create dirs automatically
function Copy-Config($Source, $Target) {
    if (-not (Test-Path $Source)) {
        Write-Host "⚠️  Skipped: source not found → $Source" -ForegroundColor DarkYellow
        return
    }

    $TargetDir = Split-Path $Target -Parent
    if ($TargetDir -and -not (Test-Path $TargetDir)) {
        New-Item -ItemType Directory -Path $TargetDir | Out-Null
    }

    Copy-Item -Force -Recurse $Source $Target
    Write-Host "✅  Copied $Source → $Target" -ForegroundColor Green
}

# ===================================================
# 📦  Core config files
# ===================================================
Copy-Config "$ConfigDir\.husky" ".husky"
Copy-Config "$ConfigDir\.editorconfig" ".editorconfig"
Copy-Config "$ConfigDir\.gitattributes" ".gitattributes"
Copy-Config "$ConfigDir\.gitignore" ".gitignore"
Copy-Config "$ConfigDir\.prettierrc" ".prettierrc"
Copy-Config "$ConfigDir\commitlint.config.js" "commitlint.config.js"
Copy-Config "$ConfigDir\lint-staged.config.js" "lint-staged.config.js"
Copy-Config "$ConfigDir\eslint.config.js" "eslint.config.js"

# ===================================================
# 📦 Merge package.json (Vite + dev-config)
# ===================================================
$DevPkg = Join-Path $ConfigDir "package.json"
$TargetPkg = "package.json"

if ((Test-Path $DevPkg) -and (Test-Path $TargetPkg)) {    
    Write-Host ""
    Write-Host "🔄  Merging dev-config package.json with project package.json..." -ForegroundColor Cyan

    # Parse both JSON files
    $devJson = Get-Content $DevPkg -Raw | ConvertFrom-Json
    $targetJson = Get-Content $TargetPkg -Raw | ConvertFrom-Json

    # --- Helper: Convert PSCustomObject to Hashtable ---
    function Convert-ToHashtable($obj) {
        if ($null -eq $obj) { return @{} }
        if ($obj -is [System.Collections.IDictionary]) { return $obj }
        $hash = @{}
        foreach ($prop in $obj.PSObject.Properties) {
            if ($null -ne $prop.Value -and ($prop.Value -is [PSCustomObject])) {
                $hash[$prop.Name] = Convert-ToHashtable $prop.Value
            } else {
                $hash[$prop.Name] = $prop.Value
            }
        }
        return $hash
    }

    # --- Convert nested objects to hashtables ---
    $targetJson = Convert-ToHashtable $targetJson
    $devJson = Convert-ToHashtable $devJson

    # Ensure sections exist
    if (-not $targetJson.ContainsKey('scripts')) { $targetJson['scripts'] = @{} }
    if (-not $targetJson.ContainsKey('dependencies')) { $targetJson['dependencies'] = @{} }
    if (-not $targetJson.ContainsKey('devDependencies')) { $targetJson['devDependencies'] = @{} }

    # --- Merge scripts (dev-config order priority) ---
    foreach ($key in $devJson['scripts'].Keys) {
        $targetJson['scripts'][$key] = $devJson['scripts'][$key]
    }

    # --- Merge dependencies (if exist) ---
    if ($devJson.ContainsKey('dependencies')) {
        foreach ($key in $devJson['dependencies'].Keys) {
            $targetJson['dependencies'][$key] = $devJson['dependencies'][$key]
        }
    }

    # --- Merge devDependencies (dev-config order priority) ---
    if ($devJson.ContainsKey('devDependencies')) {
        foreach ($key in $devJson['devDependencies'].Keys) {
            $targetJson['devDependencies'][$key] = $devJson['devDependencies'][$key]
        }
    }

    # --- Build ordered structure for pretty JSON ---
    $ordered = [ordered]@{
        name = $targetJson.name
        private = $targetJson.private
        version = $targetJson.version
        type = $targetJson.type
        scripts = [ordered]@{}
        dependencies = [ordered]@{}
        devDependencies = [ordered]@{}
    }

    # === Custom order for scripts (manual control) ===
    $preferredScriptOrder = @(
       'lint', 'format', 'build', 'preview',
       'commitlint', 'lint:fix', 'prepare', 'dev'
    )
    foreach ($key in $preferredScriptOrder) {
      if ($targetJson['scripts'].ContainsKey($key)) {
        $ordered.scripts[$key] = $targetJson['scripts'][$key]
      }
    }

    # === Dependencies: React first, rest follow ===
    foreach ($key in @('react', 'react-dom')) {
      if ($targetJson['dependencies'].ContainsKey($key)) {
        $ordered.dependencies[$key] = $targetJson['dependencies'][$key]
      }
    }

    # Add a “catch-all” for missing devDependencies
    foreach ($key in $targetJson['dependencies'].Keys) {
      if (-not $ordered.dependencies.Contains($key)) {
        $ordered.dependencies[$key] = $targetJson['dependencies'][$key]
      }
    }

    # === Custom order for devDependencies ===
    $preferredDevDepOrder = @(
        'eslint-plugin-react', '@types/react-dom', 'globals',
        '@commitlint/cli', '@eslint/js', '@commitlint/config-conventional',
        '@types/react', 'eslint-plugin-react-refresh', 'eslint',
        'vite', 'husky', 'eslint-plugin-jsx-a11y', '@vitejs/plugin-react',
        'prettier', 'lint-staged', 'eslint-plugin-react-hooks',
        'eslint-config-prettier'
    )

    foreach ($key in $preferredDevDepOrder) {
      if ($targetJson['devDependencies'].ContainsKey($key)) {
        $ordered.devDependencies[$key] = $targetJson['devDependencies'][$key]
      }
    }

    # Add a “catch-all” for missing devDependencies
    foreach ($key in $targetJson['devDependencies'].Keys) {
      if (-not $ordered.devDependencies.Contains($key)) {
        $ordered.devDependencies[$key] = $targetJson['devDependencies'][$key]
      }
    }

    # --- Save merged and ordered result ---
    $ordered | ConvertTo-Json -Depth 10 | Set-Content $TargetPkg -Encoding UTF8
    Write-Host "✅  package.json merged successfully!" -ForegroundColor Green
    } else {
       Write-Host "⚠️  Skipped package.json merge — one of the files was not found." -ForegroundColor DarkYellow
}

# ===================================================
# 🏁  Finish
# ===================================================
Write-Host ""
Write-Host "✨  All configuration files copied successfully!" -ForegroundColor Yellow
Write-Host "---------------------------------------------------"
Write-Host "🧠  Next recommended steps:" -ForegroundColor Cyan
Write-Host "   pnpm install"
Write-Host "   pnpm lint"
Write-Host "   pnpm format"
Write-Host "---------------------------------------------------"
Write-Host "🫡  Setup complete, sir!"
Write-Host ""