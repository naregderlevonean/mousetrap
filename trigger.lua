local M = {}

local directions = {
	left = function(dx)
		return dx < 0
	end,

	right = function(dx)
		return dx > 0
	end,

	up = function(_, dy)
		return dy < 0
	end,

	down = function(_, dy)
		return dy > 0
	end,
}

local function distance_sq(x, y)
	return x * x + y * y
end

local function zone_direction(zone, dx, dy)
	local state = {
		top = dy < -5,
		bottom = dy > 5,
		left = dx < -5,
		right = dx > 5,

		["top-left"] = dx < -3 and dy < -3,
		["top-right"] = dx > 3 and dy < -3,
		["bottom-left"] = dx < -3 and dy > 3,
		["bottom-right"] = dx > 3 and dy > 3,
	}

	return state[zone] == true
end

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

local function fire(state, binding, monitor)
	local ok, err = pcall(binding.callback, state.zone, monitor)

	if not ok then
		return err
	end

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

		local checker = directions[binding.direction]

		if not checker or not checker(state.direction_x, state.direction_y) then
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

		if not zone_direction(state.zone, dx, dy) then
			return
		end

		fire(state, binding, monitor)

		return
	end

	if binding.flick_sq then
		if distance_sq(dx, dy) < binding.flick_sq then
			return
		end

		if not zone_direction(state.zone, dx, dy) then
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
