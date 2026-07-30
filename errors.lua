local M = {}

M.last = nil

function M.capture(err)
	M.last = err
end

function M.clear()
	M.last = nil
end

function M.get()
	return M.last
end

return M
