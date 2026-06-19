# Enable Zsh completion system
autoload -Uz compinit
compinit

eval "$(zoxide init zsh)"

# Handle / as Word in terminals
WORDCHARS=${WORDCHARS//\//}

export PICO_SDK_PATH=$HOME/embedded/pico-sdk
export PATH="$HOME/.cargo/bin:$PATH"
# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/veltens/.lmstudio/bin"
# End of LM Studio CLI section

#neomutt related
export EDITOR="nvim"
export VISUAL="nvim"
