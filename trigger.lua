local M = {}

function M.reset(state, zone, monitor, binding)
	state.zone = zone
	state.monitor = monitor
	state.active_binding = binding

	state.time = 0
	state.triggered = false
end

local function check_direction(zone, dx, dy)
	if zone == "top" then
		return dy < -5
	elseif zone == "bottom" then
		return dy > 5
	elseif zone == "left" then
		return dx < -5
	elseif zone == "right" then
		return dx > 5
	elseif zone == "top-left" then
		return dx < -3 and dy < -3
	elseif zone == "top-right" then
		return dx > 3 and dy < -3
	elseif zone == "bottom-left" then
		return dx < -3 and dy > 3
	elseif zone == "bottom-right" then
		return dx > 3 and dy > 3
	end

	return false
end

function M.update(state, x, y, monitor, binding)
	if state.triggered or not binding then
		return
	end

	if binding.flick_sq then
		local last_x = state.last_x
		local last_y = state.last_y

		if last_x == nil or last_y == nil then
			return
		end

		local dx = x - last_x
		local dy = y - last_y

		if (dx * dx + dy * dy) < binding.flick_sq then
			return
		end

		if not check_direction(state.zone, dx, dy) then
			return
		end

		state.triggered = true

		pcall(binding.callback, state.zone, monitor)

		return
	end

	state.time = state.time + 16

	if state.time >= binding.delay then
		state.triggered = true

		pcall(binding.callback, state.zone, monitor)
	end
end

return M
