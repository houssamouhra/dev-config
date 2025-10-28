// eslint.config.ts.js — TypeScript + React projects
import js from '@eslint/js';
import globals from 'globals';
import reactPlugin from 'eslint-plugin-react';
import reactRefresh from 'eslint-plugin-react-refresh';
import tseslint from 'typescript-eslint';
import hooks from 'eslint-plugin-react-hooks';
import a11y from 'eslint-plugin-jsx-a11y';
import prettier from 'eslint-config-prettier';
import { defineConfig, globalIgnores } from 'eslint/config';

export default defineConfig([
  globalIgnores(['dist', 'node_modules', 'commitlint.config.js']),

  {
    files: ['**/*.{ts,tsx}'],

    plugins: {
      '@typescript-eslint': tseslint.plugin,
      react: reactPlugin,
      'react-hooks': hooks,
      'jsx-a11y': a11y,
      'react-refresh': reactRefresh,
    },

    languageOptions: {
      parser: tseslint.parser,
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
        ecmaFeatures: { jsx: true },
        project: ['./tsconfig.json'],
      },
      globals: globals.browser,
    },

    settings: {
      react: { version: 'detect' },
    },

    rules: {
      // --- Base rules ---
      ...js.configs.recommended.rules,
      ...reactPlugin.configs.recommended.rules,
      ...hooks.configs['recommended-latest'].rules,
      ...a11y.configs.recommended.rules,
      ...reactRefresh.configs.vite.rules,
      ...tseslint.configs.recommended.rules,

      // --- TS-aware linting ---
      'no-unused-vars': 'off',
      'no-undef': 'off',
      'no-shadow': 'off',
      'no-redeclare': 'off',

      '@typescript-eslint/no-unused-vars': [
        'warn',
        { argsIgnorePattern: '^_', varsIgnorePattern: '^[A-Z_]' },
      ],
      '@typescript-eslint/no-shadow': 'warn',
      '@typescript-eslint/no-redeclare': 'warn',

      // --- Type-aware safety rules ---
      '@typescript-eslint/no-floating-promises': 'error',
      '@typescript-eslint/no-misused-promises': 'error',
      '@typescript-eslint/await-thenable': 'error',
      '@typescript-eslint/no-for-in-array': 'warn',
      '@typescript-eslint/no-unnecessary-type-assertion': 'warn',
      '@typescript-eslint/unbound-method': 'warn',

      '@typescript-eslint/consistent-type-imports': ['warn', { prefer: 'type-imports' }],
      '@typescript-eslint/no-import-type-side-effects': 'error',

      // --- React/Hook conventions ---
      'react/react-in-jsx-scope': 'off',
      'react/prop-types': 'off',
      'react/jsx-uses-vars': 'error',
      'react/self-closing-comp': 'warn',
      'react/jsx-no-useless-fragment': 'warn',
      'react-hooks/rules-of-hooks': 'error',
      'react-hooks/exhaustive-deps': 'warn',
    },
  },

  prettier,
]);
