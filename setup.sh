#!/bin/bash
# ===================================================
# 🔧 Dev Config Installer for Linux / macOS
# Links dev-config files from ~/dev-config to current project
# ===================================================

CONFIG_DIR="$HOME/dev-config"

echo ""
echo -e "\033[36m🚀 Linking dev configuration files from $CONFIG_DIR\033[0m"
echo "==================================================="

# Ensure dev-config exists
if [ ! -d "$CONFIG_DIR" ]; then
  echo -e "\033[31m❌ Config directory not found at $CONFIG_DIR\033[0m"
  echo -e "\033[33mClone or create your dev-config repo there first.\033[0m"
  exit 1
fi

# Ask for confirmation
read -p "⚠️  This will overwrite local config files if they exist. Continue? (y/n) " confirm
if [ "$confirm" != "y" ]; then
  echo -e "\033[31m❌ Aborted by user.\033[0m"
  exit 0
fi

# Helper
link_config() {
  local source=$1
  local target=$2
  if [ -e "$target" ]; then
    rm -rf "$target"
  fi
  ln -s "$source" "$target"
  echo -e "\033[32m✅ Linked $target → $source\033[0m"
}

# Core configs
link_config "$CONFIG_DIR/.husky" ".husky"
link_config "$CONFIG_DIR/.editorconfig" ".editorconfig"
link_config "$CONFIG_DIR/.gitattributes" ".gitattributes"
link_config "$CONFIG_DIR/.gitignore" ".gitignore"
link_config "$CONFIG_DIR/.prettierrc" ".prettierrc"
link_config "$CONFIG_DIR/eslint.config.mjs" "eslint.config.mjs"
link_config "$CONFIG_DIR/commitlint.config.json" "commitlint.config.json"

echo ""
echo -e "\033[33m✨ All configuration files have been linked successfully!\033[0m"
echo "---------------------------------------------------"
echo "Next steps:"
echo "  pnpm install"
echo "  pnpm lint"
echo "  pnpm format"
echo "---------------------------------------------------"
echo ""
