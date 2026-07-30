package.path = "./?.lua;"
	.. "./?/init.lua;"
	.. "./tests/?.lua;"
	.. "./tests/?/init.lua;"
	.. "./tests/?/?.lua;"
	.. package.path

_G.hl = require("mocks.hl")

local tests = {
	"unit.geometry",
	"unit.binding",
	"unit.modifiers",
	"unit.trigger",
	"integration.reload",
}

local passed = 0
local failed = 0

for _, test in ipairs(tests) do
	local ok, result = pcall(require, test)

	if ok and result == true then
		passed = passed + 1

		print("[PASS]", test)
	else
		failed = failed + 1

		print("[FAIL]", test)

		print(result)
	end
end

print("")

print("passed:", passed)

print("failed:", failed)

if failed > 0 then
	error("mousetrap tests failed")
end

return true
