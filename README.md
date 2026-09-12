# opencode-setup

Smart one-command setup for OpenCode. Audits your bash history to detect your workflow, then installs relevant skills, agents, commands, and a clean theme.

## What it does

1. **Audits `~/.bash_history`** to detect: languages, tools, desktop environment, distro
2. **Dynamically builds config** with only relevant skills and triggers
3. **Installs 1595+ on-demand skills** via the skills collection plugin
4. **Sets up auto-loading** via the preload-skills plugin (by keyword, file type, path)
5. **Applies catppuccin theme** (dark, clean, works with Hyprland/Nord/Gruvbox setups)

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

## What gets installed

```
~/.config/opencode/
├── opencode.jsonc          # Main config (model, plugins, permissions)
├── tui.json                # Theme config (catppuccin)
├── AGENTS.md               # Global agent instructions
├── package.json            # Plugin dependencies
├── skills/                 # Custom skills (hyprland, adb, c, github)
├── agents/                 # review, debug agents
├── commands/               # /learn, /finish-work, /session-summary, /custom-skill
└── themes/                 # Custom themes (empty by default)
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
- Add skills to `~/.config/opencode/skills/<name>/SKILL.md`

## Requirements

- OpenCode installed
- Node.js/npm (for plugin installation)
- bash (for history detection)

## License

MIT
