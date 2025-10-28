// eslint.config.js — JavaScript + React projects
import js from '@eslint/js';
import globals from 'globals';
import reactPlugin from 'eslint-plugin-react';
import reactRefresh from 'eslint-plugin-react-refresh';
import hooks from 'eslint-plugin-react-hooks';
import a11y from 'eslint-plugin-jsx-a11y';
import prettier from 'eslint-config-prettier';
import { defineConfig, globalIgnores } from 'eslint/config';

export default defineConfig([
  globalIgnores(['dist', 'node_modules', 'commitlint.config.js']),

  {
    files: ['**/*.{js,jsx}'],

    plugins: {
      react: reactPlugin,
      'react-hooks': hooks,
      'jsx-a11y': a11y,
      'react-refresh': reactRefresh,
    },

    languageOptions: {
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
        ecmaFeatures: { jsx: true },
      },
      globals: globals.browser,
    },

    settings: {
      react: { version: 'detect' },
    },

    rules: {
      ...js.configs.recommended.rules,
      ...reactPlugin.configs.recommended.rules,
      ...hooks.configs['recommended-latest'].rules,
      ...a11y.configs.recommended.rules,
      ...reactRefresh.configs.vite.rules,

      // ✅ React & Hooks best practices
      'react/react-in-jsx-scope': 'off',
      'react/jsx-uses-vars': 'error',
      'react/self-closing-comp': 'warn',
      'react/jsx-no-useless-fragment': 'warn',
      'react-hooks/rules-of-hooks': 'error',
      'react-hooks/exhaustive-deps': 'warn',
    },
  },

  prettier,
]);
