export default {
  // Lint and auto-fix JS/JSX/TS/TSX files
  '**/*.{js,jsx,ts,tsx}': ['pnpm eslint --fix'],

  // Format other file types with Prettier
  '**/*.{json,css,md,html}': ['pnpm prettier --write'],
};
