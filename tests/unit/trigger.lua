local Trigger = require("trigger")

local fired = false

local state = {
	zone = "right",

	triggered = false,

	last_x = 0,
	last_y = 0,

	time = 0,

	direction_x = 0,
	direction_y = 0,
}

local binding = {
	flick_sq = 100,

	callback = function()
		fired = true
	end,
}

Trigger.update(state, 20, 0, {}, { binding })

assert(fired == true)

return true
