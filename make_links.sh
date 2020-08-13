echo "making ~/.config/fish"
mkdir ~/.config/fish
mkdir ~/.config/functions

echo "linking config files of fish..."
ln -s ~/dotfile/fish/config.fish ~/.config/fish/config.fish
ln -s ~/dotfile/fish/functions/fish_prompt.fish  ~/.config/fish/functions/fish_prompt.fish

echo "making ~/.config/nvim"
mkdir ~/.config/nvim

echo "linking config files of nvim..."
ln -s ~/dotfile/nvim/coc-settings.json ~/.config/nvim/coc-settings.json
ln -s ~/dotfile/nvim/coc-settings.vim ~/.config/nvim/coc-settings.vim
ln -s ~/dotfile/nvim/dein.toml ~/.config/nvim/dein.toml
ln -s ~/dotfile/nvim/dein_lazy.toml ~/.config/nvim/dein_lazy.toml
ln -s ~/dotfile/nvim/init.vim ~/.config/nvim/init.vim

echo "linking git settings..."
ln -s ~/dotfile/.gitconfig ~/.gitconfig
ln -s ~/dotfile/.gitignore_global ~/.gitignore_global

echo "Done!!!"
