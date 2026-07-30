local Binding = require("binding")

local fixture = require("fixtures.binding")

local binding = Binding.new(fixture.callback, {
	flick = 20,

	priority = 5,

	modifiers = fixture.modifiers,
})

assert(type(binding.id) == "number")

assert(binding.flick_sq == 400)

assert(binding.priority == 5)

assert(binding.modifiers.ctrl == true)

return true
