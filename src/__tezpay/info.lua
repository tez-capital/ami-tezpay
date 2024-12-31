local needs_json_output = am.options.OUTPUT_FORMAT == "json"


local ok, systemctl = am.plugin.safe_get("systemctl")
ami_assert(ok, "Failed to load systemctl plugin", EXIT_PLUGIN_LOAD_ERROR)
local user = am.app.get("user", "root")
systemctl = systemctl.with_options({ container = user })

local info = {
	level = "ok",
	status = "tezpay is operational",
	version = am.app.get_version(),
	type = am.app.get_type(),
	services = {}
}

local app_id = am.app.get("id")
-- strip id prefix
local function strip_app_id(id)
	return id:match("^" .. util.escape_magic_characters(app_id) .. "%-(.+)$")
end

local services = require "__tezpay.services"
for k in pairs(services.get_installed_services()) do
	local ok, status, started = systemctl.safe_get_service_status(k)
	ami_assert(ok, "Failed to get status of " .. k .. ".service " .. (status or ""), EXIT_PLUGIN_EXEC_ERROR)

	info.services[strip_app_id(k)] = {
		status = status,
		started = started
	}
	if status ~= "running" then
		info.status = "One or more tezpay services is not running!"
		info.level = "error"
	end
end

if needs_json_output then
	print(hjson.stringify_to_json(info, { indent = false }))
else
	print(hjson.stringify(info, { sortKeys = true }))
end
