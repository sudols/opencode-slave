# opencode-dsa-workflow

Hyprland workflow for solving problems using OpenCode with screenshot-to-clipboard automation.

## Components

- **Scripts** (`bin/`) - Core workflow scripts for running, retrying, and clearing
- **Hyprland** (`config/hyprland/`) - Keybind configurations
- **Fuzzel** (`config/fuzzel/`) - Input prompt styling
- **EWW** (`config/eww/`) - Status indicator widget

## Keybinds

- `Super + R` - Run OpenCode on buffer contents
- `Super + E` - Retry with automatic fix prompt
- `Super + Shift + E` - Retry with manual prompt
- `Super + C` - Clear buffer

## Installation

1. Copy scripts: `cp bin/* ~/.local/bin/`
2. Source hyprland config: `source = ~/.config/hypr/opencode-dsa-workflow/config/hyprland/oc-keybinds.conf`
3. Copy fuzzel config: `cp config/fuzzel/oc-input.ini ~/.config/fuzzel/`
4. Copy eww widget: `cp config/eww/* ~/.config/eww/oc/`
5. Launch eww widget: `eww open oc-indicator`

## Dependencies

- OpenCode
- Hyprland
- fuzzel
- eww
- wl-clipboard
