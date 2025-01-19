/* eslint-disable no-undef */
module.exports = {
  env: {
    es6: true,
    node: true,
  },
  parser: "@typescript-eslint/parser",
  parserOptions: {
    ecmaVersion: 2018,
  },
  extends: [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "google",
  ],
  rules: {
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
    "quotes": ["error", "double", {"allowTemplateLiterals": true}],
    "no-undef": "off",
    "@typescript-eslint/no-var-requires": "off",
    "no-unused-vars": "off",
    "require-jsdoc": "off",
  },
  globals: {
    module: "readonly",
    require: "readonly",
    exports: "readonly",
  },
};
/* eslint-enable no-undef */
