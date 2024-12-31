local options = ...

local enable = options.enable
local disable = options.disable
local status = options.status

local selected_options = { enable, disable, status }
local options_count = table.reduce(selected_options, function(acc, v) return acc + (v and 1 or 0) end, 0)
ami_assert(options_count == 1, "Exactly one of --enable, --disable, --status must be provided", EXIT_APP_INTERNAL_ERROR)

local continual_services = require("__tezpay.services").continual_services

local ok, systemctl = am.plugin.safe_get("systemctl")
ami_assert(ok, "Failed to load systemctl plugin")

local user = am.app.get("user", "root")
systemctl = systemctl.with_options({ container = user })

if enable then
	local all_installed = table.reduce(continual_services,
		function(acc, _, k) return acc and systemctl.is_service_installed(k) end, true)

	if not all_installed then
		for service_id, service_file in pairs(continual_services) do
			local ok, error = systemctl.safe_install_service(service_file, service_id)
			ami_assert(ok, "Failed to install " .. service_id .. ".service " .. (error or ""))
		end
	end

	log_info("Continual service enabled. To start the service, run `ami start`")
end

if disable then
	local any_installed = table.reduce(continual_services,
		function(acc, _, k) return acc or systemctl.is_service_installed(k) end, false)

	if any_installed then
		for service_id, _ in pairs(continual_services) do
			local ok, err = systemctl.safe_remove_service(service_id)
			ami_assert(ok, "Failed to remove " .. service_id .. ".service " .. (err or ""))
		end

		log_info("Continual service disabled.")
	end
end

if status then
	local all_installed = table.reduce(continual_services,
		function(acc, _, k) return acc and systemctl.is_service_installed(k) end, true)
	if all_installed then
		print("enabled")
	else
		print("disabled")
	end
end
