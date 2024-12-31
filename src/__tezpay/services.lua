local app_id = am.app.get("id")
local continual_service_id = app_id .. "-continual"

local possible_residues = {
	[app_id .. "-tezpay"] = am.app.get_model("TEZPAY_SERVICE_FILE", "__tezpay/assets/tezpay.service")
}

local continual_services = {
	[continual_service_id] = am.app.get_model("TEZPAY_SERVICE_FILE", "__tezpay/assets/continual.service")
}

local tezpay_services = continual_services

local function get_installed_services(check_old_continual_residues)
	local ok, systemctl = am.plugin.safe_get("systemctl")
	ami_assert(ok, "Failed to load systemctl plugin")

	local user = am.app.get("user", "root")
	systemctl = systemctl.with_options({ container = user })

	local installed_services = {}

	for service_id, source_file in pairs(tezpay_services) do
		if systemctl.is_service_installed(service_id) then
			installed_services[service_id] = source_file
		end
	end

	-- // TODO: remove this after a few releases
	if check_old_continual_residues and systemctl.is_service_installed(app_id .. "-tezpay") and not installed_services[continual_service_id] then
		installed_services[continual_service_id] = tezpay_services[continual_service_id]
	end
	-- end TODO

	return installed_services
end

-- includes potential residues
local function remove_all_services()
	local services = table.values(tezpay_services)
	services = util.merge_tables(services, possible_residues)

	local ok, systemctl = am.plugin.safe_get("systemctl")
	ami_assert(ok, "Failed to load systemctl plugin")

	local user = am.app.get("user", "root")
	local systemctl_user = systemctl.with_options({ container = user })

	for service  in pairs(services) do
		if type(service) ~= "string" then goto CONTINUE end

		local ok, err = systemctl.safe_remove_service(service) -- remove system wide
		if not ok then
			ami_error("Failed to remove " .. service .. ".service " .. (err or ""))
		end

		local ok, err = systemctl_user.safe_remove_service(service)
		if not ok then
			ami_error("Failed to remove " .. service .. ".service " .. (err or ""))
		end
		::CONTINUE::
	end
end

return {
	continual_services = continual_services,
	remove_all_services = remove_all_services,
	get_installed_services = get_installed_services
}

