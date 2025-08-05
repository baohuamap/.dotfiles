-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config.window_background_gradient = {
	-- Can be "Vertical" or "Horizontal".  Specifies the direction
	-- in which the color gradient varies.  The default is "Horizontal",
	-- with the gradient going from left-to-right.
	-- Linear and Radial gradients are also supported; see the other
	-- examples below
	orientation = "Vertical",

	-- Specifies the set of colors that are interpolated in the gradient.
	-- Accepts CSS style color specs, from named colors, through rgb
	-- strings and more
	--	colors = {
	--		"#0f0c29",
	--		"#302b63",
	--		"#24243e",
	--	},
	colors = {
		"#12101c", -- slightly dulled version of #0f0c29
		"#2a2750", -- dulled version of #302b63
		"#1f1f33", -- muted version of #24243e
	},

	-- Instead of specifying `colors`, you can use one of a number of
	-- predefined, preset gradients.
	-- A list of presets is shown in a section below.
	-- preset = "BuPu",

	-- Specifies the interpolation style to be used.
	-- "Linear", "Basis" and "CatmullRom" as supported.
	-- The default is "Linear".
	interpolation = "Linear",

	-- How the colors are blended in the gradient.
	-- "Rgb", "LinearRgb", "Hsv" and "Oklab" are supported.
	-- The default is "Rgb".
	blend = "Rgb",

	-- To avoid vertical color banding for horizontal gradients, the
	-- gradient position is randomly shifted by up to the `noise` value
	-- for each pixel.
	-- Smaller values, or 0, will make bands more prominent.
	-- The default value is 64 which gives decent looking results
	-- on a retina macbook pro display.
	-- noise = 64,

	-- By default, the gradient smoothly transitions between the colors.
	-- You can adjust the sharpness by specifying the segment_size and
	-- segment_smoothness parameters.
	-- segment_size configures how many segments are present.
	-- segment_smoothness is how hard the edge is; 0.0 is a hard edge,
	-- 1.0 is a soft edge.

	-- segment_size = 11,
	-- segment_smoothness = 0.0,
}

config.color_scheme = "Catppuccin Macchiato (Gogh)"

config.font = wezterm.font({
	family = "JetBrains Mono",
	weight = "Bold",
	stretch = "Expanded",
})
config.font_size = 19

config.enable_tab_bar = false

config.window_decorations = "RESIZE"
config.window_background_opacity = 0.9
config.macos_window_background_blur = 20
config.enable_scroll_bar = true
config.enable_wayland = false

-- Padding
config.window_padding = { left = 10, right = 10, top = 10, bottom = 10 }

-- Tab bar
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = true
config.colors = {
	tab_bar = {
		background = "#282828",
		active_tab = {
			bg_color = "#458588",
			fg_color = "#ffffff",
			intensity = "Bold",
		},
		inactive_tab = {
			bg_color = "#3c3836",
			fg_color = "#a89984",
		},
	},
}

-- Inactive pane visibility
config.inactive_pane_hsb = {
	saturation = 0.9,
	brightness = 0.6,
}

-- and finally, return the configuration to wezterm
return config
