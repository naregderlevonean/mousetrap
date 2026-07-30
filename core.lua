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

local function reset_position()
	state.last_x = nil
	state.last_y = nil
end

local function get_geometry(monitor)
	if not config or not config.geometry then
		return EMPTY_GEOM
	end

	return config.geometry[monitor.name] or config.geometry.default or EMPTY_GEOM
end

local function same_monitor(a, b)
	return a and b and a.name == b.name
end

local function process_cursor()
	if not config then
		return
	end

	local cursor = get_cursor()

	if not cursor then
		return
	end

	local monitor = get_monitor()

	if not monitor then
		return
	end

	local geometry = get_geometry(monitor)

	local x = cursor.x - monitor.x
	local y = cursor.y - monitor.y

	local zone = Geometry.get_zone_at_pos(x, y, monitor, geometry)

	local binding = Bindings.get_active_binding(zone)

	if zone ~= state.zone then
		local exit_binding = Bindings.get_exit_binding(state.zone)

		if exit_binding then
			Trigger.exit(state, state.zone, exit_binding, zone, monitor)
		end
	end

	if zone ~= state.zone or not same_monitor(state.monitor, monitor) or binding ~= state.active_binding then
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
		state.timer = create_timer(process_cursor, {
			type = "repeat",
			timeout = 16,
		})
	else
		state.timer:set_enabled(true)
	end

	reset_position()
end

function M.stop()
	if state.timer then
		state.timer:set_enabled(false)
	end

	state.zone = "none"
	state.monitor = nil
	state.active_binding = nil

	state.time = 0
	state.triggered = false

	state.direction_x = 0
	state.direction_y = 0

	reset_position()
end

function M.toggle()
	if not state.timer then
		M.start()
		return
	end

	if state.timer:is_enabled() then
		M.stop()
	else
		M.start()
	end
end

function M.status()
	if not state.timer then
		return false
	end

	return state.timer:is_enabled() == true
end

return M
