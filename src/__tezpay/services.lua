local _appId = am.app.get("id")
local _continualServiceId = _appId .. "-continual"

local _possibleResidue = {
	[_appId .. "-tezpay"] = am.app.get_model("TEZPAY_SERVICE_FILE", "__tezpay/assets/tezpay.service")
}

local continualServices = {
	[_continualServiceId] = am.app.get_model("TEZPAY_SERVICE_FILE", "__tezpay/assets/continual.service")
}

local _tezpayServices = continualServices

local _tezpayServiceNames = {}
for k, _ in pairs(_tezpayServices) do
        _tezpayServiceNames[k:sub((#_appId + 2))] = k
end

local function get_installed_services(checkOldContinuaResidueResidue)
	local _ok, _systemctl = am.plugin.safe_get("systemctl")
	ami_assert(_ok, "Failed to load systemctl plugin")

	local _user = am.app.get("user", "root")
	_systemctl = _systemctl.with_options({ container = _user })

	local installedServices = {}

	for serviceId, sourceFile in pairs(_tezpayServiceNames) do
		if _systemctl.is_service_installed(serviceId) then
			installedServices[serviceId] = sourceFile
		end
	end

	-- // TODO: remove this after a few releases
	if checkOldContinuaResidueResidue and _systemctl.is_service_installed(_appId .. "-tezpay") and not installedServices[_continualServiceId] then
		installedServices[_continualServiceId] = _tezpayServices[_continualServiceId]
	end
	-- end TODO

	return installedServices
end

-- includes potential residues
local function _remove_all_services()
	local _all = table.values(_tezpayServiceNames)
	_all = util.merge_arrays(_all, _possibleResidue)

	local _ok, _systemctl = am.plugin.safe_get("systemctl")
	ami_assert(_ok, "Failed to load systemctl plugin")

	local _user = am.app.get("user", "root")
	local _systemctlUser = _systemctl.with_options({ container = _user })

	for _, service in ipairs(_all) do
		if type(service) ~= "string" then goto CONTINUE end

		local _ok, _error = _systemctl.safe_remove_service(service) -- remove system wide
		if not _ok then
			ami_error("Failed to remove " .. service .. ".service " .. (_error or ""))
		end

		local _ok, _error = _systemctlUser.safe_remove_service(service)
		if not _ok then
			ami_error("Failed to remove " .. service .. ".service " .. (_error or ""))
		end
		::CONTINUE::
	end
end

return {
	continualServices = continualServices,
	remove_all_services = _remove_all_services,
	get_installed_services = get_installed_services
}

