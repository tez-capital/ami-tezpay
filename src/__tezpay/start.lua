local _ok, _systemctl = am.plugin.safe_get("systemctl")
ami_assert(_ok, "Failed to load systemctl plugin")
local _user = am.app.get("user", "root")
_systemctl = _systemctl.with_options({ container = _user })

local _services = require"__tezpay.services"

for service in pairs(_services.get_installed_services()) do
	-- skip false values
	if type(service) ~= "string" then goto CONTINUE end
	local _ok, _error = _systemctl.safe_start_service(service)
	ami_assert(_ok, "Failed to start " .. service .. ".service " .. (_error or ""))
	::CONTINUE::
end

log_success("tezpay services succesfully started.")