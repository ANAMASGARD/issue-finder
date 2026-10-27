#!/usr/bin/env node
// Validate the six-skill suite's structural invariants, per AGENTS.md:
// - Exactly the expected skills exist under skills/, no more, no less.
// - Every skill has SKILL.md and agents/openai.yaml.
// - A skill's `name:` frontmatter field equals its directory name.
// - Every skill appears in README.md's reference table, docs/skills/<name>.md,
//   and .claude-plugin/plugin.json's skills array.
// - The two user-invoked skills carry disable-model-invocation and the
//   matching openai.yaml policy; the four model-invoked ones carry neither.
//
// Exits 0 and prints nothing on success. Exits 1 and prints every violation
// found (not just the first) on failure.

import { readFileSync, existsSync, readdirSync } from "node:fs";
import { join } from "node:path";

const ROOT = new URL("..", import.meta.url).pathname;

const EXPECTED_SKILLS = [
  "issue-finder",
  "exploratory-testing",
  "verifying-findings",
  "screening-duplicates",
  "drafting-issues",
  "issue-fixer",
];

const USER_INVOKED = new Set(["issue-finder", "issue-fixer"]);

const errors = [];

function fail(message) {
  errors.push(message);
}

function readText(path) {
  return existsSync(path) ? readFileSync(path, "utf8") : null;
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

// 2-4. Per-skill checks.
for (const skill of EXPECTED_SKILLS) {
  const skillDir = join(skillsDir, skill);
  const skillMdPath = join(skillDir, "SKILL.md");
  const openaiYamlPath = join(skillDir, "agents", "openai.yaml");

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
  }

  const docsPagePath = join(ROOT, "docs", "skills", `${skill}.md`);
  if (!existsSync(docsPagePath)) {
    fail(`docs/skills/${skill}.md is missing`);
  }
}

// 5. README.md reference table.
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

// 6. .claude-plugin/plugin.json skills array.
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
    const declared = (pluginJson.skills ?? []).map((p) => p.replace(/^\.\/skills\//, ""));
    for (const skill of EXPECTED_SKILLS) {
      if (!declared.includes(skill)) {
        fail(`.claude-plugin/plugin.json's "skills" array is missing ./skills/${skill}`);
      }
    }
  }
}

if (errors.length > 0) {
  console.error(`validate-skills: ${errors.length} problem(s) found:\n`);
  for (const message of errors) {
    console.error(`  - ${message}`);
  }
  process.exit(1);
}
