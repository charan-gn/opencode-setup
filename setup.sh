#!/bin/bash
set -euo pipefail

# OpenCode Smart Setup
# Audits user history, installs relevant skills, themes, and config
# Usage: curl -fsSL <url>/setup.sh | bash
# Re-audit: op-u

OPENCODE_DIR="$HOME/.config/opencode"
SKILLS_DIR="$OPENCODE_DIR/skills"
AGENTS_DIR="$OPENCODE_DIR/agents"
COMMANDS_DIR="$OPENCODE_DIR/commands"
THEMES_DIR="$OPENCODE_DIR/themes"
HISTORY="$HOME/.bash_history"
BIN_DIR="$HOME/.local/bin"

# ---- Detect user workflow from history ----
audit_history() {
  detect() { grep -qi "$1" "$HISTORY" 2>/dev/null && echo "yes" || echo "no"; }

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
  HAS_MEDIA=$(detect "kew\|cmus\|cava\|mpv\|yt-dlp\|ffmpeg")
  HAS_SECURITY=$(detect "nmap\|burp\|sqlmap\|nikto\|metasploit")
  HAS_DATA=$(detect "jupyter\|pandas\|numpy\|matplotlib\|tensorflow\|pytorch")
  HAS_WEBDEV=$(detect "react\|vue\|angular\|svelte\|next\|nuxt\|tailwind")
  HAS_API=$(detect "fastapi\|flask\|django\|express\|gin\|axum")
}

# ---- Generate config with Python ----
generate_config() {
  python3 -c "
import json, sys

skills = ['stop-slop', 'systematic-debugging']
file_triggers = {}
path_triggers = {}
content_triggers = {}
groups = {}

skills_extra = {
    'python': ('python-style', {'.py': ['python-style']}, {'python': ['python-style'], 'pip': ['python-style'], 'django': ['python-style'], 'flask': ['python-style'], 'fastapi': ['python-style']}, {}),
    'c': ('c-project', {'.c': ['c-project'], '.h': ['c-project']}, {'gcc': ['c-project'], 'valgrind': ['c-project'], 'gdb': ['c-project'], 'compile': ['c-project']}, {'**/Makefile': ['c-project']}),
    'bash': ('shell-scripting', {'.sh': ['shell-scripting']}, {}, {'**/*.sh': ['shell-scripting']}),
    'node': ('nodejs', {}, {'npm': ['nodejs'], 'node': ['nodejs'], 'typescript': ['nodejs'], 'bun': ['nodejs']}, {}),
    'rust': ('rust', {}, {'cargo': ['rust'], 'rust': ['rust'], 'rustc': ['rust']}, {}),
    'go': ('golang', {}, {'go build': ['golang'], 'golang': ['golang']}, {}),
    'docker': ('docker', {}, {'docker': ['docker'], 'container': ['docker'], 'podman': ['docker']}, {}),
    'git': ('github-ops', {}, {'github': ['github-ops'], 'pull request': ['github-ops'], 'issue': ['github-ops'], 'workflow': ['github-ops'], 'release': ['github-ops'], 'merge': ['github-ops']}, {}),
    'hyprland': ('hyprland-config', {}, {'hyprland': ['hyprland-config'], 'keybind': ['hyprland-config'], 'monitor': ['hyprland-config'], 'wayland': ['hyprland-config']}, {'~/.config/hypr/**': ['hyprland-config']}),
    'adb': ('adb-ops', {}, {'adb': ['adb-ops'], 'android': ['adb-ops'], 'waydroid': ['adb-ops'], 'scrcpy': ['adb-ops']}, {}),
    'neovim': ('neovim', {}, {'nvim': ['neovim'], 'neovim': ['neovim'], 'vim': ['neovim']}, {}),
    'tmux': ('tmux', {}, {'tmux': ['tmux']}, {}),
    'media': ('media-tools', {}, {}, {}),
    'security': ('security-audit', {}, {}, {}),
    'data': ('data-science', {}, {}, {}),
    'webdev': ('web-development', {}, {}, {}),
    'api': ('api-design', {}, {}, {}),
}

detected = {
    'python': '$HAS_PYTHON' == 'yes',
    'c': '$HAS_C' == 'yes',
    'bash': '$HAS_BASH' == 'yes',
    'node': '$HAS_NODE' == 'yes',
    'rust': '$HAS_RUST' == 'yes',
    'go': '$HAS_GO' == 'yes',
    'docker': '$HAS_DOCKER' == 'yes',
    'git': '$HAS_GIT' == 'yes',
    'hyprland': '$HAS_HYPRLAND' == 'yes',
    'adb': '$HAS_ADB' == 'yes',
    'neovim': '$HAS_NEOVIM' == 'yes',
    'tmux': '$HAS_TMUX' == 'yes',
    'media': '$HAS_MEDIA' == 'yes',
    'security': '$HAS_SECURITY' == 'yes',
    'data': '$HAS_DATA' == 'yes',
    'webdev': '$HAS_WEBDEV' == 'yes',
    'api': '$HAS_API' == 'yes',
}

for key, active in detected.items():
    if active and key in skills_extra:
        name, ft, ct, pt = skills_extra[key]
        skills.append(name)
        file_triggers.update(ft)
        content_triggers.update(ct)
        path_triggers.update(pt)

groups['dev-core'] = ['c-project', 'github-ops', 'systematic-debugging', 'verification-before-completion']
if detected.get('python'): groups['python-dev'] = ['python-style', 'github-ops']
if detected.get('docker'): groups['devops'] = ['docker', 'github-ops']
if detected.get('hyprland'): groups['desktop'] = ['hyprland-config', 'neovim']
if detected.get('adb'): groups['android'] = ['adb-ops']

config = {
    '\$schema': 'https://opencode.ai/config.json',
    'model': 'zen/big-pickle',
    'small_model': 'zen/big-pickle',
    'plugin': [
        'opencode-skills-collection@latest',
        ['opencode-plugin-preload-skills', {
            'skills': skills,
            'fileTypeSkills': file_triggers,
            'pathPatterns': path_triggers,
            'contentTriggers': content_triggers,
            'groups': groups,
            'maxTokens': 8000,
            'showToasts': True,
            'enableTools': True
        }]
    ],
    'skills': {'paths': ['~/.config/opencode/skills']},
    'instructions': ['AGENTS.md'],
    'permission': {
        'bash': {
            'git *': 'allow', 'ls *': 'allow', 'cat *': 'allow',
            'find *': 'allow', 'grep *': 'allow', 'mkdir *': 'allow',
            'cp *': 'allow', 'mv *': 'allow', 'rm -rf *': 'ask', '*': 'ask'
        },
        'edit': 'allow', 'read': 'allow', 'glob': 'allow',
        'grep': 'allow', 'webfetch': 'allow', 'websearch': 'allow'
    }
}

print(json.dumps(config, indent=2))
" > "$OPENCODE_DIR/opencode.jsonc"
}

# ---- Write tui.json ----
write_theme() {
  cat > "$OPENCODE_DIR/tui.json" << 'THEMEEOF'
{
  "$schema": "https://opencode.ai/tui.json",
  "theme": "catppuccin"
}
THEMEEOF
}

# ---- Write AGENTS.md ----
write_agents_md() {
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

## Session End
- When user says "thank you", "thanks", "bye", "done", or indicates the session is ending, run: `~/.local/bin/op-u`
- This re-audits their workflow and updates config for next session
- Remind them to restart opencode after running
AGENTSEOF
}

# ---- Write custom skills ----
write_skills() {
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
}

# ---- Write agents ----
write_agents() {
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
}

# ---- Write commands ----
write_commands() {
  cat > "$COMMANDS_DIR/learn.md" << 'CMDEOF'
---
description: Save a lesson learned to AGENTS.md
---
Take what the user said below and write it as a concise, actionable instruction to the appropriate AGENTS.md file (project-level if in a project, global otherwise).

User said: $ARGUMENTS

Format: short rule, not a story. Example: "Use `set -euo pipefail` in all bash scripts."
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
Research the topic below online, synthesize into a SKILL.md at ~/.config/opencode/skills/<name>/SKILL.md.

Topic: $ARGUMENTS

Structure: name, description with trigger keywords, sections for commands/patterns/gotchas, safety section. Max 150 lines. Confirm creation to user.
CMDEOF
}

# ---- Write package.json ----
write_package_json() {
  cat > "$OPENCODE_DIR/package.json" << 'PKGEOF'
{
  "dependencies": {
    "@opencode-ai/plugin": "1.15.13",
    "opencode-skills-collection": "latest",
    "opencode-plugin-preload-skills": "latest"
  }
}
PKGEOF
}

# ---- Install op-u updater command ----
install_op_u() {
  mkdir -p "$BIN_DIR"
  cat > "$BIN_DIR/op-u" << 'OPUEOF'
#!/bin/bash
set -euo pipefail

OPENCODE_DIR="$HOME/.config/opencode"
HISTORY="$HOME/.bash_history"

echo "=== OpenCode Re-Audit ==="
echo ""

detect() { grep -qi "$1" "$HISTORY" 2>/dev/null && echo "yes" || echo "no"; }

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
HAS_MEDIA=$(detect "kew\|cmus\|cava\|mpv\|yt-dlp\|ffmpeg")
HAS_SECURITY=$(detect "nmap\|burp\|sqlmap\|nikto\|metasploit")
HAS_DATA=$(detect "jupyter\|pandas\|numpy\|matplotlib\|tensorflow\|pytorch")
HAS_WEBDEV=$(detect "react\|vue\|angular\|svelte\|next\|nuxt\|tailwind")
HAS_API=$(detect "fastapi\|flask\|django\|express\|gin\|axum")

echo "Detected: python=$HAS_PYTHON c=$HAS_C git=$HAS_GIT hyprland=$HAS_HYPRLAND adb=$HAS_ADB"

python3 -c "
import json, os

skills = ['stop-slop', 'systematic-debugging']
file_triggers = {}
path_triggers = {}
content_triggers = {}
groups = {}

skills_extra = {
    'python': ('python-style', {'.py': ['python-style']}, {'python': ['python-style'], 'pip': ['python-style'], 'django': ['python-style'], 'flask': ['python-style'], 'fastapi': ['python-style']}, {}),
    'c': ('c-project', {'.c': ['c-project'], '.h': ['c-project']}, {'gcc': ['c-project'], 'valgrind': ['c-project'], 'gdb': ['c-project'], 'compile': ['c-project']}, {'**/Makefile': ['c-project']}),
    'bash': ('shell-scripting', {'.sh': ['shell-scripting']}, {}, {'**/*.sh': ['shell-scripting']}),
    'node': ('nodejs', {}, {'npm': ['nodejs'], 'node': ['nodejs'], 'typescript': ['nodejs'], 'bun': ['nodejs']}, {}),
    'rust': ('rust', {}, {'cargo': ['rust'], 'rust': ['rust'], 'rustc': ['rust']}, {}),
    'go': ('golang', {}, {'go build': ['golang'], 'golang': ['golang']}, {}),
    'docker': ('docker', {}, {'docker': ['docker'], 'container': ['docker'], 'podman': ['docker']}, {}),
    'git': ('github-ops', {}, {'github': ['github-ops'], 'pull request': ['github-ops'], 'issue': ['github-ops'], 'workflow': ['github-ops'], 'release': ['github-ops'], 'merge': ['github-ops']}, {}),
    'hyprland': ('hyprland-config', {}, {'hyprland': ['hyprland-config'], 'keybind': ['hyprland-config'], 'monitor': ['hyprland-config'], 'wayland': ['hyprland-config']}, {'~/.config/hypr/**': ['hyprland-config']}),
    'adb': ('adb-ops', {}, {'adb': ['adb-ops'], 'android': ['adb-ops'], 'waydroid': ['adb-ops'], 'scrcpy': ['adb-ops']}, {}),
    'neovim': ('neovim', {}, {'nvim': ['neovim'], 'neovim': ['neovim'], 'vim': ['neovim']}, {}),
    'tmux': ('tmux', {}, {'tmux': ['tmux']}, {}),
    'media': ('media-tools', {}, {}, {}),
    'security': ('security-audit', {}, {}, {}),
    'data': ('data-science', {}, {}, {}),
    'webdev': ('web-development', {}, {}, {}),
    'api': ('api-design', {}, {}, {}),
}

detected = {
    'python': '$HAS_PYTHON' == 'yes',
    'c': '$HAS_C' == 'yes',
    'bash': '$HAS_BASH' == 'yes',
    'node': '$HAS_NODE' == 'yes',
    'rust': '$HAS_RUST' == 'yes',
    'go': '$HAS_GO' == 'yes',
    'docker': '$HAS_DOCKER' == 'yes',
    'git': '$HAS_GIT' == 'yes',
    'hyprland': '$HAS_HYPRLAND' == 'yes',
    'adb': '$HAS_ADB' == 'yes',
    'neovim': '$HAS_NEOVIM' == 'yes',
    'tmux': '$HAS_TMUX' == 'yes',
    'media': '$HAS_MEDIA' == 'yes',
    'security': '$HAS_SECURITY' == 'yes',
    'data': '$HAS_DATA' == 'yes',
    'webdev': '$HAS_WEBDEV' == 'yes',
    'api': '$HAS_API' == 'yes',
}

for key, active in detected.items():
    if active and key in skills_extra:
        name, ft, ct, pt = skills_extra[key]
        skills.append(name)
        file_triggers.update(ft)
        content_triggers.update(ct)
        path_triggers.update(pt)

groups['dev-core'] = ['c-project', 'github-ops', 'systematic-debugging', 'verification-before-completion']
if detected.get('python'): groups['python-dev'] = ['python-style', 'github-ops']
if detected.get('docker'): groups['devops'] = ['docker', 'github-ops']
if detected.get('hyprland'): groups['desktop'] = ['hyprland-config', 'neovim']
if detected.get('adb'): groups['android'] = ['adb-ops']

config = {
    '\$schema': 'https://opencode.ai/config.json',
    'model': 'zen/big-pickle',
    'small_model': 'zen/big-pickle',
    'plugin': [
        'opencode-skills-collection@latest',
        ['opencode-plugin-preload-skills', {
            'skills': skills,
            'fileTypeSkills': file_triggers,
            'pathPatterns': path_triggers,
            'contentTriggers': content_triggers,
            'groups': groups,
            'maxTokens': 8000,
            'showToasts': True,
            'enableTools': True
        }]
    ],
    'skills': {'paths': ['~/.config/opencode/skills']},
    'instructions': ['AGENTS.md'],
    'permission': {
        'bash': {
            'git *': 'allow', 'ls *': 'allow', 'cat *': 'allow',
            'find *': 'allow', 'grep *': 'allow', 'mkdir *': 'allow',
            'cp *': 'allow', 'mv *': 'allow', 'rm -rf *': 'ask', '*': 'ask'
        },
        'edit': 'allow', 'read': 'allow', 'glob': 'allow',
        'grep': 'allow', 'webfetch': 'allow', 'websearch': 'allow'
    }
}

with open(os.path.expanduser('~/.config/opencode/opencode.jsonc'), 'w') as f:
    json.dump(config, f, indent=2)
"

echo ""
echo "Done. Restart opencode to apply."
OPUEOF

  chmod +x "$BIN_DIR/op-u"
}

# ---- Install plugin deps ----
install_deps() {
  (cd "$OPENCODE_DIR" && npm install 2>/dev/null) || true
}

# ---- Main ----
main() {
  local mode="${1:-install}"

  if [ "$mode" = "install" ]; then
    echo "=== OpenCode Smart Setup ==="
    echo ""

    echo "[1/8] Auditing workflow..."
    audit_history
    echo "  Detected: python=$HAS_PYTHON c=$HAS_C git=$HAS_GIT hyprland=$HAS_HYPRLAND adb=$HAS_ADB"
    echo ""

    echo "[2/8] Building skill config..."
    mkdir -p "$SKILLS_DIR" "$AGENTS_DIR" "$COMMANDS_DIR" "$THEMES_DIR"

    echo "[3/8] Writing config..."
    generate_config

    echo "[4/8] Setting theme..."
    write_theme

    echo "[5/8] Writing agent instructions..."
    write_agents_md

    echo "[6/8] Writing skills..."
    write_skills

    echo "[7/8] Writing agents and commands..."
    write_agents
    write_commands

    echo "[8/8] Installing op-u updater + plugin deps..."
    install_op_u
    write_package_json
    install_deps

    echo ""
    echo "=== Setup Complete ==="
    echo ""
    echo "Restart opencode to load changes."
    echo "Run 'op-u' anytime to re-audit and update your config."

  elif [ "$mode" = "update" ]; then
    echo "=== OpenCode Re-Audit ==="
    echo ""
    echo "[1/3] Auditing workflow..."
    audit_history
    echo "  Detected: python=$HAS_PYTHON c=$HAS_C git=$HAS_GIT hyprland=$HAS_HYPRLAND adb=$HAS_ADB"
    echo ""

    echo "[2/3] Rebuilding config..."
    mkdir -p "$SKILLS_DIR" "$AGENTS_DIR" "$COMMANDS_DIR" "$THEMES_DIR"
    generate_config

    echo "[3/3] Installing op-u updater..."
    install_op_u

    echo ""
    echo "Done. Restart opencode to apply."
  else
    echo "Usage: $0 [install|update]"
    exit 1
  fi
}

main "$@"
