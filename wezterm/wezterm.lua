local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.automatically_reload_config = true

-- window
config.initial_cols = 128
config.initial_rows = 36
config.scrollback_lines = 20000
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = false
config.show_close_tab_button_in_tabs = false
config.tab_bar_at_bottom = true

-- config.color_scheme = 'Material Dark'
config.color_scheme = 'Everforest Dark Hard (Gogh)'

-- fonts
config.font = wezterm.font_with_fallback({
    { family = "Moralerspace Neon", stretch = 'Normal', weight = 'Regular', },
    -- { family = 'Apple Color Emoji', }
})
config.font_size = 10.0

-- keybinds
config.keys = require("keybinds").keys
config.key_tables = require("keybinds").key_tables
config.disable_default_key_bindings = true

-- 日本語入力
config.use_ime = true
config.macos_forward_to_ime_modifier_mask = 'SHIFT|CTRL'

config.leader = { key = "q", mods = "CTRL", timeout_milliseconds = 2000 }

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local background = "#5c6d74"
  local foreground = "#FFFFFF"

  if tab.is_active then
    background = "#dbbc7f"
    foreground = "#272e33"
  end

  local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "

  return {
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
  }
end)

return config
