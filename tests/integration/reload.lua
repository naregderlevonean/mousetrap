local Bindings = require("bindings")

local context = {
	state = {
		modifiers = {
			ctrl = false,
		},
	},

	config = {
		binds = {
			left = {
				{
					id = 1,

					callback = function() end,
				},
			},
		},
	},
}

Bindings.init(context)

assert(Bindings.find_by_id(1) ~= nil)

context.config = {
	binds = {
		right = {
			{
				id = 2,

				callback = function() end,
			},
		},
	},
}

Bindings.reload(context)

assert(Bindings.find_by_id(2) ~= nil)

assert(Bindings.find_by_id(1) == nil)

return true
