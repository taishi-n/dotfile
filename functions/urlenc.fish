# Defined in /Users/taishi/.config/fish/config.fish @ line 29
function urlenc
	find -E . -regex "^.+%[0-9A-Z][0-9A-Z]+.*" -exec bash -c "mv {} `echo {} | nkf --url-input `" \;
end
