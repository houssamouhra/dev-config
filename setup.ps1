# ===================================================
# 🔧 Dev Config Installer for Windows PowerShell
# Links dev-config files from ~/dev-config to current project
# ===================================================

# Define your dev-config directory
$ConfigDir = Join-Path $env:USERPROFILE "dev-config"

Write-Host ""
Write-Host "🚀 Linking dev configuration files from $ConfigDir" -ForegroundColor Cyan
Write-Host "==================================================="

# Check if dev-config folder exists
if (-not (Test-Path $ConfigDir)) {
    Write-Host "❌ Config directory not found at $ConfigDir" -ForegroundColor Red
    Write-Host "Make sure your dev-config repo is cloned to your user folder." -ForegroundColor DarkYellow
    exit 1
}

# Confirm before overwriting any files
$answer = Read-Host "⚠️  This will overwrite local config files if they exist. Continue? (y/n)"
if ($answer -ne 'y') {
    Write-Host "❌ Aborted by user." -ForegroundColor Red
    exit 0
}

# Helper function to safely link files
function New-ConfigLink($source, $target) {
    if (Test-Path $target) {
        Remove-Item $target -Force
    }
    New-Item -ItemType SymbolicLink -Path $target -Target $source | Out-Null
    Write-Host "✅ Linked $target → $source" -ForegroundColor Green
}

# ===================================================
# 📦 Core config files
# ===================================================
New-ConfigLink "$ConfigDir\.husky" ".husky"
New-ConfigLink "$ConfigDir\.editorconfig" ".editorconfig"
New-ConfigLink "$ConfigDir\.gitattributes" ".gitattributes"
New-ConfigLink "$ConfigDir\.gitignore" ".gitignore"
New-ConfigLink "$ConfigDir\.prettierrc" ".prettierrc"
New-ConfigLink "$ConfigDir\eslint.config.mjs" "eslint.config.mjs"
New-ConfigLink "$ConfigDir\commitlint.config.json" "commitlint.config.json"

# ===================================================
# 🏁 Finish
# ===================================================
Write-Host ""
Write-Host "✨ All configuration files have been linked successfully!" -ForegroundColor Yellow
Write-Host "---------------------------------------------------"
Write-Host "You can now run your usual commands:" -ForegroundColor DarkGray
Write-Host "  pnpm install"
Write-Host "  pnpm lint"
Write-Host "  pnpm format"
Write-Host "---------------------------------------------------"
Write-Host ""
