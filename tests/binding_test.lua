local Binding = require("mousetrap.binding")

local callback = function() end

local binding = Binding.new(callback, {
	flick = 20,
	priority = 5,
	modifiers = {
		ctrl = true,
	},
})

assert(type(binding.id) == "number")

assert(binding.flick_sq == 400)

assert(binding.priority == 5)

assert(binding.modifiers.ctrl == true)

return true
