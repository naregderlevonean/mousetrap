local M = {}

M._VERSION = "0.2.0"

local path = (...):gsub("%.init$", "")

local core = require(path .. ".core")
local default = require(path .. ".config")

function M.setup(config)
    M.config = {}
    
    for key, val in pairs(default) do
        if type(val) == "table" then
            M.config[key] = {}
            for sub_key, sub_val in pairs(val) do 
                M.config[key][sub_key] = sub_val 
            end
        else
            M.config[key] = val
        end
    end

    if config and config.geometry then
        for monitor, data in pairs(config.geometry) do
            M.config.geometry[monitor] = data
        end
    end
    
    core.init(M.config)
    return M
end

function M.start() core.start() end
function M.stop()  core.stop()  end
function M.toggle() core.toggle() end

function M.modifiers(mods)
    return function()
        core.set_modifiers(mods)
    end
end

function M.bind(zone, callback, options)
    local has_flick = options and type(options.flick) == "number"
    local delay = (options and options.delay) or 0
    local modifier_options = (options and (options.modifiers or options.mod)) or {}
    
    if has_flick then delay = 0 end

    local normalized_mod = {
        super = modifier_options.super or false,
        shift = modifier_options.shift or false,
        ctrl = modifier_options.ctrl or false,
        alt = modifier_options.alt or false
    }

    if not M.config.binds[zone] then
        M.config.binds[zone] = {}
    end

    table.insert(M.config.binds[zone], {
        callback = callback,
        delay = delay,
        flick_sq = has_flick and (options.flick * options.flick) or nil,
        modifiers = normalized_mod
    })
end

return M
