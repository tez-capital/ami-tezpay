local hjson = require"hjson"

local specs_raw = fs.read_file("./src/specs.json")
local specs = hjson.parse(specs_raw)

print("ID=" .. specs.id)
print("VERSION=" .. specs.version)