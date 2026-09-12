# opencode-setup

One-command setup for OpenCode with curated skills, agents, commands, and model config for Arch Linux / Hyprland users.

## What it installs

**Config** (`~/.config/opencode/opencode.jsonc`):
- `opencode-skills-collection` plugin (1595+ on-demand skills)
- `opencode-plugin-preload-skills` (auto-loads skills by keyword/file/path)
- Permissions configured for safe bash, edit, read, web access
- Model: `zen/big-pickle` (free)

**AGENTS.md** - Global instructions:
- Code style (Linux kernel for C, PEP 8 for Python, ShellCheck for bash)
- Hyprland/Wayland conventions
- ADB/Android patterns
- Safety rules

**Skills** (4 custom):
| Skill | Triggers on |
|-------|-------------|
| `hyprland-config` | "hyprland", "keybind", "monitor", "wayland" |
| `adb-ops` | "adb", "android", "waydroid" |
| `c-project` | `.c`/`.h` files, "gcc", "valgrind" |
| `github-ops` | "github", "pull request", "issue", "workflow" |

**Agents**:
- `review` - Code review for bugs/style/security
- `debug` - Systematic debugging process

**Commands**:
- `/learn` - Save lessons to AGENTS.md
- `/finish-work` - Pre-commit quality gate
- `/session-summary` - Handoff summary
- `/custom-skill` - Auto-generate skills from web research

## Usage

```bash
curl -fsSL https://raw.githubusercontent.com/charan-gn/opencode-setup/main/setup.sh | bash
```

Or clone and run:
```bash
git clone https://github.com/charan-gn/opencode-setup.git
cd opencode-setup
bash setup.sh
```

## Restart opencode after running.

## Customization

Edit `~/.config/opencode/AGENTS.md` to add your own rules and project context.
Edit `~/.config/opencode/opencode.jsonc` to change model, permissions, or triggers.
