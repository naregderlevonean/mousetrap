local Bindings = require("bindings")

local state = {
	modifiers = {
		ctrl = false,
		shift = false,
	},
}

local context = {
	state = state,

	config = {
		binds = {
			right = {
				{
					callback = function() end,

					modifiers = {
						ctrl = true,
					},
				},
			},
		},
	},
}

Bindings.init(context)

assert(Bindings.get_active_binding("right") == nil)

Bindings.set_modifiers({
	ctrl = true,
})

assert(Bindings.get_active_binding("right") ~= nil)

return true
