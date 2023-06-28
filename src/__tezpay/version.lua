print("ami-tezpay: " .. am.app.get_version())
local handle <close> = io.popen("bin/tezpay version", "r")
if handle ~= nil then
	local version = handle:read("*a")
	print("tezpay: ".. version)
end