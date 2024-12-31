local platform
local ok, platform_plugin = am.plugin.safe_get("platform")
if ok then ok, platform = platform_plugin.get_platform() end

if not ok then
	log_error("Cannot determine platform!")
	return
end

local download_url = nil
local sources = require"__tezpay/constants".sources

if platform.OS == "unix" then
	download_url = sources["linux-x86_x64"]
	if platform.SYSTEM_TYPE:match("[Aa]arch64") then
		download_url = sources["linux-arm64"]
	end
end

if download_url == nil then
	log_error("Platform not supported!")
	return
end

am.app.set_model(
	{
		DOWNLOAD_URLS = {
			tezpay = am.app.get_configuration("SOURCE", download_url),
		}
	},
	{ merge = true, overwrite = true }
)

am.app.set_model(
	{
		WANTED_BINARIES = { "tezpay" },
		SERVICE_CONFIGURATION = util.merge_tables(
            {
                TimeoutStopSec = 600,
            },
            type(am.app.get_configuration("SERVICE_CONFIGURATION")) == "table" and am.app.get_configuration("SERVICE_CONFIGURATION") or {},
            true
        )
	},
	{ merge = true, overwrite = true }
)
