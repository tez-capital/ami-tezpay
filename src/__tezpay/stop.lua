local _ok, _systemctl = am.plugin.safe_get("systemctl")
ami_assert(_ok, "Failed to load systemctl plugin")

local _user = am.app.get("user", "root")
_systemctl = _systemctl.with_options({ container = _user })

local _services = require"__tezpay.services"

log_info("Stopping tezpay services... this may take few minutes.")
for _, service in pairs(_services.allNames) do
	-- skip false values
	if type(service) ~= "string" then goto CONTINUE end
	local _ok, _error = _systemctl.safe_stop_service(service)
	ami_assert(_ok, "Failed to stop " .. service .. ".service " .. (_error or ""))
	::CONTINUE::
end
log_success("tezpay services succesfully stopped.")