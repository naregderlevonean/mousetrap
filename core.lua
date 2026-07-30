local M = {}

local path = (...):gsub("%.core$", "")

local state = require(path .. ".state").state
local Geometry = require(path .. ".geometry")
local Bindings = require(path .. ".bindings")
local Trigger = require(path .. ".trigger")

local get_cursor = hl.get_cursor_pos
local get_monitor = hl.get_monitor_at_cursor
local create_timer = hl.timer

local EMPTY_GEOM = {}

local config = nil

local function tick()
	if not config then
		return
	end

	local cursor = get_cursor()
	local monitor = get_monitor()

	if not monitor then
		return
	end

	local geometry = config.geometry[monitor.name] or config.geometry.default or EMPTY_GEOM

	local x = cursor.x - monitor.x
	local y = cursor.y - monitor.y

	local zone = Geometry.get_zone_at_pos(x, y, monitor, geometry)

	local binding = Bindings.get_active_binding(zone)

	if
		zone ~= state.zone
		or monitor.name ~= (state.monitor and state.monitor.name)
		or binding ~= state.active_binding
	then
		Trigger.reset(state, zone, monitor, binding)
	end

	Trigger.update(state, x, y, monitor, binding)

	state.last_x = x
	state.last_y = y
end

function M.init(active_config)
	config = active_config
	Bindings.init(active_config)
end

function M.set_modifiers(modifiers)
	Bindings.set_modifiers(modifiers)
end

function M.start()
	if not state.timer then
		state.last_x = nil
		state.last_y = nil

		state.timer = create_timer(tick, {
			type = "repeat",
			timeout = 16,
		})
	else
		state.last_x = nil
		state.last_y = nil

		state.timer:set_enabled(true)
	end
end

function M.stop()
	if state.timer then
		state.timer:set_enabled(false)
	end

	state.zone = "none"
	state.monitor = nil

	state.time = 0
	state.triggered = false

	state.last_x = nil
	state.last_y = nil

	state.active_binding = nil
end

function M.toggle()
	if not state.timer then
		M.start()
	elseif state.timer:is_enabled() then
		M.stop()
	else
		M.start()
	end
end

function M.status()
	if state.timer then
		return state.timer:is_enabled() == true
	end

	return false
end

return M
