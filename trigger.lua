local M = {}

function M.reset(state, zone, monitor, binding)
	state.zone = zone
	state.monitor = monitor
	state.active_binding = binding

	state.time = 0
	state.triggered = false

	state.direction_x = 0
	state.direction_y = 0
end

function M.exit(state, old_zone, binding, new_zone, monitor)
	if not binding.exit then
		return
	end

	if new_zone ~= "none" then
		return
	end

	state.triggered = true

	pcall(binding.callback, old_zone, monitor)
end

local function check_zone_direction(zone, dx, dy)
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

local function check_direction(direction, dx, dy)
	if direction == "left" then
		return dx < 0
	elseif direction == "right" then
		return dx > 0
	elseif direction == "up" then
		return dy < 0
	elseif direction == "down" then
		return dy > 0
	end

	return false
end

local function fire(state, binding, monitor)
	pcall(binding.callback, state.zone, monitor)

	if binding.loop then
		state.time = 0
		state.direction_x = 0
		state.direction_y = 0
	else
		state.triggered = true
	end
end

function M.update(state, x, y, monitor, binding)
	if not binding then
		return
	end

	if state.triggered then
		return
	end

	local last_x = state.last_x
	local last_y = state.last_y

	if last_x == nil or last_y == nil then
		return
	end

	local dx = x - last_x
	local dy = y - last_y

	if binding.direction then
		state.direction_x = state.direction_x + dx

		state.direction_y = state.direction_y + dy

		if not check_direction(binding.direction, state.direction_x, state.direction_y) then
			return
		end

		if binding.distance then
			local distance = state.direction_x * state.direction_x + state.direction_y * state.direction_y

			if distance < (binding.distance * binding.distance) then
				return
			end
		end

		if binding.flick_sq then
			local distance = state.direction_x * state.direction_x + state.direction_y * state.direction_y

			if distance < binding.flick_sq then
				return
			end
		end

		fire(state, binding, monitor)
		return
	end

	if binding.flick_sq then
		if (dx * dx + dy * dy) < binding.flick_sq then
			return
		end

		if not check_zone_direction(state.zone, dx, dy) then
			return
		end

		fire(state, binding, monitor)

		return
	end

	state.time = state.time + 16

	if state.time >= binding.delay then
		fire(state, binding, monitor)
	end
end

return M
