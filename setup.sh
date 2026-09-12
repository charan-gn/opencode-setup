#!/bin/bash
set -euo pipefail

# OpenCode Smart Setup
# Audits user history, installs relevant skills, themes, and config
# Usage: curl -fsSL <url>/setup.sh | bash

OPENCODE_DIR="$HOME/.config/opencode"
SKILLS_DIR="$OPENCODE_DIR/skills"
AGENTS_DIR="$OPENCODE_DIR/agents"
COMMANDS_DIR="$OPENCODE_DIR/commands"
THEMES_DIR="$OPENCODE_DIR/themes"
HISTORY="$HOME/.bash_history"

echo "=== OpenCode Smart Setup ==="
echo ""

# ---- Detect user workflow from history ----
echo "[1/6] Auditing your workflow..."

detect() {
  grep -qi "$1" "$HISTORY" 2>/dev/null && echo "yes" || echo "no"
}

HAS_PYTHON=$(detect "python\|pip\|venv\|django\|flask\|fastapi")
HAS_C=$(detect "gcc\|gdb\|valgrind\|make\|cmake\|\.c\b")
HAS_BASH=$(detect "bash\|shellcheck\|shfmt\|#!/bin/bash")
HAS_NODE=$(detect "node\|npm\|yarn\|pnpm\|bun\|deno\|typescript")
HAS_RUST=$(detect "cargo\|rustc\|rustup")
HAS_GO=$(detect "go build\|go run\|golang")
HAS_DOCKER=$(detect "docker\|docker-compose\|podman\|container")
HAS_GIT=$(detect "git\|github\|gh\b")
HAS_HYPRLAND=$(detect "hyprland\|hyprctl\|wayland\|wlroots")
HAS_ADB=$(detect "adb\|waydroid\|android\|scrcpy")
HAS_NEOVIM=$(detect "nvim\|neovim\|vim")
HAS_TMUX=$(detect "tmux")
HAS_FISH=$(detect "fish")
HAS_ZSH=$(detect "zsh")
HAS_I3=$(detect "i3\|sway")
HAS_KDE=$(detect "kde\|plasma\|kwin")
HAS_GNOME=$(detect "gnome\|gnome-shell")
HAS='".$_" | head -1 > /dev/null 2>&1 && HAS_ARCH=$(detect "pacman\|yay\|paru\|makepkg") || HAS_ARCH=$(detect "pacman\|yay\|paru")
HAS_DEBIAN=$(detect "apt\|dpkg\|debian")
HAS_FEDORA=$(detect "dnf\|yum\|fedora")
HAS_MEDIA=$(detect "kew\|cmus\|cava\|mpv\|yt-dlp\|ffmpeg")
HAS_GAMING=$(detect "steam\|proton\|wine\|lutris\|mangohud")
HAS(download)" && HAS_DOWNLOAD=1 || HAS_DOWNLOAD=0
HAS_CURL=$(detect "curl\|wget\|aria2c")
HAS_SECURITY=$(detect "nmap\|burp\|sqlmap\|nikto\|metasploit")
HAS_DATA=$(detect "jupyter\|pandas\|numpy\|matplotlib\|tensorflow\|pytorch")
HAS_WEBDEV=$(detect "react\|vue\|angular\|svelte\|next\|nuxt\|tailwind")
HAS_API=$(detect "fastapi\|flask\|django\|express\|gin\|axum")

echo "  Python:       $HAS_PYTHON"
echo "  C:            $HAS_C"
echo "  Bash:         $HAS_BASH"
echo "  Node.js:      $HAS_NODE"
echo "  Rust:         $HAS_RUST"
echo "  Go:           $HAS_GO"
echo "  Docker:       $HAS_DOCKER"
echo "  Git/GitHub:   $HAS_GIT"
echo "  Hyprland:     $HAS_HYPRLAND"
echo "  ADB/Android:  $HAS_ADB"
echo "  Neovim:       $HAS_NEOVIM"
echo "  Tmux:         $HAS_TMUX"
echo "  Arch Linux:   $HAS_ARCH"
echo "  Media tools:  $HAS_MEDIA"
echo "  Gaming:       $HAS_GAMING"
echo "  Security:     $HAS_SECURITY"
echo "  Data/ML:      $HAS_DATA"
echo "  Web dev:      $HAS_WEBDEV"
echo ""

# ---- Build dynamic skill list ----
echo "[2/6] Building skill configuration..."

ALWAYS_LOAD="stop-slop systematic-debugging"
FILE_TRIGGERS=""
PATH_TRIGGERS=""
CONTENT_TRIGGERS=""
GROUPS=""

# Language skills
if [ "$HAS_PYTHON" = "yes" ]; then
  ALWAYS_LOAD="$ALWAYS_LOAD python-style"
  FILE_TRIGGERS="$FILE_TRIGGERS
        \".py\": [\"python-style\"],"
  CONTENT_TRIGGERS="$CONTENT_TRIGGERS
        \"python\": [\"python-style\"],
        \"pip\": [\"python-style\"],
        \"django\": [\"python-style\"],
        \"flask\": [\"python-style\"],
        \"fastapi\": [\"python-style\"],"
fi

if [ "$HAS_C" = "yes" ]; then
  ALWAYS_LOAD="$ALWAYS_LOAD c-project"
  FILE_TRIGGERS="$FILE_TRIGGERS
        \".c\": [\"c-project\"],
        \".h\": [\"c-project\"],"
  PATH_TRIGGERS="$PATH_TRIGGERS
        \"**/Makefile\": [\"c-project\"],"
  CONTENT_TRIGGERS="$CONTENT_TRIGGERS
        \"gcc\": [\"c-project\"],
        \"valgrind\": [\"c-project\"],
        \"gdb\": [\"c-project\"],
        \"compile\": [\"c-project\"],"
fi

if [ "$HAS_BASH" = "yes" ]; then
  ALWAYS_LOAD="$ALWAYS_LOAD shell-scripting"
  FILE_TRIGGERS="$FILE_TRIGGERS
        \".sh\": [\"shell-scripting\"],"
  PATH_TRIGGERS="$PATH_TRIGGERS
        \"**/*.sh\": [\"shell-scripting\"],"
fi

if [ "$HAS_NODE" = "yes" ]; then
  ALWAYS_LOAD="$ALWAYS_LOAD nodejs"
  CONTENT_TRIGGERS="$CONTENT_TRIGGERS
        \"npm\": [\"nodejs\"],
        \"node\": [\"nodejs\"],
        \"typescript\": [\"nodejs\"],
        \"bun\": [\"nodejs\"],"
fi

if [ "$HAS_RUST" = "yes" ]; then
  ALWAYS_LOAD="$ALWAYS_LOAD rust"
  CONTENT_TRIGGERS="$CONTENT_TRIGGERS
        \"cargo\": [\"rust\"],
        \"rust\": [\"rust\"],
        \"rustc\": [\"rust\"],"
fi

if [ "$HAS_GO" = "yes" ]; then
  ALWAYS_LOAD="$ALWAYS_LOAD golang"
  CONTENT_TRIGGERS="$CONTENT_TRIGGERS
        \"go build\": [\"golang\"],
        \"golang\": [\"golang\"],"
fi

# Tool skills
if [ "$HAS_DOCKER" = "yes" ]; then
  ALWAYS_LOAD="$ALWAYS_LOAD docker"
  CONTENT_TRIGGERS="$CONTENT_TRIGGERS
        \"docker\": [\"docker\"],
        \"container\": [\"docker\"],
        \"podman\": [\"docker\"],"
fi

if [ "$HAS_GIT" = "yes" ]; then
  ALWAYS_LOAD="$ALWAYS_LOAD github-ops"
  CONTENT_TRIGGERS="$CONTENT_TRIGGERS
        \"github\": [\"github-ops\"],
        \"pull request\": [\"github-ops\"],
        \"issue\": [\"github-ops\"],
        \"workflow\": [\"github-ops\"],
        \"release\": [\"github-ops\"],
        \"merge\": [\"github-ops\"],"
fi

if [ "$HAS_HYPRLAND" = "yes" ]; then
  FILE_TRIGGERS="$FILE_TRIGGERS
        \".c\": [\"c-project\"],
        \".h\": [\"c-project\"],"
  PATH_TRIGGERS="$PATH_TRIGGERS
        \"~/.config/hypr/**\": [\"hyprland-config\"],"
  CONTENT_TRIGGERS="$CONTENT_TRIGGERS
        \"hyprland\": [\"hyprland-config\"],
        \"keybind\": [\"hyprland-config\"],
        \"monitor\": [\"hyprland-config\"],
        \"wayland\": [\"hyprland-config\"],"
  ALWAYS_LOAD="$ALWAYS_LOAD hyprland-config"
fi

if [ "$HAS_ADB" = "yes" ]; then
  CONTENT_TRIGGERS="$CONTENT_TRIGGERS
        \"adb\": [\"adb-ops\"],
        \"android\": [\"adb-ops\"],
        \"waydroid\": [\"adb-ops\"],
        \"scrcpy\": [\"adb-ops\"],"
  ALWAYS_LOAD="$ALWAYS_LOAD adb-ops"
fi

if [ "$HAS_NEOVIM" = "yes" ]; then
  ALWAYS_LOAD="$ALWAYS_LOAD neovim"
  CONTENT_TRIGGERS="$CONTENT_TRIGGERS
        \"nvim\": [\"neovim\"],
        \"neovim\": [\"neovim\"],
        \"vim\": [\"neovim\"],"
fi

if [ "$HAS_TMUX" = "yes" ]; then
  ALWAYS_LOAD="$ALWAYS_LOAD tmux"
  CONTENT_TRIGGERS="$CONTENT_TRIGGERS
        \"tmux\": [\"tmux\"],"
fi

if [ "$HAS_MEDIA" = "yes" ]; then
  ALWAYS_LOAD="$ALWAYS_LOAD media-tools"
fi

if [ "$HAS_SECURITY" = "yes" ]; then
  ALWAYS_LOAD="$ALWAYS_LOAD security-audit"
fi

if [ "$HAS_DATA" = "yes" ]; then
  ALWAYS_LOAD="$ALWAYS_LOAD data-science"
fi

if [ "$HAS_WEBDEV" = "yes" ]; then
  ALWAYS_LOAD="$ALWAYS_LOAD web-development"
fi

if [ "$HAS_API" = "yes" ]; then
  ALWAYS_LOAD="$ALWAYS_LOAD api-design"
fi

# Build groups
GROUPS="
        \"dev-core\": [\"c-project\", \"github-ops\", \"systematic-debugging\", \"verification-before-completion\"],"
[ "$HAS_PYTHON" = "yes" ] && GROUPS="$GROUPS
        \"python-dev\": [\"python-style\", \"github-ops\"],"
[ "$HAS_DOCKER" = "yes" ] && GROUPS="$GROUPS
        \"devops\": [\"docker\", \"github-ops\"],"
[ "$HAS_HYPRLAND" = "yes" ] && GROUPS="$GROUPS
        \"desktop\": [\"hyprland-config\", \"neovim\"],"
[ "$HAS_ADB" = "yes" ] && GROUPS="$GROUPS
        \"android\": [\"adb-ops\"]"

# ---- Create directories ----
mkdir -p "$SKILLS_DIR" "$AGENTS_DIR" "$COMMANDS_DIR" "$THEMES_DIR"

# ---- Write config ----
echo "[3/6] Writing config..."

cat > "$OPENCODE_DIR/opencode.jsonc" << CONFIGEOF
{
  "\$schema": "https://opencode.ai/config.json",
  "model": "zen/big-pickle",
  "small_model": "zen/big-pickle",
  "plugin": [
    "opencode-skills-collection@latest",
    ["opencode-plugin-preload-skills", {
      "skills": [$(echo "$ALWAYS_LOAD" | sed 's/ /", "/g' | sed 's/^/"/' | sed 's/$/"/')],
      "fileTypeSkills": {$(echo "$FILE_TRIGGERS" | sed '/^$/d')},
      "pathPatterns": {$(echo "$PATH_TRIGGERS" | sed '/^$/d')},
      "contentTriggers": {$(echo "$CONTENT_TRIGGERS" | sed '/^$/d')},
      "groups": {$(echo "$GROUPS" | sed '/^$/d')},
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

# ---- Write TUI config (theme) ----
echo "[4/6] Setting theme..."

cat > "$OPENCODE_DIR/tui.json" << 'THEMEEOF'
{
  "$schema": "https://opencode.ai/tui.json",
  "theme": "catppuccin"
}
THEMEEOF

# ---- Write AGENTS.md ----
echo "[5/6] Writing agent instructions..."

cat > "$OPENCODE_DIR/AGENTS.md" << 'AGENTSEOF'
# Global Agent Instructions

## User Profile
Detected from system history. Update this file with your specifics.

## Core Rules

### Code Style
- C: Linux kernel style (tabs=8, K&R braces, snake_case)
- Python: PEP 8, f-strings, type hints
- Bash: ShellCheck-clean, `set -euo pipefail`, quote variables
- Rust: rustfmt defaults
- Go: gofmt defaults
- Config files: Comment non-obvious changes

### Workflow
- Use `systematic-debugging` for bugs (reproduce → isolate → diagnose → verify)
- Use `verification-before-completion` before marking anything done
- Use `writing-plans` for tasks > 5 minutes
- Ask clarifying questions before ambiguous implementations

### Safety
- Never commit API keys, tokens, or secrets
- Ask before `rm -rf` or destructive operations
- Verify backups before system-level changes
- Use `sudo` sparingly; explain when required

### Communication
- Be concise. No preamble.
- Reference code with `file:line` format
- One-word answers when possible
- No emojis unless requested

## Skill Usage
- Invoke relevant skills proactively when the task matches
- Use `caveman` output mode when token efficiency matters
- Use `stop-slop` on any prose or documentation output
AGENTSEOF

# ---- Write Custom Skills ----

# hyprland-config
mkdir -p "$SKILLS_DIR/hyprland-config"
cat > "$SKILLS_DIR/hyprland-config/SKILL.md" << 'SKILLEOF'
---
name: hyprland-config
description: Use when editing Hyprland config, adding keybinds, monitoring setup, or debugging Wayland issues. Trigger keywords: hyprland, keybind, monitor, wayland, hyprctl, ddcutil.
---

# Hyprland Configuration

## Commands
- Reload: `hyprctl reload`
- Test bind: `hyprctl dispatch <dispatcher>`
- Monitor input: `ddcutil setvcp 60 <value>` (0x0F=DP, 0x11=HDMI1)

## Config Pattern
```
bind = $mainMod, KEY, exec, COMMAND
monitor = NAME, RESOLUTION@RATE, POSITION, SCALE
windowrulev2 = float, class:^(NAME)$
```

## Safety
- Backup before changes
- Test one change at a time
SKILLEOF

# adb-ops
mkdir -p "$SKILLS_DIR/adb-ops"
cat > "$SKILLS_DIR/adb-ops/SKILL.md" << 'SKILLEOF'
---
name: adb-ops
description: Use when working with Android devices via ADB, Waydroid, file transfers, or app installation. Trigger keywords: adb, android, waydroid, push, pull, install, device.
---

# ADB / Android Operations

## Core
```bash
adb devices                    # List devices
adb push <local> <remote>      # Push file
adb pull <remote> <local>      # Pull file
adb install <apk>              # Install APK
```

## Waydroid
```bash
waydroid session start/stop
waydroid app install <apk>
```

## Safety
- Verify connection first
- Backup before destructive changes
SKILLEOF

# c-project
mkdir -p "$SKILLS_DIR/c-project"
cat > "$SKILLS_DIR/c-project/SKILL.md" << 'SKILLEOF'
---
name: c-project
description: Use when working with C code, compiling, debugging, or setting up C projects. Trigger keywords: gcc, compile, debug, c, makefile, valgrind.
---

# C Project Management

## Style
- Tabs=8, K&R braces, snake_case, UPPER_CASE macros

## Compile
```bash
gcc -Wall -Wextra -g -o out src.c
valgrind --leak-check=full ./out
gcc -fsanitize=address -g -o out src.c
```

## Safety
- Check return values
- Free allocated memory
- Use const where possible
SKILLEOF

# github-ops
mkdir -p "$SKILLS_DIR/github-ops"
cat > "$SKILLS_DIR/github-ops/SKILL.md" << 'SKILLEOF'
---
name: github-ops
description: Use when working with GitHub repos, PRs, issues, releases, or Actions. Trigger keywords: gh, github, pr, issue, release, workflow, actions, fork, clone.
---

# GitHub CLI (gh)

## PRs
```bash
gh pr create --fill
gh pr checkout 42
gh pr checks 42 --watch
gh pr merge 42 --squash --delete-branch
```

## Issues
```bash
gh issue create --title "X" --body "Y" --label bug
gh issue list --assignee @me
```

## Aliases
```bash
gh alias set prs 'pr list --author @me'
gh alias set ship '!gh pr review $1 --approve && gh pr merge $1 --squash --delete-branch' -s
```
SKILLEOF

# ---- Write Agents ----
cat > "$AGENTS_DIR/review.md" << 'AGENTEOF'
---
description: Reviews code for bugs, style issues, and potential improvements
mode: subagent
permission:
  edit: deny
  bash: deny
---

Code reviewer. Check for: bugs, style violations, security issues, performance problems, missing error handling. Report with file:line references. Do not make changes.
AGENTEOF

cat > "$AGENTS_DIR/debug.md" << 'AGENTEOF'
---
description: Helps debug issues systematically
mode: subagent
permission:
  edit: deny
  bash: ask
---

Debugger. Process: understand expected vs actual → minimal reproduction → isolate problem → propose fix with verification. Never guess. Reference file:line.
AGENTEOF

# ---- Write Commands ----
cat > "$COMMANDS_DIR/learn.md" << 'CMDEOF'
---
description: Save a lesson learned to AGENTS.md
---
Take what the user said and write it as a concise, actionable instruction to AGENTS.md. Short rule, not a story.
CMDEOF

cat > "$COMMANDS_DIR/finish-work.md" << 'CMDEOF'
---
description: Final pre-commit quality gate
---
Check: compiles, no debug prints, error handling present, no secrets, no unused imports, linter passes. Report pass/fail per item.
CMDEOF

cat > "$COMMANDS_DIR/session-summary.md" << 'CMDEOF'
---
description: Summarize current session for handoff
---
Brief summary: what got done, what's in progress, key decisions, next steps, blockers. Short and actionable.
CMDEOF

cat > "$COMMANDS_DIR/custom-skill.md" << 'CMDEOF'
---
description: Auto-generate a skill by researching the current task online
---
Research the topic online, synthesize into a SKILL.md at ~/.config/opencode/skills/<name>/SKILL.md. Structure: name, description with trigger keywords, sections for commands/patterns/gotchas, safety section. Max 150 lines. Confirm creation to user.
CMDEOF

# ---- Write package.json ----
cat > "$OPENCODE_DIR/package.json" << 'PKGEOF'
{
  "dependencies": {
    "@opencode-ai/plugin": "1.15.13",
    "opencode-skills-collection": "latest",
    "opencode-plugin-preload-skills": "latest"
  }
}
PKGEOF

# ---- Install dependencies ----
echo "[6/6] Installing plugin dependencies..."
(cd "$OPENCODE_DIR" && npm install 2>/dev/null) || true

# ---- Summary ----
echo ""
echo "=== Setup Complete ==="
echo ""
echo "Skills auto-loaded at start: $(echo $ALWAYS_LOAD | wc -w) skills"
echo "  $ALWAYS_LOAD"
echo ""
echo "Theme: catppuccin"
echo "Model: zen/big-pickle (free)"
echo ""
echo "Restart opencode to load changes."
