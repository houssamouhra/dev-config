# ===================================================
# ⚙️  Dev Config Installer for Linux / macOS (Bash)
# Copies dev-config files from ~/dev-config into current project
# ===================================================

set -e  # stop on any error

CONFIG_DIR="$HOME/dev-config"

echo ""
echo -e "\033[36m🚀  Copying dev configuration files from $CONFIG_DIR\033[0m"
echo "==================================================="

# Check if dev-config exists
if [ ! -d "$CONFIG_DIR" ]; then
  echo -e "\033[31m❌  Config directory not found at $CONFIG_DIR\033[0m"
  echo -e "\033[33m💡  Make sure your dev-config repo is cloned to your home folder.\033[0m"
  exit 1
fi

# Ask before overwriting
read -p "⚠️  This will overwrite local config files if they exist. Continue? (y/n): " ANSWER
if [ "$ANSWER" != "y" ]; then
  echo -e "\033[31m❌  Aborted by user.\033[0m"
  exit 0
fi

# Helper: copy and create folders automatically
copy_config() {
  local SOURCE="$1"
  local TARGET="$2"

  if [ ! -e "$SOURCE" ]; then
    echo -e "\033[33m⚠️  Skipped: source not found → $SOURCE\033[0m"
    return
  fi

  local TARGET_DIR
  TARGET_DIR=$(dirname "$TARGET")
  mkdir -p "$TARGET_DIR"

  cp -rf "$SOURCE" "$TARGET"
  echo -e "\033[32m✅  Copied $SOURCE → $TARGET\033[0m"
}

# ===================================================
# 📦  Core config files
# ===================================================
copy_config "$CONFIG_DIR/.husky" ".husky"
copy_config "$CONFIG_DIR/.editorconfig" ".editorconfig"
copy_config "$CONFIG_DIR/.gitattributes" ".gitattributes"
copy_config "$CONFIG_DIR/.gitignore" ".gitignore"
copy_config "$CONFIG_DIR/.prettierrc" ".prettierrc"
copy_config "$CONFIG_DIR/commitlint.config.js" "commitlint.config.js"
copy_config "$CONFIG_DIR/lint-staged.config.js" "lint-staged.config.js"
copy_config "$CONFIG_DIR/eslint.config.js" "eslint.config.js"

# ===================================================
# 📦  Merge package.json (Vite + dev-config)
# ===================================================
DEV_PKG="$CONFIG_DIR/package.json"
TARGET_PKG="package.json"

if [ -f "$DEV_PKG" ] && [ -f "$TARGET_PKG" ]; then
  echo ""
  echo -e "\033[36m🔄  Merging dev-config package.json with project package.json...\033[0m"

  # Merge using jq
  if ! command -v jq >/dev/null 2>&1; then
    echo -e "\033[31m❌  jq is required for merging JSON. Install it via:\033[0m"
    echo "   sudo apt install jq        # on Ubuntu/Debian"
    echo "   brew install jq            # on macOS"
    exit 1
  fi

  TMP_FILE=$(mktemp)

  jq -s '
    def merge(a;b):
      reduce (b | keys_unsorted[]) as $k (a;
        .[$k] = if (a[$k] | type) == "object" and (b[$k] | type) == "object"
                 then merge(a[$k]; b[$k])
                 else b[$k]
                 end);
    merge(.[0]; .[1])
  ' "$TARGET_PKG" "$DEV_PKG" >"$TMP_FILE"

  mv "$TMP_FILE" "$TARGET_PKG"
  echo -e "\033[32m✅  package.json merged successfully!\033[0m"
else
  echo -e "\033[33m⚠️  Skipped package.json merge — one of the files was not found.\033[0m"
fi

# ===================================================
# 🏁  Finish
# ===================================================
echo ""
echo -e "\033[33m✨  All configuration files copied successfully!\033[0m"
echo "---------------------------------------------------"
echo -e "\033[36m🧠  Next recommended steps:\033[0m"
echo "   pnpm install"
echo "   pnpm lint"
echo "   pnpm format"
echo "---------------------------------------------------"
echo "🫡  Setup complete, sir!"
echo ""
