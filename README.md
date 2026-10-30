# Noctalia plugins

Personal [Noctalia](https://noctalia.dev) plugin source.

| Plugin | Description |
| --- | --- |
| [`toniogela/comma`](comma/README.md) | Launch GUI apps from nixpkgs via comma, without installing them |

## Install

Add this repository as a git plugin source and enable the plugin, either at
runtime:

```sh
noctalia msg plugins source add toniogela git https://github.com/TonioGela/noctalia-plugins
noctalia msg plugins enable toniogela/comma
```

or declaratively in `config.toml`:

```toml
[[plugins.source]]
enabled = true
kind = "git"
location = "https://github.com/TonioGela/noctalia-plugins"
name = "toniogela"

[plugins]
enabled = ["toniogela/comma"]
```

## Developing

Use a checkout as a `path` source; `.luau` edits hot-reload:

```sh
noctalia msg plugins source add dev path /path/to/this/checkout
noctalia plugins lint comma
```

Each plugin lives in a directory named after the part of its id after the `/`.
Git sources only see plugins listed in `catalog.toml`, so on every release bump
`version` in both `<plugin>/plugin.toml` and `catalog.toml`.
