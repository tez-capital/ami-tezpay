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

local startup_args = am.app.get_configuration("STARTUP_ARGS", {})

local continual_configuration = am.app.get_configuration("CONTINUAL", nil)
if type(continual_configuration) == "table" then
	local payout_interval = continual_configuration.interval or 1
	if type(payout_interval) == "number" and payout_interval > 1 then
		table.insert(startup_args, "--interval=" .. tostring(payout_interval))
	end
	local payout_interval_trigger_offset = continual_configuration.interval_trigger_offset or 0
	if type(payout_interval_trigger_offset) == "number" and payout_interval_trigger_offset > 0 then
		table.insert(startup_args, "--interval-trigger-offset=" .. tostring(payout_interval_trigger_offset))
	end
	local payout_include_previous_cycles = continual_configuration.include_previous_cycles or 0
	if type(payout_include_previous_cycles) == "number" and payout_include_previous_cycles > 0 then
		table.insert(startup_args, "--include-previous-cycles=" .. tostring(payout_include_previous_cycles))
	end
end

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
		),
		STARTUP_ARGS = startup_args,
	},
	{ merge = true, overwrite = true }
)
