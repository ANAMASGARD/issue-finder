// A tiny, dependency-free slugify function. See README.md for the documented
// contract; this fixture is deliberately correct and matches its own docs.

function slugify(input) {
  if (typeof input !== "string") {
    throw new TypeError("slugify expects a string");
  }

  return input
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

module.exports = { slugify };
