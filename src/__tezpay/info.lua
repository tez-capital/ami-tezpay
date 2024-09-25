local _json = am.options.OUTPUT_FORMAT == "json"


local _ok, _systemctl = am.plugin.safe_get("systemctl")
ami_assert(_ok, "Failed to load systemctl plugin", EXIT_PLUGIN_LOAD_ERROR)
local _user = am.app.get("user", "root")
_systemctl = _systemctl.with_options({ container = _user })

local _info = {
	level = "ok",
	status = "tezpay is operational",
	version = am.app.get_version(),
	type = am.app.get_type(),
	services = {}
}

local _appId = am.app.get("id")
-- strip id prefix
local function strip_app_id(id)
	return id:match("^" .. util.escape_magic_characters(_appId) .. "%-(.+)$")
end

local _services = require "__tezpay.services"
for k in pairs(_services.get_installed_services()) do
	local _ok, _status, _started = _systemctl.safe_get_service_status(k)
	ami_assert(_ok, "Failed to get status of " .. k .. ".service " .. (_status or ""), EXIT_PLUGIN_EXEC_ERROR)

	_info.services[strip_app_id(k)] = {
		status = _status,
		started = _started
	}
	if _status ~= "running" then
		_info.status = "One or more tezpay services is not running!"
		_info.level = "error"
	end
end

if _json then
	print(hjson.stringify_to_json(_info, { indent = false }))
else
	print(hjson.stringify(_info, { sortKeys = true }))
end
