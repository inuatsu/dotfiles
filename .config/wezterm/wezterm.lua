local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.adjust_window_size_when_changing_font_size = true
config.automatically_reload_config = true
config.color_scheme = "Japanesque (Gogh)"
config.default_cursor_style = "BlinkingBar"
config.enable_scroll_bar = true
config.font = wezterm.font("DaddyTimeMono Nerd Font")
config.font_size = 14.0
config.hyperlink_rules = wezterm.default_hyperlink_rules()
config.scrollback_lines = 1000000
config.text_background_opacity = 0.5
config.use_ime = true
config.window_background_opacity = 0.8

return config
