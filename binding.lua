local M = {}

function M.new(callback, options)
	if type(callback) ~= "function" then
		error("mousetrap: callback must be a function")
	end

	options = options or {}

	local modifiers = options.modifiers or options.mod or {}

	local has_flick = type(options.flick) == "number"
	local has_direction = type(options.direction) == "string"

	local binding_modifiers = {}

	for key, value in pairs(modifiers) do
		if value == true then
			binding_modifiers[key] = true
		end
	end

	return {
		callback = callback,

		delay = (has_flick or has_direction)
			and 0
			or (options.delay or 0),

		flick_sq = has_flick
			and (options.flick * options.flick)
			or nil,

		direction = has_direction
			and options.direction
			or nil,

		distance = type(options.distance) == "number"
			and options.distance
			or nil,

		modifiers = binding_modifiers,
	}
end

return M
