local M = {}

M._VERSION = "0.1.0"

local path = (...):match("(.-)[^%.]+$")

local core = require(path .. ".core")
local default = require(path .. ".config")

function M.setup(config)
    M.config = {}
    
    for key, val in pairs(default) do
        if type(val) == "table" then
            M.config[key] = {}
            for sub_key, sub_val in pairs(val) do M.config[key][sub_key] = sub_val end
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

function M.start()
    core.start()
end

function M.stop()
    core.stop() 
end

function M.toggle()
    core.toggle()
end

function M.bind(zone, callback, opts)
    M.config.binds[zone] = {
        callback = callback,
        delay = (opts and opts.delay) or 0
    }
end

return M

