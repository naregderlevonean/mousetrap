local M = {}

local state = {
    timer = nil,
    monitor = nil,
    zone = "none",
    time = 0,
    triggered = false,
    last_x = nil,
    last_y = nil,
    active_binding = nil, 
    modifiers = {
        super = false,
        shift = false,
        ctrl = false,
        alt = false
    }
}

local get_cursor = hl.get_cursor_pos
local get_monitor = hl.get_monitor_at_cursor
local create_timer = hl.timer

local EMPTY_GEOM = {}
local config = nil

local function get_zone_at_pos(x, y, monitor, geometry)
    local scale = monitor.scale or 1
    local inv_scale = 1 / scale
    local width, height = monitor.width * inv_scale, monitor.height * inv_scale
    
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

local function get_active_binding(zone)
    if not config or not config.binds then return nil end
    local binds = config.binds[zone]
    if not binds then return nil end

    local sm = state.modifiers
    for _, b in ipairs(binds) do
        local bm = b.modifiers
        if bm.super == sm.super and
           bm.shift == sm.shift and
           bm.ctrl == sm.ctrl and
           bm.alt == sm.alt then
            return b
        end
    end
    return nil
end

local function tick()
    if not config then return end
    
    local cursor = get_cursor()
    local monitor = get_monitor()
    if not monitor then return end

    local geometry = config.geometry[monitor.name] or config.geometry.default or EMPTY_GEOM
    local x, y = cursor.x - monitor.x, cursor.y - monitor.y
    local zone = get_zone_at_pos(x, y, monitor, geometry)
    local binding = get_active_binding(zone)

    local last_x = state.last_x
    local last_y = state.last_y
    state.last_x, state.last_y = x, y

    local velocity_sq = 0
    if last_x and last_y then
        local dx = x - last_x
        local dy = y - last_y
        velocity_sq = (dx * dx) + (dy * dy)
    end

    if zone ~= state.zone or monitor.name ~= state.monitor or binding ~= state.active_binding then
        state.zone, state.monitor, state.active_binding = zone, monitor.name, binding
        state.time = 0
        state.triggered = false
    end

    if zone ~= "none" and binding and not state.triggered then
        if binding.flick_sq then
            if velocity_sq >= binding.flick_sq then
                state.triggered = true
                binding.callback(zone, monitor.name)
            end
        else
            state.time = state.time + 16
            if state.time >= binding.delay then 
                state.triggered = true
                binding.callback(zone, monitor.name)
            end
        end
    end
end

function M.init(active_config)
    config = active_config
end

function M.set_modifiers(modifiers)
    if type(modifiers) ~= "table" then return end
    for k, v in pairs(modifiers) do
        if state.modifiers[k] ~= nil then
            state.modifiers[k] = v
        end
    end
end

function M.start()
    if not state.timer then
        state.last_x, state.last_y = nil, nil
        state.timer = create_timer(tick, { type = "repeat", timeout = 16 })
    else
        state.last_x, state.last_y = nil, nil
        state.timer:set_enabled(true)
    end
end

function M.stop()
    if state.timer then state.timer:set_enabled(false) end
    state.zone, state.monitor, state.time, state.triggered = "none", nil, 0, false
    state.last_x, state.last_y = nil, nil
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

