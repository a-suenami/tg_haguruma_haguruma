// =============================================================================
// .eslintrc
// =============================================================================
module.exports = {
  env: {
    browser: true,
    es2021: true,
  },
  extends: [
    'eslint:recommended',
  ],
  ignorePatterns: ['.eslintrc.js'],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 13,
    sourceType: 'module',
  },
  plugins: [
    '@typescript-eslint',
  ],
  rules: {
    'lines-between-class-members': 'off',
    'import/prefer-default-export': 'off',
    'no-unused-vars': 'off',
    'class-methods-use-this': 'off',
    '@typescript-eslint/no-unused-vars': ['error'],
    // 'import/extensions': [
    //   'error',
    //   'ignorePackages',
    //   {
    //     js: 'never',
    //     jsx: 'never',
    //     ts: 'never',
    //     tsx: 'never',
    //   },
    // ],
    'max-len': [
      'error',
      { code: 128, ignorePattern: '^import .*' },
    ],
  },
  settings: {
    'import/resolver': {
      alias: {
        map: [['@app', './app/frontend']],
        extensions: ['.js', '.jsx', '.ts', '.tsx'],
      },
    },
  },
};
