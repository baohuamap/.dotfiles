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
	colors = {
		"#0f0c29",
		"#302b63",
		"#24243e",
	},

	-- Instead of specifying `colors`, you can use one of a number of
	-- predefined, preset gradients.
	-- A list of presets is shown in a section below.
	-- preset = "Warm",

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

config.font = wezterm.font("JetBrains Mono")
config.font_size = 19

config.enable_tab_bar = false

config.window_decorations = "RESIZE"
config.window_background_opacity = 0.9
config.macos_window_background_blur = 20

-- and finally, return the configuration to wezterm
return config
