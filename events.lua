local M = {}

local queue = {}

function M.push(name, data)
	queue[#queue + 1] = {
		name = name,
		data = data,
	}
end

function M.pop()
	if #queue == 0 then
		return nil
	end

	local event = queue[1]

	table.remove(queue, 1)

	return event
end

function M.clear()
	queue = {}
end

return M
