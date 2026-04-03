# dotfiles

Personal configuration files for macOS (Apple M4).

## Contents

| Path | Description |
|------|-------------|
| `nvim/` | Neovim 0.12 config (LSP, Treesitter, FZF, Git) |
| `kitty/` | Kitty terminal config |
| `.zshrc` | Zsh config with dev function and completions |

## Dependencies

```bash
brew install neovim fzf
brew install rust
cargo install --locked tree-sitter-cli
```

LSP servers via Mason (`:Mason` in Neovim):
- `clangd` — C/C++ (already via Xcode CLT)
- `sourcekit` — Swift (already via Xcode CLT)
- `ts_ls` — TypeScript/JavaScript
- `pyright` — Python
- `lua_ls` — Lua
- `bashls` — Bash

## Setup

```bash
git clone https://github.com/swiftAndHandy/dotfiles.git ~/dotfiles

mv ~/.config/nvim ~/dotfiles/nvim
mv ~/.config/kitty ~/dotfiles/kitty
mv ~/.zshrc ~/dotfiles/.zshrc

ln -s ~/dotfiles/nvim ~/.config/nvim
ln -s ~/dotfiles/kitty ~/.config/kitty
ln -s ~/dotfiles/.zshrc ~/.zshrc
```

Add to `~/.zprofile`:
```bash
eval "$(/opt/homebrew/bin/brew shellenv zsh)"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
```

## Raspberry Pi Pico

The `.zshrc` includes `PICO_SDK_PATH` pointing to `~/pico/pico-sdk`. To set up the SDK:

```bash
brew install cmake gcc-arm-embedded
mkdir ~/pico && cd ~/pico
git clone https://github.com/raspberrypi/pico-sdk.git
cd pico-sdk && git submodule update --init
```

Install picotool separatly to avoid ckmake rebuilding it for every project: 
```bash
brew install picotool
```

If you don't need Pico support, remove the `PICO_SDK_PATH` export from `.zshrc` and skip the above.

