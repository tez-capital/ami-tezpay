local hjson = require"hjson"

local version = os.getenv("VERSION")
if not version then
	os.exit(222)
end
local constants = fs.read_file("./src/__tezpay/constants.lua")
constants = constants:gsub("tezpay/releases/download/%d-%.%d-%.%d-[^/]*", "tezpay/releases/download/" .. version)
fs.write_file("./src/__tezpay/constants.lua", constants)

local specsContent = fs.read_file("./src/specs.json")
local specs = hjson.parse(specsContent)
local packageVersion = string.split(specs.version, "+", true)[1]
local packageVersionPatch = tonumber(string.split(packageVersion, ".", true)[3])
packageVersionPatch = packageVersionPatch + 1
packageVersion = string.split(packageVersion, ".", true)[1] .. "." .. string.split(packageVersion, ".", true)[2] .. "." .. packageVersionPatch
specs.version = packageVersion .. "+" .. version

fs.write_file("./src/specs.json", hjson.stringify_to_json(specs, { indent = "    " }))

print("VERSION=" .. specs.version)