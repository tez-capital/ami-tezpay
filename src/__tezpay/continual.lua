local _options = ...

local enable = _options.enable
local disable = _options.disable
local status = _options.status

local selectedOptions = { enable, disable, status }
local optedInCount = table.reduce(selectedOptions, function(acc, v) return acc + (v and 1 or 0) end, 0)
ami_assert(optedInCount == 1, "Exactly one of --enable, --disable, --status must be provided", EXIT_APP_INTERNAL_ERROR)

local continualServices = require("__tezpay.services").continualServices

local _ok, _systemctl = am.plugin.safe_get("systemctl")
ami_assert(_ok, "Failed to load systemctl plugin")

local _user = am.app.get("user", "root")
_systemctl = _systemctl.with_options({ container = _user })

if enable then
	local allInstalled = table.reduce(continualServices,
		function(acc, _, k) return acc and _systemctl.is_service_installed(k) end, true)

	if allInstalled then
		for serviceId, serviceFile in pairs(continualServices) do
			local _ok, _error = _systemctl.safe_install_service(serviceFile, serviceId)
			ami_assert(_ok, "Failed to install " .. serviceId .. ".service " .. (_error or ""))
		end
	end

	log_info("Continual service enabled. To start the service, run `am start`")
end

if disable then
	local anyInstalled = table.reduce(continualServices,
		function(acc, _, k) return acc or _systemctl.is_service_installed(k) end, false)

	if anyInstalled then
		for serviceId, _ in pairs(continualServices) do
			local _ok, _error = _systemctl.safe_remove_service(serviceId)
			ami_assert(_ok, "Failed to remove " .. serviceId .. ".service " .. (_error or ""))
		end

		log_info("Continual service disabled.")
	end
end

if status then
	local allInstalled = table.reduce(continualServices,
		function(acc, _, k) return acc and _systemctl.is_service_installed(k) end, true)
	if allInstalled then
		print("enabled")
	else
		print("disabled")
	end
end
