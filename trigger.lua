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

local function zone_direction(zone, dx, dy, state_motion)
	local cardinal = state_motion and state_motion.cardinal or 5
	local diagonal = state_motion and state_motion.diagonal or 3

	local check = {
		top = dy < -cardinal,
		bottom = dy > cardinal,
		left = dx < -cardinal,
		right = dx > cardinal,

		["top-left"] = dx < -diagonal and dy < -diagonal,
		["top-right"] = dx > diagonal and dy < -diagonal,
		["bottom-left"] = dx < -diagonal and dy > diagonal,
		["bottom-right"] = dx > diagonal and dy > diagonal,
	}

	return check[zone] == true
end

function M.reset(state, zone, monitor, bindings)
	state.zone = zone
	state.monitor = monitor
	state.active_bindings = bindings

	state.time = 0
	state.triggered = false

	state.direction_x = 0
	state.direction_y = 0
end

function M.exit(state, old_zone, binding, new_zone, monitor)
	if not binding or not binding.exit then
		return
	end

	if new_zone ~= "none" then
		return
	end

	state.triggered = true

	local ok, err = pcall(binding.callback, old_zone, monitor)
	if not ok and state.debug then
		print("[mousetrap][error] Exit callback failed:", err)
	end
end

local function fire(state, binding, monitor)
	local ok, err = pcall(binding.callback, state.zone, monitor)

	if not ok then
		print("[mousetrap][error] Callback runtime failure:", err)
		return err
	end

	if binding.loop then
		state.time = 0
		state.direction_x = 0
		state.direction_y = 0
	else
		state.triggered = true
	end
end

local function check_binding(state, binding, dx, dy, monitor)
	if binding.direction then
		local checker = directions[binding.direction]
		if checker then
			local moves_correctly = checker(dx, dy)
			if not moves_correctly and dx ~= 0 and dy ~= 0 then
				state.direction_x = 0
				state.direction_y = 0
			end
		end

		state.direction_x = state.direction_x + dx
		state.direction_y = state.direction_y + dy

		if not checker or not checker(state.direction_x, state.direction_y) then
			return false
		end

		if
			binding.distance
			and distance_sq(state.direction_x, state.direction_y) < binding.distance * binding.distance
		then
			return false
		end

		fire(state, binding, monitor)
		return true
	end

	if binding.velocity_sq then
		if distance_sq(dx, dy) < binding.velocity_sq then
			return false
		end

		if not zone_direction(state.zone, dx, dy, state.motion) then
			return false
		end

		fire(state, binding, monitor)
		return true
	end

	if binding.flick_sq then
		if distance_sq(dx, dy) < binding.flick_sq then
			return false
		end

		if not zone_direction(state.zone, dx, dy, state.motion) then
			return false
		end

		fire(state, binding, monitor)
		return true
	end

	state.time = state.time + (state.timer_interval or 16)

	if state.time >= binding.delay then
		fire(state, binding, monitor)
		return true
	end

	return false
end

function M.update(state, x, y, monitor, bindings)
	if not bindings or state.triggered then
		return
	end

	if state.last_x == nil or state.last_y == nil then
		return
	end

	local dx = x - state.last_x
	local dy = y - state.last_y

	for _, binding in ipairs(bindings) do
		if check_binding(state, binding, dx, dy, monitor) then
			return
		end
	end
end

return M
