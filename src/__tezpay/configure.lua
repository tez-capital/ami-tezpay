local user = am.app.get("user", "root")
ami_assert(type(user) == "string", "User not specified...", EXIT_INVALID_CONFIGURATION)

local ok, err = fs.safe_mkdirp("reports")
ami_assert(ok, "Failed to create reports directory - " .. tostring(err) .. "!")
local ok, uid = fs.safe_getuid(user)
ami_assert(ok, "Failed to get " .. user .. "uid - " .. (uid or ""))

local ok, systemctl = am.plugin.safe_get("systemctl")
ami_assert(ok, "Failed to load systemctl plugin")
systemctl = systemctl.with_options({ container = user })

--- enable linger if not root
if user ~= "root" then
	local ok, result = proc.safe_exec("loginctl show-user ".. user .. " --property=Linger=yes", { stdout = "pipe" })
	local stdout = result.stdout_stream:read("a") or ""
	if not ok or result.exit_code ~= 0 or stdout == ""  then
		log_info("Enabling linger for " .. user .. "...")
		local ok, _, exit_code = os.execute("loginctl enable-linger ".. user)
		assert(ok and exit_code == 0, "failed to enable linger for " .. user .. " - " .. tostring(exit_code))
	end
end

local services = require "__tezpay.services"
local services_to_install = services.get_installed_services(true)
services.remove_all_services() -- cleanup past install

for service_id, service_file in pairs(services_to_install) do
	local ok, err = systemctl.safe_install_service(service_file, service_id)
	ami_assert(ok, "Failed to install " .. service_id .. ".service " .. (err or ""))
end

local ok, err = fs.safe_mkdirp("samples")
ami_assert(ok, "Failed to create samples directory - " .. tostring(err) .. "!")

local constants = require"__tezpay/constants"
local configurations = constants.configurations
-- download sample config
local ok, err = net.safe_download_file(configurations.config, "samples/config.hjson",
	{ follow_redirects = true })
if not ok then log_warn("Failed to download sample config.hjson - " .. (err or "")) end

-- download sample remote_signer config
local ok, err = net.safe_download_file(configurations.remote_signer, "samples/remote_signer.hjson",
	{ follow_redirects = true })
if not ok then log_warn("Failed to download sample remote_signer.hjson - " .. (err or "")) end

-- download sample payout_wallet_private.key
local ok, err = net.safe_download_file(configurations.payout_wallet_private_key, "samples/payout_wallet_private.key",
        { follow_redirects = true })
if not ok then log_warn("Failed to download sample payout_wallet_private.key - " .. (err or "")) end

log_info("Granting access to " .. user .. "(" .. tostring(uid) .. ")...")
local ok, err = fs.chown(os.cwd() or ".", uid, uid, { recurse = true })
ami_assert(ok, "Failed to chown reports - " .. (err or ""))
