#!/usr/bin/env node
// SPDX-License-Identifier: GPL-3.0-only
// Copyright (C) 2026 Gaurav Chaudhary. See NOTICE for required attribution.
//
// Copy package.json's version into .claude-plugin/plugin.json and
// .cursor-plugin/plugin.json, so all three agree.
//
// Usage:
//   node scripts/sync-plugin-version.mjs          # writes the sync
//   node scripts/sync-plugin-version.mjs --check  # exits 1 if out of sync, writes nothing

import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const ROOT = new URL("..", import.meta.url).pathname;
const checkOnly = process.argv.includes("--check");

const PACKAGE_JSON_PATH = join(ROOT, "package.json");
const TARGETS = [
  join(ROOT, ".claude-plugin", "plugin.json"),
  join(ROOT, ".cursor-plugin", "plugin.json"),
];

function readJson(path) {
  return JSON.parse(readFileSync(path, "utf8"));
}

const { version } = readJson(PACKAGE_JSON_PATH);
if (!version) {
  console.error("sync-plugin-version: package.json has no version field");
  process.exit(1);
}

let mismatched = false;

for (const targetPath of TARGETS) {
  const raw = readFileSync(targetPath, "utf8");
  const json = JSON.parse(raw);

  if (json.version === version) {
    continue;
  }

  mismatched = true;

  if (checkOnly) {
    console.error(
      `sync-plugin-version: ${targetPath} has version ${json.version}, expected ${version}`,
    );
    continue;
  }

  json.version = version;
  // Preserve key order and trailing newline by re-serializing with the same
  // indentation this repo's JSON files use (2 spaces).
  writeFileSync(targetPath, `${JSON.stringify(json, null, 2)}\n`);
  console.log(`sync-plugin-version: updated ${targetPath} to ${version}`);
}

if (checkOnly && mismatched) {
  console.error(
    "sync-plugin-version: out of sync. Run `node scripts/sync-plugin-version.mjs` to fix.",
  );
  process.exit(1);
}

if (!mismatched) {
  console.log(`sync-plugin-version: all plugin manifests already at ${version}`);
}
