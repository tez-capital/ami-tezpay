local download_url = nil
local sources = require "__tezpay/constants".sources

local system_os = am.app.get_model("SYSTEM_OS", "unknown")
local system_distro = am.app.get_model("SYSTEM_DISTRO", "unknown")
local system_type = am.app.get_model("SYSTEM_TYPE", "unknown")

if system_os == "unix" then
	if system_distro == "MacOS" then
		download_url = sources["macos-arm64"]
	else
		download_url = sources["linux-x86_x64"]
		if system_type:match("[Aa]arch64") then
			download_url = sources["linux-arm64"]
		end
	end
end

ami_assert(download_url ~= nil,
	"no download URLs found for the current platform: " .. system_os .. " " .. system_distro .. " " .. system_type)

am.app.set_model(
	{
		DOWNLOAD_URLS = {
			tezpay = am.app.get_configuration("SOURCE", download_url),
		},
		WANTED_BINARIES = { "tezpay" },
		SERVICE_CONFIGURATION = util.merge_tables(
			{
				TimeoutStopSec = 600,
			},
			type(am.app.get_configuration("SERVICE_CONFIGURATION")) == "table" and
			am.app.get_configuration("SERVICE_CONFIGURATION") or {},
			true
		)
	},
	{ merge = true, overwrite = true }
)
