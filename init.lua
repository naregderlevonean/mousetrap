local M = {}

M._VERSION = "0.4.0"

local path = (...):gsub("%.init$", "")

local core = require(path .. ".core")
local default = require(path .. ".config")
local Binding = require(path .. ".binding")

local function clone(tbl)
	local result = {}

	for key, value in pairs(tbl) do
		if type(value) == "table" then
			result[key] = clone(value)
		else
			result[key] = value
		end
	end

	return result
end

function M.setup(config)
	M.config = clone(default)

	if config and config.geometry then
		for monitor, geometry in pairs(config.geometry) do
			M.config.geometry[monitor] = geometry
		end
	end

	core.init(M.config)

	return M
end

function M.modifiers(mods)
	return function()
		core.set_modifiers(mods)
	end
end

function M.bind(zone, callback, options)
	if not M.config then
		error("mousetrap: call setup() before bind()")
	end

	if not M.config.binds[zone] then
		M.config.binds[zone] = {}
	end

	table.insert(M.config.binds[zone], Binding.new(callback, options))
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

function M.status()
	return core.status()
end

return M
