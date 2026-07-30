local M = {}

function M.reset(state, zone, monitor, binding)
	local old_binding = state.active_binding

	state.zone = zone
	state.monitor = monitor
	state.active_binding = binding

	state.time = 0
	state.triggered = false

	state.direction_x = 0
	state.direction_y = 0

	if old_binding and old_binding ~= binding and old_binding.on_leave then
		pcall(old_binding.on_leave, zone, monitor)
	end

	if binding and binding.on_enter then
		pcall(binding.on_enter, zone, monitor)
	end
end

function M.exit(state, old_zone, binding, new_zone, monitor)
	if not binding or not binding.exit then
		return
	end

	if new_zone ~= "none" then
		return
	end

	state.triggered = true

	pcall(binding.callback, old_zone, monitor)
end

local function distance_sq(x, y)
	return x * x + y * y
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

	if binding.on_trigger then
		pcall(binding.on_trigger, state.zone, monitor)
	end

	if binding.loop then
		state.time = 0
		state.direction_x = 0
		state.direction_y = 0
	else
		state.triggered = true
	end
end

function M.update(state, x, y, monitor, binding)
	if not binding or state.triggered then
		return
	end

	if state.last_x == nil or state.last_y == nil then
		return
	end

	local dx = x - state.last_x
	local dy = y - state.last_y

	if binding.direction then
		state.direction_x = state.direction_x + dx
		state.direction_y = state.direction_y + dy

		if not check_direction(binding.direction, state.direction_x, state.direction_y) then
			return
		end

		if
			binding.distance
			and distance_sq(state.direction_x, state.direction_y) < binding.distance * binding.distance
		then
			return
		end

		fire(state, binding, monitor)

		return
	end

	if binding.velocity_sq then
		if distance_sq(dx, dy) < binding.velocity_sq then
			return
		end

		if not check_zone_direction(state.zone, dx, dy) then
			return
		end

		fire(state, binding, monitor)

		return
	end

	if binding.flick_sq then
		if distance_sq(dx, dy) < binding.flick_sq then
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
