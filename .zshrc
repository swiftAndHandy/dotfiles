# Enable Zsh completion system
autoload -Uz compinit
compinit

# Target local sourcecode-folders
dev() {
    local base=~/Documents/development

    case "$1" in
        c)
            base="$base/c" ;;
        pico)
            base="$base/pico" ;;
        py)
            base="$base/python" ;;
        swift)
            base="$base/swift" ;;
        web)
            base="$base/web" ;;
        *) 
            echo "Unknown category"; return 1 ;;
    esac

    if [ -n "$2" ]; then
        base="$base/$2"
    fi

    cd "$base" || return 
    ls
}

# Auto completion in dev-function
_dev() {
    local base=~/Documents/development
    local -a categories
    categories=(c pico py swift web)

    if (( CURRENT == 2 )); then
        _describe 'category' categories
        return
    fi

    if (( CURRENT == 3 )); then 
        case "$words[2]" in 
            c)    _files -W "$base/c" -/ ;;
            pico) _files -W "$base/pico" -/ ;;
            py)    _files -W "$base/python" -/ ;;
            swift) _files -W "$base/swift" -/ ;;
            web)   _files -W "$base/web" -/ ;;
            *)     _files -W "$base" -/ ;;
        esac
    fi
}

compdef _dev dev

export PICO_SDK_PATH=$HOME/pico/pico-sdk
export PATH="$HOME/.cargo/bin:$PATH"
