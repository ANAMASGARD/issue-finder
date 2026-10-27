# slugify

A tiny, dependency-free function that turns a string into a URL-safe slug.

## Usage

```js
const { slugify } = require("./slugify");

slugify("Hello, World!"); // "hello-world"
slugify("  Already   spaced  "); // "already-spaced"
slugify(""); // ""
```

## Behavior

- Lowercases the input.
- Replaces any run of non-alphanumeric characters with a single hyphen.
- Trims leading and trailing hyphens.
- Returns an empty string for empty or whitespace-only input.
