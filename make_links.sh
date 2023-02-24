echo "making ~/.config/fish"
mkdir ~/.config/fish
mkdir ~/.config/functions

echo "linking config files of fish..."
ln -s ~/dotfile/fish/config.fish ~/.config/fish/config.fish
ln -s ~/dotfile/fish/functions/fish_prompt.fish  ~/.config/fish/functions/fish_prompt.fish

echo "linking ~/.config/nvim"
ln -s ~/dotfile/nvim/ ~/.config/nvim/

echo "linking git settings..."
ln -s ~/dotfile/.gitconfig ~/.gitconfig
ln -s ~/dotfile/.gitignore_global ~/.gitignore_global

echo "Done!!!"
