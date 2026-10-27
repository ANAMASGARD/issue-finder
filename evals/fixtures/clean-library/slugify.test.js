const assert = require("node:assert");
const { test } = require("node:test");
const { slugify } = require("./slugify");

test("basic case", () => {
  assert.strictEqual(slugify("Hello, World!"), "hello-world");
});

test("already spaced", () => {
  assert.strictEqual(slugify("  Already   spaced  "), "already-spaced");
});

test("empty string", () => {
  assert.strictEqual(slugify(""), "");
});

test("whitespace only", () => {
  assert.strictEqual(slugify("   "), "");
});

test("throws on non-string input", () => {
  assert.throws(() => slugify(42), TypeError);
});
