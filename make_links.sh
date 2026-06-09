#!/bin/sh
set -eu

SCRIPT_DIR=$(
    CDPATH= cd -- "$(dirname -- "$0")" && pwd
)
DOTFILES_DIR="${DOTFILES_DIR:-$SCRIPT_DIR}"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"

backup_path() {
    path=$1
    if [ -e "$path" ] || [ -L "$path" ]; then
        backup="${path}.bak.${TIMESTAMP}"
        echo "backing up $path -> $backup"
        mv "$path" "$backup"
    fi
}

ensure_parent_dir() {
    parent_dir=$(dirname -- "$1")
    mkdir -p "$parent_dir"
}

link_path() {
    src=$1
    dest=$2

    ensure_parent_dir "$dest"

    if [ -L "$dest" ]; then
        current_target=$(readlink "$dest")
        if [ "$current_target" = "$src" ]; then
            echo "keeping existing link $dest"
            return
        fi
    fi

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        backup_path "$dest"
    fi

    ln -s "$src" "$dest"
}

echo "linking fish config"
mkdir -p "$HOME/.config/fish"
mkdir -p "$HOME/.config/fish/functions"
link_path "$DOTFILES_DIR/fish/config.fish" "$HOME/.config/fish/config.fish"
link_path "$DOTFILES_DIR/fish/functions/fish_prompt.fish" "$HOME/.config/fish/functions/fish_prompt.fish"

echo "linking zsh settings"
link_path "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

echo "linking nvim config"
link_path "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

echo "linking wezterm config"
link_path "$DOTFILES_DIR/wezterm" "$HOME/.config/wezterm"

echo "linking karabiner config"
mkdir -p "$HOME/.config/karabiner"
link_path "$DOTFILES_DIR/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"

echo "linking git settings"
link_path "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
link_path "$DOTFILES_DIR/.gitignore_global" "$HOME/.gitignore_global"

echo "Done!!!"
