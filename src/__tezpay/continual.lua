local _, command = ...

local services = require("__tezpay.services")
local service_manager = require "__xtz.service-manager"

local actions = {
	enable = function()
		local installed_services = services.get_active_names()

		if not next(installed_services) then
			service_manager.install_services(services.available_services)
		end

		log_info("continual service enabled, to start the service, run `ami start`")
	end,
	disable = function()
		local installed_services = services.get_active_names()

		if next(installed_services) then
			service_manager.stop_services(installed_services)
			service_manager.remove_services(services.installed_services)
		end
		log_info("continual service disabled")
	end,
	status = function()
		local installed_services = services.get_active_names()
		if next(installed_services) then
			print("enabled")
		else
			print("disabled")
		end
	end
}

local action_id = command.id
local action = actions[action_id]
ami_assert(action, "unknown command: " .. action_id)
action()