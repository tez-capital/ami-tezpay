local _options, _, args, _ = ...

local user = am.app.get("user", "root")

local _args = table.map(args, function(v) return v.arg end)
local _services = require("__tezpay.services")

local installedServices = _services.get_installed_services()
local toCheck = table.keys(installedServices)
if #_args > 0 then
    toCheck = {}
    for _, v in ipairs(_args) do
        ami_assert(installedServices[v], "service '" .. v .. "' not installed or found", EXIT_APP_INTERNAL_ERROR)
        table.insert(toCheck, v)
    end
end

local _journalctlArgs = { "journalctl" }
if user ~= "root" then
    table.insert(_journalctlArgs, "--user")
end
if _options.follow then table.insert(_journalctlArgs, "-f") end
if _options['end'] then table.insert(_journalctlArgs, "-e") end
for _, v in ipairs(toCheck) do
    table.insert(_journalctlArgs, "-u")
    table.insert(_journalctlArgs, v)
end

os.execute(string.join(" ", table.unpack(_journalctlArgs)))