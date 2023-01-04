local _json = am.options.OUTPUT_FORMAT == "json"


local _ok, _systemctl = am.plugin.safe_get("systemctl")
ami_assert(_ok, "Failed to load systemctl plugin", EXIT_PLUGIN_LOAD_ERROR)

local _info = {
	level = "ok",
	status = "tezpay is operational",
	version = am.app.get_version(),
	type = am.app.get_type(),
	services = {}
}


local _services = require "__tezpay.services"
for k, v in pairs(_services.allNames) do
	if type(v) ~= "string" then goto CONTINUE end
	local _ok, _status, _started = _systemctl.safe_get_service_status(v)
	ami_assert(_ok, "Failed to get status of " .. v .. ".service " .. (_status or ""), EXIT_PLUGIN_EXEC_ERROR)
	_info.services[k] = {
		status = _status,
		started = _started
	}
	if _status ~= "running" then
		_info.status = "One or more tezpay services is not running!"
		_info.level = "error"
	end
	::CONTINUE::
end

if _json then
	print(hjson.stringify_to_json(_info, { indent = false }))
else
	print(hjson.stringify(_info, { sortKeys = true }))
end
