local hjson = require "hjson"

local version = os.getenv("VERSION")
if not version then
	os.exit(222)
end

-- Update sources.hjson with new tezpay version
local sources_raw = fs.read_file("./src/__xtz/sources.hjson")
sources_raw = sources_raw:gsub("tezpay/releases/download/%d-%.%d-%.%d-[^/]*", "tezpay/releases/download/" .. version)
fs.write_file("./src/__xtz/sources.hjson", sources_raw)

-- Update version field in sources.hjson for tezpay entries
local sources = hjson.parse(sources_raw)
for platform, platform_sources in pairs(sources) do
	if type(platform_sources) == "table" and platform_sources.tezpay then
		platform_sources.tezpay.version = version
	end
end
-- Preserve header comment
local header = "// tezpay SOURCE: https://github.com/tez-capital/tezpay/releases \n"
fs.write_file("./src/__xtz/sources.hjson", header .. hjson.stringify(sources, { separator = true, sort_keys = true }))

-- Update specs.json version
local specs_raw = fs.read_file("./src/specs.json")
local specs = hjson.parse(specs_raw)
local package_version = string.split(specs.version, "+", true)[1]
local package_version_patch = tonumber(string.split(package_version, ".", true)[3])
package_version_patch = package_version_patch + 1
package_version = string.split(package_version, ".", true)[1] ..
"." .. string.split(package_version, ".", true)[2] .. "." .. package_version_patch
specs.version = package_version .. "+" .. version

fs.write_file("./src/specs.json", hjson.stringify_to_json(specs, { indent = "    " }))

print("VERSION=" .. specs.version)
