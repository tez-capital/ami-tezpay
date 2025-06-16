local service_manager = require"__xtz.service-manager"
local services = require"__xtz.services"

log_info("stopping tezpay services... this may take few minutes.")

service_manager.stop_services(services.get_active_names())

log_success("tezpay services succesfully stopped.")