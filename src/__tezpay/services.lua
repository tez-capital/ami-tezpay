local _appId = am.app.get("id")
local _tezpayServiceId = _appId .. "-tezpay"

local _possibleResidue = { }

local _tezpayServices = {
	[_tezpayServiceId] = am.app.get_model("TEZPAY_SERVICE_FILE", "__tezpay/assets/tezpay.service")
}

local _tezpayServiceNames = {}
for k, _ in pairs(_tezpayServices) do
        _tezpayServiceNames[k:sub((#_appId + 2))] = k
end

local _allNames = util.clone(_tezpayServiceNames)

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
	tezpayServiceId = _tezpayServiceId,
	tezpayServices = _tezpayServices,
	tezpayServiceNames = _tezpayServiceNames,
	allNames = _allNames,
	remove_all_services = _remove_all_services
}

