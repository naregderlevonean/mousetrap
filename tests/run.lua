local tests = {
	"tests.geometry_test",
	"tests.binding_test",
	"tests.trigger_test",
}

for _, test in ipairs(tests) do
	local ok, result = pcall(require, test)

	assert(ok and result == true, test)
end

print("mousetrap tests passed")
