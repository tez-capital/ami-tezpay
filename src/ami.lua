return {
    title = 'tezpay',
    commands = {
        info = {
            description = "ami 'info' sub command",
            summary = 'Prints runtime info and status of the app',
            action = '__tezpay/info.lua',
            contextFailExitCode = EXIT_APP_INFO_ERROR
        },
        setup = {
            options = {
                configure = {
                    description = 'Configures application, renders templates and installs services'
                }
            },
            action = function(_options, _, _, _)
                local _noOptions = #table.keys(_options) == 0
                if _noOptions or _options.environment then
                    am.app.prepare()
                end

                if _noOptions or not _options['no-validate'] then
                    am.execute('validate', {'--platform'})
                end

                if _noOptions or _options.app then
                    am.execute_extension('__xtz/download-binaries.lua', {contextFailExitCode = EXIT_SETUP_ERROR})
                end

                if _noOptions and not _options['no-validate'] then
                    am.execute('validate', {'--configuration'})
                end

                if _noOptions or _options.configure then
					am.execute_extension('__xtz/create_user.lua', {contextFailExitCode = EXIT_APP_CONFIGURE_ERROR})
                    am.app.render()
                    am.execute_extension('__tezpay/configure.lua', {contextFailExitCode = EXIT_APP_CONFIGURE_ERROR})
                end
                log_success('tezpay setup complete.')
            end
        },
        start = {
            description = "ami 'start' sub command",
            summary = 'Starts the tezpay services',
            action = '__tezpay/start.lua',
            contextFailExitCode = EXIT_APP_START_ERROR
        },
        stop = {
            description = "ami 'stop' sub command",
            summary = 'Stops the tezpay services',
            action = '__tezpay/stop.lua',
            contextFailExitCode = EXIT_APP_STOP_ERROR
        },
        validate = {
            description = "ami 'validate' sub command",
            summary = 'Validates app configuration and platform support',
            action = function(_options, _, _, _cli)
                if _options.help then
                    am.print_help(_cli)
                    return
                end
                log_success('tezpay app configuration validated.')
            end
        },
        log = {
            description = "ami 'log' sub command",
            summary = 'Prints logs from services.',
            options = {
                ["follow"] = {
                    aliases = {"f"},
                    description = "Keeps printing the log continuously.",
                    type = "boolean"
                },
                ["end"] = {
                    aliases = {"e"},
                    description = "Jumps to the end of the log.",
                    type = "boolean"
                }
            },
            type = "no-command",
            action = '__tezpay/log.lua',
            contextFailExitCode = EXIT_APP_INTERNAL_ERROR
        },
        tezpay = {
            description = "tezpay direct passthrough",
            summary = 'Passes any passed arguments directly to tezpay.',
            index = 8,
            type = 'external',
            exec = 'bin/tezpay',
            environment = {
                HOME = os.cwd()
            },
            contextFailExitCode = EXIT_APP_INTERNAL_ERROR
        },
        pay = {
            description = "tezpay 'pay' passthrough",
            summary = 'Passes any passed arguments directly to tezpay pay.',
            index = 9,
            type = 'external',
            exec = 'bin/tezpay',
            environment = {
                HOME = os.cwd()
            },
            injectArgs = { "pay" },
            contextFailExitCode = EXIT_APP_INTERNAL_ERROR
        },
        ["generate-payouts"] = {
            description = "tezpay 'generate-payouts' passthrough",
            summary = 'Passes any passed arguments directly to tezpay.',
            index = 10,
            type = 'external',
            exec = 'bin/tezpay',
            environment = {
                HOME = os.cwd()
            },
            injectArgs = { "generate-payouts" },
            contextFailExitCode = EXIT_APP_INTERNAL_ERROR
        },
        about = {
            description = "ami 'about' sub command",
            summary = 'Prints information about application',
            action = function(_options, _, _, _)
                local _ok, _aboutFile = fs.safe_read_file('__tezpay/about.hjson')
                ami_assert(_ok, 'Failed to read about file!', EXIT_APP_ABOUT_ERROR)

                local _ok, _about = hjson.safe_parse(_aboutFile)
                _about['App Type'] = am.app.get({'type', 'id'}, am.app.get('type'))
                ami_assert(_ok, 'Failed to parse about file!', EXIT_APP_ABOUT_ERROR)
                if am.options.OUTPUT_FORMAT == 'json' then
                    print(hjson.stringify_to_json(_about, {indent = false, skipkeys = true}))
                else
                    print(hjson.stringify(_about))
                end
            end
        },
        remove = {
            index = 7,
            -- // TODO: remove just reports ??
            action = function(_options, _, _, _)
                if _options.all then
                    am.execute_extension('__tezpay/remove-all.lua', {contextFailExitCode = EXIT_RM_ERROR})
                    am.app.remove(require"__tezpay/constants".protectedFiles)
                    log_success('Application removed.')
                else
                    log_warn"only whole tezpay ami instance can be remoced and requires --all parameter"
                end
                return
            end
        }
    }
}
