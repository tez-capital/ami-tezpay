local app_id = am.app.get("id")
local continual_service_id = "continual"

local possible_residues = {
	[app_id .. "-tezpay"] = am.app.get_model("TEZPAY_SERVICE_FILE", "__tezpay/assets/tezpay.service")
}

local available_services = {
	[continual_service_id] = am.app.get_model("TEZPAY_SERVICE_FILE", "__tezpay/assets/continual.service")
}

local function get_active_services()
	local service_manager = require"__xtz.service-manager"
	return service_manager.get_installed_services(available_services)
end

local function get_active_names()
	return table.values(get_active_services())
end

--- cleanup names include everything including residues
---@type string[]
local cleanup_names = {}
cleanup_names = util.merge_arrays(cleanup_names, table.values(tezpay_services))
cleanup_names = util.merge_arrays(cleanup_names, table.values(possible_residues))

return {
	get_active_services = get_active_services,
	get_active_names = get_active_names,
	available_services = available_services,
	cleanup_names = cleanup_names
}

