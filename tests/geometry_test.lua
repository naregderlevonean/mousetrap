local Geometry = require("mousetrap.geometry")

local monitor = {
	width = 1920,
	height = 1080,
	scale = 1,
	transform = 0,
}

local config = {
	corner = 10,
	edge = 5,
}

assert(Geometry.get_zone_at_pos(0, 0, monitor, config) == "top-left")

assert(Geometry.get_zone_at_pos(1919, 0, monitor, config) == "top-right")

assert(Geometry.get_zone_at_pos(960, 540, monitor, config) == "none")

assert(Geometry.get_zone_at_pos(0, 540, monitor, config) == "left")

return true
