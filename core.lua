local M = {}

local state = {
    timer = nil,
    monitor = nil,
    zone = "none",
    time = 0,
    triggered = false
}

local get_cursor = hl.get_cursor_pos
local get_monitor = hl.get_monitor_at_cursor
local create_timer = hl.timer

local EMPTY_GEOM = {}
local config = nil

local function get_zone_at_pos(x, y, monitor, geometry)
    local scale = monitor.scale or 1
    local width, height = monitor.width / scale, monitor.height / scale
    
    local transform = monitor.transform or 0
    if transform == 1 or transform == 3 then
        width, height = height, width
    end

    local corner = geometry.corner or 4
    local edge = geometry.edge or 2

    if y < corner then
        if x < corner then return "top-left" end
        if x > (width - corner) then return "top-right" end
        if y < edge then return "top" end
    elseif y > (height - corner) then
        if x < corner then return "bottom-left" end
        if x > (width - corner) then return "bottom-right" end
        if y > (height - edge) then return "bottom" end
    elseif x < edge then return "left"
    elseif x > (width - edge) then return "right"
    end
    
    return "none"
end

local function tick()
    if not config then return end
    
    local cursor = get_cursor()
    local monitor = get_monitor()
    if not monitor then return end

    local geometry = config.geometry[monitor.name] or config.geometry.default or EMPTY_GEOM
    local x, y = cursor.x - monitor.x, cursor.y - monitor.y
    local zone = get_zone_at_pos(x, y, monitor, geometry)

    if zone ~= state.zone or monitor.name ~= state.monitor then
        state.zone, state.monitor = zone, monitor.name
        state.time, state.triggered = 0, false
    elseif zone ~= "none" and not state.triggered then
        state.time = state.time + 16
    end

    if zone ~= "none" and not state.triggered then
        local binding = config.binds[zone]
        if binding and state.time >= (binding.delay or 0) then 
            state.triggered = true
            binding.callback(zone, monitor.name)
        end
    end
end

function M.init(active_config)
    config = active_config
end

function M.start()
    if not state.timer then
        state.timer = create_timer(tick, { type = "repeat", timeout = 16 })
    else
        state.timer:set_enabled(true)
    end
end

function M.stop()
    if state.timer then state.timer:set_enabled(false) end
    state.zone, state.monitor, state.time, state.triggered = "none", nil, 0, false
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

return M
