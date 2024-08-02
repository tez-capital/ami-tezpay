local _user = am.app.get("user", "root")
ami_assert(type(_user) == "string", "User not specified...", EXIT_INVALID_CONFIGURATION)

local _ok, _error = fs.safe_mkdirp("reports")
ami_assert(_ok, "Failed to create reports directory - " .. tostring(_error) .. "!")
local _ok, _uid = fs.safe_getuid(_user)
ami_assert(_ok, "Failed to get " .. _user .. "uid - " .. (_uid or ""))

local _ok, _systemctl = am.plugin.safe_get("systemctl")
ami_assert(_ok, "Failed to load systemctl plugin")
_systemctl = _systemctl.with_options({ container = _user })

--- enable linger if not root
if _user ~= "root" then
	local ok, result = proc.safe_exec("loginctl show-user ".. _user .. " --property=Linger=yes", { stdout = "pipe" })
	if not ok or result.exitcode ~= 0 or result.stdoutStream:read("a") == "" then
		log_info("Enabling linger for " .. _user .. "...")
		local ok, _, exitcode = os.execute("loginctl enable-linger ".. _user)
		assert(ok and exitcode == 0, "failed to enable linger for " .. _user .. " - " .. tostring(exitcode))
	end
end

local _services = require "__tezpay.services"
local servicesToInstall = _services.get_installed_services(true)
_services.remove_all_services() -- cleanup past install

for serviceId, serviceFile in pairs(servicesToInstall) do
	local _ok, _error = _systemctl.safe_install_service(serviceFile, serviceId)
	ami_assert(_ok, "Failed to install " .. serviceId .. ".service " .. (_error or ""))
end

local _ok, _error = fs.safe_mkdirp("samples")
ami_assert(_ok, "Failed to create samples directory - " .. tostring(_error) .. "!")

local _configurations = require"__tezpay.constants".configurations
-- download sample config
local _ok, _error = net.safe_download_file(_configurations.config, "samples/config.hjson",
	{ followRedirects = true })
if not _ok then log_warn("Failed to download sample config.hjson - " .. (_error or "")) end

-- download sample remote_signer config
local _ok, _error = net.safe_download_file(_configurations.remote_signer, "samples/remote_signer.hjson",
	{ followRedirects = true })
if not _ok then log_warn("Failed to download sample remote_signer.hjson - " .. (_error or "")) end

-- download sample payout_wallet_private.key
local _ok, _error = net.safe_download_file(_configurations.payout_wallet_private_key, "samples/payout_wallet_private.key",
        { followRedirects = true })
if not _ok then log_warn("Failed to download sample payout_wallet_private.key - " .. (_error or "")) end

log_info("Granting access to " .. _user .. "(" .. tostring(_uid) .. ")...")
local _ok, _error = fs.chown(os.cwd(), _uid, _uid, { recurse = true })
ami_assert(_ok, "Failed to chown reports - " .. (_error or ""))
