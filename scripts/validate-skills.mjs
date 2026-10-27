#!/usr/bin/env node
// SPDX-License-Identifier: GPL-3.0-only
// Copyright (C) 2026 Gaurav Chaudhary. See NOTICE for required attribution.
//
// Validate the two-skill suite's structural invariants, per AGENTS.md:
// - Exactly issue-finder and issue-fixer exist under skills/.
// - Every skill has SKILL.md, agents/openai.yaml, LICENSE.txt, and NOTICE.
// - A skill's `name:` frontmatter field equals its directory name.
// - issue-finder is user-invoked; issue-fixer is model-invoked.
// - SKILL.md stays under the line caps (finder 100, fixer 80).
// - LICENSE.txt and NOTICE in each skill folder are byte-identical to root.
// - Both skills appear in README.md and .claude-plugin/plugin.json.
// - No em-dashes in repo prose.
//
// Exits 0 and prints nothing on success. Exits 1 and prints every violation
// found (not just the first) on failure.

import { readFileSync, existsSync, readdirSync } from "node:fs";
import { join, relative } from "node:path";

const ROOT = new URL("..", import.meta.url).pathname;

const EXPECTED_SKILLS = ["issue-finder", "issue-fixer"];
const USER_INVOKED = new Set(["issue-finder"]);
const LINE_CAPS = { "issue-finder": 100, "issue-fixer": 80 };
const EM_DASH = "\u2014";

const SKIP_EMDASH_DIRS = new Set([
  "node_modules",
  ".git",
  "evals/fixtures",
  "docs/research",
]);
const SKIP_EMDASH_FILES = new Set(["LICENSE", "LICENSE.txt"]);

const errors = [];

function fail(message) {
  errors.push(message);
}

function readText(path) {
  return existsSync(path) ? readFileSync(path, "utf8") : null;
}

function walk(dir, acc = []) {
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    const full = join(dir, entry.name);
    const rel = relative(ROOT, full);
    if (entry.isDirectory()) {
      if (SKIP_EMDASH_DIRS.has(entry.name) || SKIP_EMDASH_DIRS.has(rel)) continue;
      walk(full, acc);
    } else if (entry.isFile()) {
      acc.push(full);
    }
  }
  return acc;
}

// 1. Directory listing matches expected set exactly.
const skillsDir = join(ROOT, "skills");
const actualSkills = existsSync(skillsDir)
  ? readdirSync(skillsDir, { withFileTypes: true })
      .filter((entry) => entry.isDirectory())
      .map((entry) => entry.name)
      .sort()
  : [];
const expectedSorted = [...EXPECTED_SKILLS].sort();
if (JSON.stringify(actualSkills) !== JSON.stringify(expectedSorted)) {
  fail(
    `skills/ contains ${JSON.stringify(actualSkills)}, expected exactly ${JSON.stringify(expectedSorted)}`,
  );
}

const rootLicense = readText(join(ROOT, "LICENSE"));
const rootNotice = readText(join(ROOT, "NOTICE"));
if (rootLicense === null) fail("LICENSE is missing at repo root");
if (rootNotice === null) fail("NOTICE is missing at repo root");

// 2-4. Per-skill checks.
for (const skill of EXPECTED_SKILLS) {
  const skillDir = join(skillsDir, skill);
  const skillMdPath = join(skillDir, "SKILL.md");
  const openaiYamlPath = join(skillDir, "agents", "openai.yaml");
  const licensePath = join(skillDir, "LICENSE.txt");
  const noticePath = join(skillDir, "NOTICE");

  const skillMd = readText(skillMdPath);
  if (skillMd === null) {
    fail(`skills/${skill}/SKILL.md is missing`);
  } else {
    const nameMatch = skillMd.match(/^name:\s*(.+)$/m);
    if (!nameMatch) {
      fail(`skills/${skill}/SKILL.md has no "name:" frontmatter field`);
    } else if (nameMatch[1].trim() !== skill) {
      fail(
        `skills/${skill}/SKILL.md declares name: ${nameMatch[1].trim()}, expected ${skill}`,
      );
    }

    const licenseMatch = skillMd.match(/^license:\s*(.+)$/m);
    if (!licenseMatch || licenseMatch[1].trim() !== "GPL-3.0-only") {
      fail(`skills/${skill}/SKILL.md must declare license: GPL-3.0-only`);
    }

    const hasDisableFlag = /^disable-model-invocation:\s*true\s*$/m.test(skillMd);
    if (USER_INVOKED.has(skill) && !hasDisableFlag) {
      fail(
        `skills/${skill}/SKILL.md is user-invoked but is missing "disable-model-invocation: true"`,
      );
    }
    if (!USER_INVOKED.has(skill) && hasDisableFlag) {
      fail(
        `skills/${skill}/SKILL.md is model-invoked but sets "disable-model-invocation: true"`,
      );
    }

    const lineCount = skillMd.split(/\r?\n/).length;
    const cap = LINE_CAPS[skill];
    if (cap && lineCount > cap) {
      fail(`skills/${skill}/SKILL.md is ${lineCount} lines, cap is ${cap}`);
    }
  }

  const openaiYaml = readText(openaiYamlPath);
  if (openaiYaml === null) {
    fail(`skills/${skill}/agents/openai.yaml is missing`);
  } else if (USER_INVOKED.has(skill)) {
    if (!/allow_implicit_invocation:\s*false/.test(openaiYaml)) {
      fail(
        `skills/${skill}/agents/openai.yaml is user-invoked but is missing "policy.allow_implicit_invocation: false"`,
      );
    }
  } else if (/allow_implicit_invocation:\s*false/.test(openaiYaml)) {
    fail(
      `skills/${skill}/agents/openai.yaml is model-invoked but sets allow_implicit_invocation: false`,
    );
  }

  const skillLicense = readText(licensePath);
  if (skillLicense === null) {
    fail(`skills/${skill}/LICENSE.txt is missing`);
  } else if (rootLicense !== null && skillLicense !== rootLicense) {
    fail(`skills/${skill}/LICENSE.txt is not byte-identical to the root LICENSE`);
  }

  const skillNotice = readText(noticePath);
  if (skillNotice === null) {
    fail(`skills/${skill}/NOTICE is missing`);
  } else if (rootNotice !== null && skillNotice !== rootNotice) {
    fail(`skills/${skill}/NOTICE is not byte-identical to the root NOTICE`);
  }
}

// 5. README.md mentions both skills.
const readme = readText(join(ROOT, "README.md"));
if (readme === null) {
  fail("README.md is missing");
} else {
  for (const skill of EXPECTED_SKILLS) {
    if (!readme.includes(`\`${skill}\``)) {
      fail(`README.md does not mention \`${skill}\``);
    }
  }
}

// 6. .claude-plugin/plugin.json skills array is exactly the expected set.
const pluginJsonPath = join(ROOT, ".claude-plugin", "plugin.json");
const pluginJsonText = readText(pluginJsonPath);
if (pluginJsonText === null) {
  fail(".claude-plugin/plugin.json is missing");
} else {
  let pluginJson;
  try {
    pluginJson = JSON.parse(pluginJsonText);
  } catch (err) {
    fail(`.claude-plugin/plugin.json is not valid JSON: ${err.message}`);
    pluginJson = null;
  }
  if (pluginJson) {
    const declared = (pluginJson.skills ?? []).map((p) =>
      p.replace(/^\.\/skills\//, ""),
    );
    const declaredSorted = [...declared].sort();
    if (JSON.stringify(declaredSorted) !== JSON.stringify(expectedSorted)) {
      fail(
        `.claude-plugin/plugin.json's "skills" array is ${JSON.stringify(declared)}, expected exactly ${JSON.stringify(EXPECTED_SKILLS)}`,
      );
    }
    if (pluginJson.license !== "GPL-3.0-only") {
      fail(`.claude-plugin/plugin.json license is ${pluginJson.license}, expected GPL-3.0-only`);
    }
  }
}

const packageJsonText = readText(join(ROOT, "package.json"));
if (packageJsonText === null) {
  fail("package.json is missing");
} else {
  const packageJson = JSON.parse(packageJsonText);
  if (packageJson.license !== "GPL-3.0-only") {
    fail(`package.json license is ${packageJson.license}, expected GPL-3.0-only`);
  }
}

// 7. No em-dashes in repo prose.
const proseExt = new Set([".md", ".mjs", ".js", ".sh", ".yml", ".yaml", ".json"]);
for (const file of walk(ROOT)) {
  const name = file.split("/").pop();
  if (SKIP_EMDASH_FILES.has(name)) continue;
  const ext = name.includes(".") ? name.slice(name.lastIndexOf(".")) : "";
  if (!proseExt.has(ext)) continue;
  const text = readText(file);
  if (text && text.includes(EM_DASH)) {
    fail(`${relative(ROOT, file)} contains an em-dash; rewrite with a comma, colon, period, parentheses, or a conjunction`);
  }
}

if (errors.length > 0) {
  console.error(`validate-skills: ${errors.length} problem(s) found:\n`);
  for (const message of errors) {
    console.error(`  - ${message}`);
  }
  process.exit(1);
}
