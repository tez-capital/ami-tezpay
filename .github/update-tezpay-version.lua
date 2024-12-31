local hjson = require"hjson"

local version = os.getenv("VERSION")
if not version then
	os.exit(222)
end
local constants = fs.read_file("./src/__tezpay/constants.lua")
constants = constants:gsub("tezpay/releases/download/%d-%.%d-%.%d-[^/]*", "tezpay/releases/download/" .. version)
fs.write_file("./src/__tezpay/constants.lua", constants)

local specs_raw = fs.read_file("./src/specs.json")
local specs = hjson.parse(specs_raw)
local pacakge_version = string.split(specs.version, "+", true)[1]
local package_version_patch = tonumber(string.split(pacakge_version, ".", true)[3])
package_version_patch = package_version_patch + 1
pacakge_version = string.split(pacakge_version, ".", true)[1] .. "." .. string.split(pacakge_version, ".", true)[2] .. "." .. package_version_patch
specs.version = pacakge_version .. "+" .. version

fs.write_file("./src/specs.json", hjson.stringify_to_json(specs, { indent = "    " }))

print("VERSION=" .. specs.version)