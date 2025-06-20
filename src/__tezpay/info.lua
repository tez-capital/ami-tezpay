local needs_json_output = am.options.OUTPUT_FORMAT == "json"

local info = {
	level = "ok",
	status = "tezpay is operational",
	version = am.app.get_version(),
	type = am.app.get_type(),
	services = {}
}

local service_manager = require "__xtz.service-manager"
local services = require "__tezpay.services"
local statuses, all_running = service_manager.get_services_status(services.get_active_names())
info.services = statuses
if not all_running then
	info.status = "one or more tezpay services is not running"
	info.level = "error"
end

if needs_json_output then
	print(hjson.stringify_to_json(info, { indent = false }))
else
	print(hjson.stringify(info, { sortKeys = true }))
end
