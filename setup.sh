#!/bin/bash
set -euo pipefail

# OpenCode Ultimate Setup Script
# Sets up skills, agents, commands, plugins, and model config
# Usage: curl -fsSL <url>/setup.sh | bash

OPENCODE_DIR="$HOME/.config/opencode"
SKILLS_DIR="$OPENCODE_DIR/skills"
AGENTS_DIR="$OPENCODE_DIR/agents"
COMMANDS_DIR="$OPENCODE_DIR/commands"

echo "=== OpenCode Setup ==="

# Create directories
mkdir -p "$SKILLS_DIR" "$AGENTS_DIR" "$COMMANDS_DIR"

# ---- Config ----
cat > "$OPENCODE_DIR/opencode.jsonc" << 'CONFIGEOF'
{
  "$schema": "https://opencode.ai/config.json",
  "model": "zen/big-pickle",
  "small_model": "zen/big-pickle",
  "plugin": [
    "opencode-skills-collection@latest",
    ["opencode-plugin-preload-skills", {
      "skills": ["c-project", "github-ops", "stop-slop", "systematic-debugging"],
      "fileTypeSkills": {
        ".c": ["c-project"],
        ".h": ["c-project"],
        ".py": ["python-style"],
        ".sh": ["shell-scripting"],
        ".md": ["stop-slop"]
      },
      "pathPatterns": {
        "~/.config/hypr/**": ["hyprland-config"],
        "**/Makefile": ["c-project"],
        "**/*.sh": ["shell-scripting"]
      },
      "contentTriggers": {
        "hyprland": ["hyprland-config"],
        "keybind": ["hyprland-config"],
        "monitor": ["hyprland-config"],
        "wayland": ["hyprland-config"],
        "adb": ["adb-ops"],
        "android": ["adb-ops"],
        "waydroid": ["adb-ops"],
        "compile": ["c-project"],
        "gcc": ["c-project"],
        "valgrind": ["c-project"],
        "github": ["github-ops"],
        "pull request": ["github-ops"],
        "issue": ["github-ops"],
        "workflow": ["github-ops"],
        "release": ["github-ops"],
        "merge": ["github-ops"]
      },
      "groups": {
        "dev-core": ["c-project", "github-ops", "systematic-debugging", "verification-before-completion"],
        "android": ["adb-ops"],
        "desktop": ["hyprland-config"]
      },
      "maxTokens": 8000,
      "showToasts": true,
      "enableTools": true
    }]
  ],
  "skills": {
    "paths": ["~/.config/opencode/skills"]
  },
  "instructions": ["AGENTS.md"],
  "permission": {
    "bash": {
      "git *": "allow",
      "ls *": "allow",
      "cat *": "allow",
      "find *": "allow",
      "grep *": "allow",
      "mkdir *": "allow",
      "cp *": "allow",
      "mv *": "allow",
      "rm -rf *": "ask",
      "*": "ask"
    },
    "edit": "allow",
    "read": "allow",
    "glob": "allow",
    "grep": "allow",
    "webfetch": "allow",
    "websearch": "allow"
  }
}
CONFIGEOF

# ---- AGENTS.md ----
cat > "$OPENCODE_DIR/AGENTS.md" << 'AGENTSEOF'
# Global Agent Instructions

## User Profile
- Arch Linux power user on Hyprland (Wayland)
- Languages: C, Python, Bash
- Interests: Android modding (ADB, Waydroid), media tools, gaming, CLI utilities
- Uses: kew, cmus, cava, media-picker, ani-cli, stremio

## Core Rules

### Code Style
- C: Follow Linux kernel style (tabs=8, K&R braces, snake_case)
- Python: PEP 8, f-strings, type hints where useful
- Bash: ShellCheck-clean, `set -euo pipefail`, quote variables
- Config files: Comment non-obvious changes

### Workflow
- Use `systematic-debugging` skill for bugs (reproduce → isolate → diagnose → verify)
- Use `verification-before-completion` before marking anything done
- Use `writing-plans` for tasks taking more than 5 minutes
- Ask clarifying questions before ambiguous implementations

### Hyprland / Wayland
- Config lives at `~/.config/hypr/hyprland.conf`
- Test binds with `hyprctl dispatch` before committing
- Use `hyprctl reload` after config changes
- Monitor input switching: `ddcutil setvcp 60 <value>`

### ADB / Android
- Always check `adb devices` before operations
- Use `adb push`/`adb pull` for file transfers
- Waydroid sessions: start/stop with `waydroid session start/stop`

### Safety
- Never commit API keys, tokens, or secrets
- Ask before `rm -rf` or destructive operations
- Verify backups before system-level changes
- Use `sudo` sparingly; explain when required

### Communication
- Be concise. No preamble ("Here is...", "I will now...")
- Reference code with `file:line` format
- One-word answers when possible
- No emojis unless requested

## Skill Usage
- Invoke relevant skills proactively when the task matches
- Use `ask-questions-if-underspecified` before vague requirements
- Use `caveman` output mode when token efficiency matters
- Use `stop-slop` on any prose or documentation output

## Project Context
- `~/projects/captive-chat` - Python captive portal chat system
- `~/projects/stremiop` - Stremio-related project
- `~/projects/dtn-mesh` - Delay-tolerant networking mesh
- C files in `~/projects/` for quick experiments
AGENTSEOF

# ---- Custom Skills ----

# hyprland-config
mkdir -p "$SKILLS_DIR/hyprland-config"
cat > "$SKILLS_DIR/hyprland-config/SKILL.md" << 'SKILLEOF'
---
name: hyprland-config
description: Use when editing Hyprland config, adding keybinds, monitoring setup, or debugging Wayland issues. Trigger keywords: hyprland, keybind, monitor, wayland, hyprctl, ddcutil.
---

# Hyprland Configuration Skill

## Config Location
- Main config: `~/.config/hypr/hyprland.conf`
- Backups: `~/.backup_hyprconf-charan/`

## Key Commands
- Reload config: `hyprctl reload`
- Test bind: `hyprctl dispatch <dispatcher>`
- Monitor input switch: `ddcutil setvcp 60 <value>`
  - `0x0F` = DisplayPort
  - `0x11` = HDMI 1

## Config Patterns
```bash
# Keybind format
bind = $mainMod, KEY, exec, COMMAND

# Monitor config
monitor = NAME, RESOLUTION@RATE, POSITION, SCALE

# Window rules
windowrulev2 = float, class:^(NAME)$
```

## Common Tasks
1. Adding a keybind: Append to `~/.config/hypr/hyprland.conf`
2. After editing: Run `hyprctl reload`
3. Testing: Use `hyprctl dispatch` to verify dispatcher works

## Safety
- Always backup before major changes
- Test one change at a time
- Keep a working fallback config
SKILLEOF

# adb-ops
mkdir -p "$SKILLS_DIR/adb-ops"
cat > "$SKILLS_DIR/adb-ops/SKILL.md" << 'SKILLEOF'
---
name: adb-ops
description: Use when working with Android devices via ADB, Waydroid, file transfers, or app installation. Trigger keywords: adb, android, waydroid, push, pull, install, device.
---

# ADB / Android Operations

## Prerequisites
- Always run `adb devices` first to verify connection
- Ensure device is in correct mode (USB debugging enabled)

## Core Commands
```bash
# Device management
adb devices                    # List connected devices
adb -s <serial> shell          # Shell into specific device

# File transfer
adb push <local> <remote>      # Push file to device
adb pull <remote> <local>      # Pull file from device

# App management
adb install <apk>              # Install APK
adb uninstall <package>        # Uninstall app
adb shell pm list packages     # List installed packages

# Session management
adb forward tcp:<local> tcp:<remote>  # Port forwarding
adb reverse tcp:<local> tcp:<remote>  # Reverse forwarding
```

## Waydroid
```bash
# Session management
waydroid session start
waydroid session stop
waydroid show-full-ui

# App management
waydroid app install <apk>
waydroid app list
```

## Safety
- Verify device connection before operations
- Use `adb pull` to backup before destructive changes
- Check `adb devices` after each major operation
SKILLEOF

# c-project
mkdir -p "$SKILLS_DIR/c-project"
cat > "$SKILLS_DIR/c-project/SKILL.md" << 'SKILLEOF'
---
name: c-project
description: Use when working with C code, compiling, debugging, or setting up C projects. Trigger keywords: gcc, compile, debug, c, makefile, valgrind.
---

# C Project Management

## Code Style (Linux Kernel)
- Tabs = 8 spaces
- K&R brace style
- snake_case for functions/variables
- UPPER_CASE for macros/constants
- Functions limited to one screen

## Compile & Run
```bash
# Simple compile
gcc -Wall -Wextra -o <output> <source.c>

# With debug symbols
gcc -g -Wall -Wextra -o <output> <source.c>

# Optimization levels
gcc -O2 -o <output> <source.c>

# Run
./<output>
```

## Debugging
```bash
# GDB
gcc -g -o <output> <source.c>
gdb ./<output>

# Valgrind (memory checking)
valgrind --leak-check=full ./<output>

# AddressSanitizer
gcc -fsanitize=address -g -o <output> <source.c>
```

## Project Structure
```
project/
├── src/           # Source files
├── include/       # Headers
├── Makefile       # Build system
└── README.md      # Documentation
```

## Common Patterns
- Always check return values
- Free allocated memory
- Use `const` where possible
- Include header guards
SKILLEOF

# github-ops
mkdir -p "$SKILLS_DIR/github-ops"
cat > "$SKILLS_DIR/github-ops/SKILL.md" << 'SKILLEOF'
---
name: github-ops
description: Use when working with GitHub repos, PRs, issues, releases, or Actions. Trigger keywords: gh, github, pr, issue, release, workflow, actions, fork, clone.
---

# GitHub Operations (gh CLI)

## Setup
```bash
gh auth login                    # Interactive auth
gh auth status                   # Check who you're logged in as
gh config set editor vim         # Set default editor
gh config set git_protocol ssh   # Use SSH for git ops
```

## Repos
```bash
gh repo clone owner/repo         # Clone
gh repo create NAME --public --source=. --push  # Create from current dir
gh repo fork owner/repo --clone  # Fork + clone
gh repo view                     # View in terminal
gh repo view --web               # Open in browser
gh repo sync                     # Sync fork with upstream
gh repo list --limit 20          # List repos
```

## Pull Requests
```bash
gh pr create --fill              # Create from commits
gh pr create --draft             # Draft PR
gh pr list                       # List open PRs
gh pr list --author @me          # My PRs
gh pr list --reviewer @me        # PRs needing my review
gh pr checkout 42                # Checkout PR branch locally
gh pr diff 42                    # See changes
gh pr checks 42 --watch          # Watch CI live
gh pr review 42 --approve        # Approve
gh pr review 42 --request-changes --body "Needs X"
gh pr merge 42 --squash --delete-branch  # Merge + cleanup
gh pr merge 42 --auto --squash   # Auto-merge when checks pass
```

## Issues
```bash
gh issue create --title "Bug: X" --body "Description" --label bug
gh issue list                    # List issues
gh issue list --assignee @me     # My issues
gh issue list --label bug        # Filter by label
gh issue view 17                 # View issue
gh issue close 17 --comment "Fixed in #42"
```

## Actions / CI
```bash
gh workflow list                 # List workflows
gh workflow run deploy.yml       # Trigger manually
gh run list --workflow ci.yml --limit 5
gh run watch RUN_ID              # Stream logs live
gh run rerun RUN_ID --failed     # Retry failed only
```

## Releases
```bash
gh release create v1.0.0 --generate-notes dist/*.tar.gz
gh release list
```

## Aliases
```bash
gh alias set prs 'pr list --author @me'
gh alias set mybugs 'issue list --label bug --assignee @me'
gh alias set ship '!gh pr review $1 --approve && gh pr merge $1 --squash --delete-branch' -s
```

## Gotchas
- `gh` uses `GH_TOKEN` first, falls back to `GITHUB_TOKEN`
- SSO orgs need separate token auth: `gh auth refresh -s read:org`
- Don't use `apt install gh` on Debian - wrong package
SKILLEOF

# ---- Agents ----

# review agent
cat > "$AGENTS_DIR/review.md" << 'AGENTEOF'
---
description: Reviews code for bugs, style issues, and potential improvements
mode: subagent
permission:
  edit: deny
  bash: deny
---

You are a code reviewer. Analyze the code for:
1. Bugs and logic errors
2. Style violations (Linux kernel style for C, PEP 8 for Python)
3. Security issues
4. Performance problems
5. Missing error handling

Report findings concisely with file:line references. Do not make changes.
AGENTEOF

# debug agent
cat > "$AGENTS_DIR/debug.md" << 'AGENTEOF'
---
description: Helps debug issues systematically
mode: subagent
permission:
  edit: deny
  bash: ask
---

You are a debugger. Follow this process:
1. Understand the expected vs actual behavior
2. Identify minimal reproduction steps
3. Isolate the problem to specific code
4. Propose a fix with verification steps

Never guess. Ask for more info if unclear. Reference file:line for all findings.
AGENTEOF

# ---- Commands ----

# /learn
cat > "$COMMANDS_DIR/learn.md" << 'CMDEOF'
---
description: Save a lesson learned to AGENTS.md
---

The user wants to save a lesson learned. Take what they said and write it as a concise, actionable instruction to the appropriate AGENTS.md file (project-level if in a project, global otherwise).

Format: short rule, not a story. Example: "Use `set -euo pipefail` in all bash scripts."
CMDEOF

# /finish-work
cat > "$COMMANDS_DIR/finish-work.md" << 'CMDEOF'
---
description: Final pre-commit quality gate
---

Run these checks before committing:
1. Code compiles/runs without errors
2. No debug prints or TODOs left behind
3. Error handling is present
4. No secrets or keys in code
5. If C: no memory leaks (valgrind if applicable)
6. If Python: no unused imports
7. Run any existing linter/formatter

Report pass/fail for each item. Do not commit automatically.
CMDEOF

# /session-summary
cat > "$COMMANDS_DIR/session-summary.md" << 'CMDEOF'
---
description: Summarize current session for handoff
---

Create a brief session summary:
1. What was accomplished
2. What's in progress (if anything)
3. Key decisions made
4. Next steps
5. Any blockers or issues

Keep it short and actionable. Format as markdown.
CMDEOF

# /custom-skill
cat > "$COMMANDS_DIR/custom-skill.md" << 'CMDEOF'
---
description: Auto-generate a skill by researching the current task online
---

The user wants to create a custom skill based on what they're currently working on. Take their input ($ARGUMENTS) or infer from the current task context.

Steps:
1. Search the web for best practices, common commands, gotchas, and workflows related to the topic
2. Synthesize findings into a SKILL.md file
3. Write it to `~/.config/opencode/skills/<skill-name>/SKILL.md`
4. Use this structure:

```
---
name: <kebab-case-name>
description: Use when [trigger condition]. Trigger keywords: [comma-separated keywords].
---

# <Skill Title>

## <Section>
(content)

## Common Commands
(code blocks with commands)

## Safety
(warnings and best practices)
```

Rules:
- Keep it concise. Max 150 lines.
- Focus on commands, patterns, and gotchas - not theory
- Include real examples from web research
- Always add a Safety section
- Confirm to user: "Created skill `<name>` at `~/.config/opencode/skills/<name>/SKILL.md` - restart opencode to load it"
CMDEOF

# ---- Package.json ----
cat > "$OPENCODE_DIR/package.json" << 'PKGEOF'
{
  "dependencies": {
    "@opencode-ai/plugin": "1.15.13",
    "opencode-skills-collection": "latest",
    "opencode-plugin-preload-skills": "latest"
  }
}
PKGEOF

# Install plugin dependencies
echo "Installing plugin dependencies..."
(cd "$OPENCODE_DIR" && npm install 2>/dev/null) || true

echo ""
echo "=== Setup Complete ==="
echo "Restart opencode to load changes."
echo ""
echo "Installed:"
echo "  Config:   ~/.config/opencode/opencode.jsonc"
echo "  Skills:   ~/.config/opencode/skills/ (4 custom + 1595 from collection)"
echo "  Agents:   ~/.config/opencode/agents/ (review, debug)"
echo "  Commands: ~/.config/opencode/commands/ (/learn, /finish-work, /session-summary, /custom-skill)"
echo "  Model:    zen/big-pickle (free)"
echo ""
echo "Auto-loaded skills at start: c-project, github-ops, stop-slop, systematic-debugging"
echo "On-demand: hyprland-config, adb-ops (by keyword triggers)"
