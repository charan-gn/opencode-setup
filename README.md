# opencode-setup

Smart one-command setup for OpenCode. Audits your bash history to detect your workflow, then installs relevant skills, agents, commands, and a clean theme.

## Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/charan-gn/opencode-setup/main/setup.sh)
```

## Re-audit (run anytime)

```bash
op-u
```

Re-reads your `~/.bash_history`, detects new tools/languages you've started using, and updates your config. Restart opencode after running.

## What it does

1. **Audits `~/.bash_history`** to detect: languages, tools, desktop environment
2. **Dynamically builds config** with only relevant skills and triggers
3. **Installs 1595+ on-demand skills** via the skills collection plugin
4. **Sets up auto-loading** via the preload-skills plugin
5. **Applies catppuccin theme**
6. **Installs `op-u`** to `~/.local/bin/` for re-auditing

## Detected workflows

| Detection | Skills installed |
|-----------|-----------------|
| Python (pip/django/flask) | `python-style` |
| C (gcc/valgrind) | `c-project` |
| Bash (shellcheck) | `shell-scripting` |
| Node.js (npm/bun) | `nodejs` |
| Rust (cargo) | `rust` |
| Go | `golang` |
| Docker/Podman | `docker` |
| Git/GitHub | `github-ops` |
| Hyprland/Wayland | `hyprland-config` |
| ADB/Android/Waydroid | `adb-ops` |
| Neovim | `neovim` |
| Tmux | `tmux` |
| Media tools | `media-tools` |
| Security tools | `security-audit` |
| Data/ML | `data-science` |
| Web dev | `web-development` |

## What gets installed

```
~/.config/opencode/
├── opencode.jsonc          # Main config
├── tui.json                # Theme (catppuccin)
├── AGENTS.md               # Global instructions
├── package.json            # Plugin deps
├── skills/                 # Custom skills
├── agents/                 # review, debug
├── commands/               # /learn, /finish-work, /session-summary, /custom-skill
└── themes/

~/.local/bin/
└── op-u                    # Re-audit command
```

## Commands

| Command | What it does |
|---------|--------------|
| `/learn` | Save a lesson learned to AGENTS.md |
| `/finish-work` | Pre-commit quality gate |
| `/session-summary` | Session handoff summary |
| `/custom-skill` | Auto-generate a skill from web research |

## Customization

- Edit `~/.config/opencode/AGENTS.md` for your rules
- Edit `~/.config/opencode/opencode.jsonc` for model/permissions
- Run `/theme` in opencode to change theme
- Run `op-u` to re-audit after installing new tools

## Requirements

- OpenCode installed
- Node.js/npm
- bash
