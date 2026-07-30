local M = {}

M.state = {
	timer = nil,

	monitor = nil,
	zone = "none",

	time = 0,
	triggered = false,

	last_x = nil,
	last_y = nil,

	active_binding = nil,

	modifiers = {
		super = false,
		shift = false,
		ctrl = false,
		alt = false,
	},
}

return M
