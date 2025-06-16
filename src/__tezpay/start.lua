local service_manager = require"__xtz.service-manager"
local services = require"__tezpay.services"

service_manager.start_services(services.get_active_names())

log_success("tezpay services succesfully started.")