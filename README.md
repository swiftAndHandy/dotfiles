# dotfiles

Personal configuration files for macOS (Apple M4).

## Contents

| Path | Description |
| --- | --- |
| `nvim/` | Neovim 0.12 config (LSP, Treesitter, FZF, Git) |
| `kitty/` | Kitty terminal config |
| `clangd/` | clangd config for ARM (Pico) and RISC-V (ESP32) |
| `.zshrc` | Zsh config with dev function and completions |

## Dependencies

```
brew install neovim fzf
brew install rust
cargo install --locked tree-sitter-cli
brew install llvm  # native macOS clangd for embedded development
```

LSP servers via Mason (`:Mason` in Neovim):

- `clangd` — C/C++, configured via `~/Library/Preferences/clangd/config.yaml`
- `sourcekit` — Swift (via Xcode CLT)
- `ts_ls` — TypeScript/JavaScript
- `pyright` — Python
- `lua_ls` — Lua
- `bashls` — Bash

## Setup

```
git clone https://github.com/swiftAndHandy/dotfiles.git ~/dotfiles

ln -s ~/dotfiles/nvim ~/.config/nvim
ln -s ~/dotfiles/kitty ~/.config/kitty
ln -s ~/dotfiles/clangd ~/.config/clangd
ln -s ~/dotfiles/.zshrc ~/.zshrc

mkdir -p ~/Library/Preferences/clangd
ln -sf ~/.config/clangd/config.yaml ~/Library/Preferences/clangd/config.yaml
```

Add to `~/.zprofile`:

```
eval "$(/opt/homebrew/bin/brew shellenv zsh)"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
```

## Embedded Development

Projects live under `~/Documents/development/esp` and `~/Documents/development/pico`.

### ESP32-H2 (ESP-IDF)

ESP-IDF is managed by EIM (Espressif Installation Manager) and installed to `~/.espressif`. Install once:

```
brew install libgcrypt glib pixman sdl2 libslirp cmake
brew tap espressif/eim
brew install eim
eim install
```

Activate the environment per terminal session:

```
source ~/.espressif/tools/activate_idf_v6.0.sh
```

Add to `.zshrc` for convenience:

```
alias get_idf='source ~/.espressif/tools/activate_idf_v6.0.sh'
```

### Raspberry Pi Pico

The `.zshrc` exports `PICO_SDK_PATH` pointing to `~/embedded/pico-sdk`. To set up the SDK:

```
brew install cmake gcc-arm-embedded
mkdir -p ~/embedded/ && cd ~/embedded/
git clone https://github.com/raspberrypi/pico-sdk.git
cd pico-sdk && git submodule update --init
brew install picotool
```

## clangd Configuration

The `clangd/config.yaml` uses `PathMatch` to apply different settings per project:

- `~/Documents/development/pico/.*` → ARM toolchain (Xcode CLT + ARM GNU)
- `~/Documents/development/esp/.*` → RISC-V toolchain (ESP-IDF riscv32-esp-elf)

Neovim uses the Homebrew clangd (`/opt/homebrew/opt/llvm/bin/clangd`) with `--query-driver` pointing to both ARM and RISC-V toolchains. A symlink is required because Homebrew clangd reads from a macOS-specific path:

```
mkdir -p ~/Library/Preferences/clangd
ln -sf ~/.config/clangd/config.yaml ~/Library/Preferences/clangd/config.yaml
```