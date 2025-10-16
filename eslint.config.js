import js from '@eslint/js';
import globals from 'globals';
import reactPlugin from 'eslint-plugin-react';
import hooks from 'eslint-plugin-react-hooks';
import a11y from 'eslint-plugin-jsx-a11y';
import reactRefresh from 'eslint-plugin-react-refresh';
import prettier from 'eslint-config-prettier';
import { defineConfig, globalIgnores } from 'eslint/config';

export default defineConfig([
  // Ignore build folders
  globalIgnores(['dist', 'node_modules']),
  {
    files: ['**/*.{js,jsx}'],
    ignores: ['dist', 'node_modules'],

    // Flat-config style plugin registration
    plugins: {
      react: reactPlugin,
      'react-hooks': hooks,
      'jsx-a11y': a11y,
      'react-refresh': reactRefresh,
    },

    // Apply language & parser options
    languageOptions: {
      ecmaVersion: 'latest',
      sourceType: 'module',
      globals: globals.browser,
    },

    // Settings (auto-detect React version)
    settings: {
      react: { version: 'detect' },
    },

    // Merge rule sets manually
    rules: {
      ...js.configs.recommended.rules,
      ...reactPlugin.configs.recommended.rules,
      ...hooks.configs['recommended-latest'].rules,
      ...a11y.configs.recommended.rules,
      ...reactRefresh.configs.vite.rules,
      ...prettier.rules, // disables style rules conflicting with Prettier

      // Custom tweaks
      'react/react-in-jsx-scope': 'off', // Not needed with React 17+
      'react/prop-types': 'off', // You use TypeScript or JS docs
      'no-unused-vars': ['warn', { varsIgnorePattern: '^[A-Z_]' }],
    },
  },
]);
