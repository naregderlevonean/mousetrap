local M = {}

M._VERSION = "0.9.0"

local path = (...):gsub("%.init$", "")

local core = require(path .. ".core")
local default = require(path .. ".config")
local Binding = require(path .. ".binding")
local Bindings = require(path .. ".bindings")
local Validator = require(path .. ".validator")
local Logger = require(path .. ".logger")

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

	local valid, err = Validator.validate(M.config)

	if not valid then
		Logger.error(err)

		error("mousetrap: invalid configuration: " .. err)
	end

	core.init(M.config)

	return M
end

function M.reload(config)
	if not M.config then
		return M.setup(config)
	end

	merge(M.config, config or {})

	local valid, err = Validator.validate(M.config)

	if not valid then
		Logger.error(err)

		return false
	end

	core.reload(M.config)

	return M
end

function M.validate(config)
	local target = clone(default)

	merge(target, config or {})

	return Validator.validate(target)
end

function M.log_level(level)
	Logger.set_level(level)
end

function M.logger()
	return Logger
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

	local binding = Binding.new(callback, options)

	table.insert(binds, binding)

	sort_bindings(binds)

	Bindings.clear_cache()

	return binding.id
end

function M.remove_binding(id)
	return Bindings.remove(id)
end

function M.find_binding(id)
	return Bindings.find_by_id(id)
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

	Bindings.clear_cache()
end

function M.events()
	return core.events()
end

function M.state()
	return core.state()
end

function M.last_error()
	return require(path .. ".errors").get()
end

function M.clear_error()
	require(path .. ".errors").clear()
end

function M.debug(enabled)
	if not M.config then
		return
	end

	M.config.debug = enabled == true

	core.reload(M.config)
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
