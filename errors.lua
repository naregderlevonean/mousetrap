local M = {}

local Logger = require((...):gsub("%.errors$", "") .. ".logger")

M.last = nil

function M.capture(err)
	M.last = err

	Logger.error(tostring(err))
end

function M.clear()
	M.last = nil
end

function M.get()
	return M.last
end

return M
