local wezterm = require("wezterm")

local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")

local config = {
	automatically_reload_config = true,
	check_for_updates = false,
	window_close_confirmation = "NeverPrompt",
	-- color_scheme = "Oxocarbon Dark (Gogh)",
	color_scheme = "carbonfox",
	-- font
	font_size = 12.0,
	font = wezterm.font_with_fallback({
		{ family = "Iosevka Term Nerd Font", stretch = "Expanded", weight = "DemiBold" },
		{ family = "Symbols Nerd Font Mono", scale = 0.85 },
	}),
	warn_about_missing_glyphs = false,
	adjust_window_size_when_changing_font_size = false,

	line_height = 1,
	cell_width = 0.9,
	-- cursor
	default_cursor_style = "BlinkingBar",
	cursor_blink_rate = 500,
	cursor_thickness = "1pt",

	force_reverse_video_cursor = false,
	-- tab bar
	enable_tab_bar = true,
	use_fancy_tab_bar = true,
	hide_tab_bar_if_only_one_tab = true,
	tab_bar_at_bottom = false,
	-- windows
	window_padding = {
		left = 3,
		right = 3,
		top = 5,
		bottom = 0,
	},
	window_decorations = "TITLE | RESIZE",
	window_background_opacity = 1,

	-- bells
	audible_bell = "Disabled",
	visual_bell = {
		fade_in_duration_ms = 75,
		fade_out_duration_ms = 75,
		target = "CursorColor",
	},

	term = "xterm-256color",
	-- term = "wezterm",
	inactive_pane_hsb = {
		hue = 1.0,
		saturation = 1.0,
		brightness = 0.7,
	},
	-- colors
	colors = {
		cursor_bg = "#A6ACCD",
		cursor_border = "#A6ACCD",
		cursor_fg = "#1B1E28",
		tab_bar = {
			background = "#121212",
			new_tab = { bg_color = "#121212", fg_color = "#FCE8C3", intensity = "Bold" },
			new_tab_hover = { bg_color = "#121212", fg_color = "#FBB829", intensity = "Bold" },
			active_tab = { bg_color = "#121212", fg_color = "#FCE8C3" },
		},
	},
	-- prefer_to_spawn_tabs = true,
}

local act = wezterm.action

config.leader = { key = "Space", mods = "SHIFT", timeout_milliseconds = 1000 }

config.keys = {

	{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
	{ key = "h", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "v", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "l", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },

	{ key = "LeftArrow", mods = "SHIFT|ALT", action = act.MoveTabRelative(-1) },
	{ key = "RightArrow", mods = "SHIFT|ALT", action = act.MoveTabRelative(1) },
	{ key = "PageDown", mods = "CTRL", action = act.ActivateTabRelative(-1) },
	{ key = "PageUp", mods = "CTRL", action = act.ActivateTabRelative(1) },
	-- { key = "[", mods = "CTRL|ALT", action = act.ActivateTabRelative(-1) },
	-- { key = "]", mods = "CTRL|ALT", action = act.ActivateTabRelative(1) },

	-- Show the selector, using the quick_select_alphabet
	{ key = "o", mods = "CTRL", action = wezterm.action({ PaneSelect = {} }) },
	-- Show the selector, using your own alphabet
	{ key = "p", mods = "CTRL", action = wezterm.action({ PaneSelect = { alphabet = "0123456789" } }) },
	{ key = "z", mods = "CTRL", action = wezterm.action.TogglePaneZoomState },
	-- activate resize mode
	{
		key = "r",
		mods = "LEADER",
		action = act.ActivateKeyTable({
			name = "resize_pane",
			one_shot = false,
		}),
	},
	{
		key = "c",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Enter new tab name:",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					local tab = window:mux_window():spawn_tab({
						cwd = wezterm.home_dir .. "/me",
					})
					tab:set_title(line)
					tab:activate()
				end
			end),
		}),
	},
	{ key = "9", mods = "LEADER", action = act.ActivateCommandPalette },
	{
		key = "w",
		mods = "ALT",
		action = wezterm.action_callback(function(win, pane)
			resurrect.save_state(resurrect.workspace_state.get_workspace_state())
		end),
	},
	{
		key = "W",
		mods = "ALT",
		action = resurrect.window_state.save_window_action(),
	},
	{
		key = "T",
		mods = "ALT",
		action = resurrect.tab_state.save_tab_action(),
	},
	{
		key = "s",
		mods = "ALT",
		action = wezterm.action_callback(function(win, pane)
			resurrect.save_state(resurrect.workspace_state.get_workspace_state())
			resurrect.window_state.save_window_action()
		end),
	},
	{
		key = "r",
		mods = "ALT",
		action = wezterm.action_callback(function(win, pane)
			resurrect.fuzzy_load(win, pane, function(id, label)
				local type = string.match(id, "^([^/]+)") -- match before '/'
				id = string.match(id, "([^/]+)$") -- match after '/'
				id = string.match(id, "(.+)%..+$") -- remove file extention
				local opts = {
					relative = true,
					restore_text = true,
					on_pane_restore = resurrect.tab_state.default_on_pane_restore,
				}
				if type == "workspace" then
					local state = resurrect.load_state(id, "workspace")
					resurrect.workspace_state.restore_workspace(state, opts)
				elseif type == "window" then
					local state = resurrect.load_state(id, "window")
					resurrect.window_state.restore_window(pane:window(), state, opts)
				elseif type == "tab" then
					local state = resurrect.load_state(id, "tab")
					resurrect.tab_state.restore_tab(pane:tab(), state, opts)
				end
			end)
		end),
	},
}

config.key_tables = {
	resize_pane = {
		{ key = "LeftArrow", action = act.AdjustPaneSize({ "Left", 5 }) },
		{ key = "RightArrow", action = act.AdjustPaneSize({ "Right", 5 }) },
		{ key = "UpArrow", action = act.AdjustPaneSize({ "Up", 2 }) },
		{ key = "DownArrow", action = act.AdjustPaneSize({ "Down", 2 }) },
		{ key = "Escape", action = "PopKeyTable" },
	},
}

local launch_menu = {}
config.launch_menu = launch_menu

local ssh_cmd = { "ssh" }
local ssh_config_file = wezterm.home_dir .. "/.ssh/config"
local f = io.open(ssh_config_file)
if f then
	local line = f:read("*l")
	while line do
		if line:find("Host ") == 1 then
			local host = line:gsub("Host ", "")
			local args = {}
			for i, v in pairs(ssh_cmd) do
				args[i] = v
			end
			args[#args + 1] = host
			table.insert(launch_menu, {
				label = "SSH " .. host,
				args = args,
			})
			-- default open vm
			if host == "vm" then
				config.default_prog = { "powershell.exe", "ssh", "vm" }
			end
		end
		line = f:read("*l")
	end
	f:close()
end

local mux = wezterm.mux
wezterm.on("mux-startup", function()
	local tab, pane, window = mux.spawn_window({})
	window:gui_window():set_inner_size(1280, 720)
	window:gui_window():set_position(980, 59)
	pane:split({ direction = "Bottom", size = 0.25 })
end)

wezterm.unix_domains = {
	{
		name = "unix",
	},
}

wezterm.on("format-tab-title", function(tab, _, _, _, _)
	-- i could forget i've zoomed in and forget about a pane in a tab
	local is_zoomed = ""
	if tab.active_pane.is_zoomed then
		is_zoomed = "z"
	end

	return {
		{ Text = " " .. tab.tab_index + 1 .. is_zoomed .. " " },
	}
end)

local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")
bar.apply_to_config(config, { enabled_modules = { hostname = true } })

config.hyperlink_rules = {
	-- Matches: a URL in parens: (URL)
	{
		regex = "\\((\\w+://\\S+)\\)",
		format = "$1",
		highlight = 1,
	},
	-- Matches: a URL in brackets: [URL]
	{
		regex = "\\[(\\w+://\\S+)\\]",
		format = "$1",
		highlight = 1,
	},
	-- Matches: a URL in curly braces: {URL}
	{
		regex = "\\{(\\w+://\\S+)\\}",
		format = "$1",
		highlight = 1,
	},
	-- Matches: a URL in angle brackets: <URL>
	{
		regex = "<(\\w+://\\S+)>",
		format = "$1",
		highlight = 1,
	},
	-- Then handle URLs not wrapped in brackets
	{
		-- Before
		--regex = '\\b\\w+://\\S+[)/a-zA-Z0-9-]+',
		--format = '$0',
		-- After
		regex = "[^(]\\b(\\w+://\\S+[)/a-zA-Z0-9-]+)",
		format = "$1",
		highlight = 1,
	},
	-- implicit mailto link
	{
		regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b",
		format = "mailto:$0",
	},
}

-- local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
-- workspace_switcher.apply_to_config(config)

return config
