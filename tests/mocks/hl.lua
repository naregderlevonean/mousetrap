local M = {}

local cursor = {
	x = 0,
	y = 0,
}

local monitor = require("fixtures.monitor")

function M.set_cursor(x, y)
	cursor.x = x
	cursor.y = y
end

function M.get_cursor_pos()
	return cursor
end

function M.set_monitor(value)
	monitor = value
end

function M.get_monitor_at_cursor()
	return monitor
end

function M.timer(callback)
	local timer = {
		enabled = false,
		callback = callback,
	}

	function timer:set_enabled(value)
		self.enabled = value == true
	end

	function timer:is_enabled()
		return self.enabled
	end

	function timer:tick()
		if self.enabled then
			self.callback()
		end
	end

	return timer
end

return M
