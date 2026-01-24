local hjson = require "hjson"

local specs = fs.read_file("./src/specs.json")
local specs_json = hjson.parse(specs)
print("VERSION=" .. specs_json.version)
