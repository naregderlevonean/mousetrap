local M = {}

M._VERSION = "0.7.0"

local path = (...):gsub("%.init$", "")

local core = require(path .. ".core")
local default = require(path .. ".config")
local Binding = require(path .. ".binding")

local function clone(value)
	if type(value) ~= "table" then
		return value
	end

	local result = {}

	for key, item in pairs(value) do
		result[key] = clone(item)
	end

	return result
end

local function merge(target, source)
	if type(source) ~= "table" then
		return
	end

	for key, value in pairs(source) do
		if type(value) == "table" and type(target[key]) == "table" then
			merge(target[key], value)
		else
			target[key] = value
		end
	end
end

local function sort_bindings(list)
	table.sort(list, function(a, b)
		return (a.priority or 0) > (b.priority or 0)
	end)
end

function M.setup(config)
	M.config = clone(default)

	if type(config) == "table" then
		merge(M.config, config)
	end

	M.config.binds = M.config.binds or {}

	core.init(M.config)

	return M
end

function M.reload(config)
	if not M.config then
		return M.setup(config)
	end

	merge(M.config, config or {})

	core.reload(M.config)

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

	local binds = M.config.binds[zone]

	if not binds then
		binds = {}
		M.config.binds[zone] = binds
	end

	table.insert(binds, Binding.new(callback, options))

	sort_bindings(binds)
end

function M.unbind(zone, callback)
	if not M.config or not M.config.binds[zone] then
		return
	end

	local binds = M.config.binds[zone]

	for index = #binds, 1, -1 do
		if not callback or binds[index].callback == callback then
			table.remove(binds, index)
		end
	end
end

function M.state()
	return core.state()
end

function M.debug(enabled)
	if M.config then
		M.config.debug = enabled == true
		core.reload(M.config)
	end
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
