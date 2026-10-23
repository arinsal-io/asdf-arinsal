# asdf-arinsal

The Arinsal asdf plugin installs the self-contained Arinsal runtime and its bundled Erlang/OTP 29.1.1 libraries.

## Install

```sh
asdf plugin add arinsal https://github.com/arinsal-io/asdf-arinsal.git
asdf install arinsal latest
```

Use Arinsal as the Erlang runtime in `.tool-versions`. The `erl`, `erlc`, and `escript` commands are supplied by the Arinsal installation, so asdf-elixir can use it from `PATH`:

```text
arinsal 0.1.0
elixir 1.20.4-otp-29
```

## Supported platforms

- Apple silicon macOS: `aarch64-apple-darwin`
- ARM64 Linux with GNU libc: `aarch64-unknown-linux-gnu`

x86-64 and Windows are not supported.

## Private repository access

While the Arinsal release and plugin repositories are private, set `GITHUB_API_TOKEN` or `GITHUB_TOKEN` to a GitHub token with read access to both `arinsal-io/arinsal` and `arinsal-io/asdf-arinsal`. The token is used for GitHub's releases API and private release assets. Once both repositories are public, no token is needed.
