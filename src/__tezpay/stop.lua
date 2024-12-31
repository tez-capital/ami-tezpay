local ok, systemctl = am.plugin.safe_get("systemctl")
ami_assert(ok, "Failed to load systemctl plugin")

local user = am.app.get("user", "root")
systemctl = systemctl.with_options({ container = user })

local services = require"__tezpay.services"

log_info("Stopping tezpay services... this may take few minutes.")
for service in pairs(services.get_installed_services()) do
	-- skip false values
	if type(service) ~= "string" then goto CONTINUE end
	local ok, err = systemctl.safe_stop_service(service)
	ami_assert(ok, "Failed to stop " .. service .. ".service " .. (err or ""))
	::CONTINUE::
end
log_success("tezpay services succesfully stopped.")