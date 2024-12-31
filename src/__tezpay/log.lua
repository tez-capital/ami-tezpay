local options, _, args, _ = ...

local user = am.app.get("user", "root")

local args = table.map(args, function(v) return v.arg end)
local services = require("__tezpay.services")

local installed_services = services.get_installed_services()
local to_check = table.keys(installed_services)
if #args > 0 then
    to_check = {}
    for _, v in ipairs(args) do
        ami_assert(installed_services[v], "service '" .. v .. "' not installed or found", EXIT_APP_INTERNAL_ERROR)
        table.insert(to_check, v)
    end
end

local journalctl_args = { "journalctl" }
if user ~= "root" then
    table.insert(journalctl_args, "--user")
end
if options.follow then table.insert(journalctl_args, "-f") end
if options['end'] then table.insert(journalctl_args, "-e") end
for _, v in ipairs(to_check) do
    table.insert(journalctl_args, "-u")
    table.insert(journalctl_args, v)
end

os.execute(string.join(" ", table.unpack(journalctl_args)))