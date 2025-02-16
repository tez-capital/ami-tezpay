return {
    protected_files = {
        "config.hjson",
        "remote_signer.hjson",
        "payout_wallet_private.key",
        "reports/"
    },
    configurations = {
        config = "https://raw.githubusercontent.com/tez-capital/tezpay/main/docs/configuration/config.default.hjson",
        ["remote_signer"] = "https://raw.githubusercontent.com/tez-capital/tezpay/main/docs/configuration/remote_signer.sample.hjson",
        ["payout_wallet_private_key"] = "https://raw.githubusercontent.com/tez-capital/tezpay/main/docs/configuration/payout_wallet_private.sample.key"
    },
    sources = {
        ["linux-x86_x64"] = "https://github.com/tez-capital/tezpay/releases/download/0.20.1-beta/tezpay-linux-amd64",
        ["linux-arm64"] = "https://github.com/tez-capital/tezpay/releases/download/0.20.1-beta/tezpay-linux-arm64"
    }
}
