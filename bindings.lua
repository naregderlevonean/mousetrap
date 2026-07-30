local M = {}

local path = (...):gsub("%.bindings$", "")

local state = require(path .. ".state").state

local config = nil

local cache = {
	zone = nil,
	binding = nil,
	exit_zone = nil,
	exit_binding = nil,
}

local function clear_cache()
	cache.zone = nil
	cache.binding = nil
	cache.exit_zone = nil
	cache.exit_binding = nil
end

function M.init(active_config)
	config = active_config
	clear_cache()
end

function M.set_modifiers(modifiers)
	if type(modifiers) ~= "table" then
		return
	end

	for key, value in pairs(modifiers) do
		if state.modifiers[key] ~= nil then
			state.modifiers[key] = value == true
		end
	end

	clear_cache()
end

local function modifiers_match(required)
	if not required then
		return true
	end

	for key, value in pairs(required) do
		if state.modifiers[key] ~= value then
			return false
		end
	end

	return true
end

local function get_zone_bindings(zone)
	if not config or type(config.binds) ~= "table" then
		return nil
	end

	local binds = config.binds[zone]

	if type(binds) ~= "table" then
		return nil
	end

	return binds
end

function M.get_active_binding(zone)
	if cache.zone == zone then
		return cache.binding
	end

	cache.zone = zone
	cache.binding = nil

	local binds = get_zone_bindings(zone)

	if not binds then
		return nil
	end

	for _, binding in ipairs(binds) do
		if type(binding) == "table" and not binding.exit then
			if modifiers_match(binding.modifiers) then
				cache.binding = binding
				return binding
			end
		end
	end

	return nil
end

function M.get_exit_binding(zone)
	if cache.exit_zone == zone then
		return cache.exit_binding
	end

	cache.exit_zone = zone
	cache.exit_binding = nil

	local binds = get_zone_bindings(zone)

	if not binds then
		return nil
	end

	for _, binding in ipairs(binds) do
		if type(binding) == "table" and binding.exit then
			if modifiers_match(binding.modifiers) then
				cache.exit_binding = binding
				return binding
			end
		end
	end

	return nil
end

return M
