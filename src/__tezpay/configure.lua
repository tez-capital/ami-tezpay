local _user = am.app.get("user", "root")
ami_assert(type(_user) == "string", "User not specified...", EXIT_INVALID_CONFIGURATION)

local _ok, _error = fs.safe_mkdirp("data")
ami_assert(_ok, "Failed to create data directory - " .. tostring(_error) .. "!")
local _ok, _uid = fs.safe_getuid(_user)
ami_assert(_ok, "Failed to get " .. _user .. "uid - " .. (_uid or ""))

local _ok, _systemctl = am.plugin.safe_get("systemctl")
ami_assert(_ok, "Failed to load systemctl plugin")

local _services = require "__tezpay.services"
_services.remove_all_services() -- cleanup past install

for serviceId, serviceFile in pairs(_services.tezpayServices) do
	local _ok, _error = _systemctl.safe_install_service(serviceFile, serviceId)
	ami_assert(_ok, "Failed to install " .. serviceId .. ".service " .. (_error or ""))
end

log_info("Granting access to " .. _user .. "(" .. tostring(_uid) .. ")...")
local _ok, _error = fs.chown(os.cwd(), _uid, _uid, { recurse = true })
ami_assert(_ok, "Failed to chown data - " .. (_error or ""))

-- download default config
local _downloadLinks = hjson.parse(fs.read_file("__xtz/sources.hjson"))

if not fs.exists("config.hjson") then
	local _ok, _error = net.safe_download_file(_downloadLinks.configurations.config, "config.hjson",
		{ followRedirects = true })
	ami_assert(_ok, "Failed to download default config - " .. (_error or ""))
end

-- download default remote_signer
if not fs.exists("remote_signer") then
	local _ok, _error = net.safe_download_file(_downloadLinks.configurations.remote_signer, "remote_signer",
		{ followRedirects = true })
	ami_assert(_ok, "Failed to download default remote_signer - " .. (_error or ""))
end