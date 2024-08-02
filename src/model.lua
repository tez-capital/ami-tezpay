local _platform
local _ok, _platformPlugin = am.plugin.safe_get("platform")
if _ok then _ok, _platform = _platformPlugin.get_platform() end

if not _ok then
	log_error("Cannot determine platform!")
	return
end

local _downlaodUrl = nil
local _sources = require"__tezpay/constants".sources

if _platform.OS == "unix" then
	_downlaodUrl = _sources["linux-x86_x64"]
	if _platform.SYSTEM_TYPE:match("[Aa]arch64") then
		_downlaodUrl = _sources["linux-arm64"]
	end
end

if _downlaodUrl == nil then
	log_error("Platform not supported!")
	return
end

am.app.set_model(
	{
		DOWNLOAD_URLS = {
			tezpay = am.app.get_configuration("SOURCE", _downlaodUrl),
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
