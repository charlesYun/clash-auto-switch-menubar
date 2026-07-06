[中文](README.md) | **English**

# Clash Auto Switch Menubar

A macOS menu bar app that speed-tests the selector groups in your current Clash Verge Rev / Mihomo chain and switches them to the lowest-latency available node.

This repository focuses on the macOS menu bar wrapper, build scripts, and downloadable app packaging. The underlying auto-test and auto-switch script is based on [tankeito/clash-verge-auto-switch](https://github.com/tankeito/clash-verge-auto-switch).

## Download

Download the current build directly:

[Download Clash Verge Auto Switch.app](https://github.com/charlesYun/clash-auto-switch-menubar/raw/main/downloads/Clash-Verge-Auto-Switch-macOS-arm64.zip)

After downloading, unzip `Clash-Verge-Auto-Switch-macOS-arm64.zip` and move `Clash Verge Auto Switch.app` to `Applications`, or run it directly.

> The current build is not signed or notarized with an Apple Developer ID. If macOS says the developer cannot be verified, right-click the app in Finder and choose Open.

## Requirements

- macOS 13 or later
- Apple Silicon Mac: M1 / M2 / M3 / M4
- Clash Verge Rev or another Mihomo-compatible client installed and running
- Reachable Clash external controller
- `/usr/bin/python3` and `curl` available on the system

## Clash Configuration

The app discovers the controller from common Clash config files:

```yaml
external-controller: 127.0.0.1:9097
secret: ""
```

Unix socket controllers are also supported:

```yaml
external-controller-unix: /path/to/socket
```

Default lookup paths:

```text
~/Library/Application Support/io.github.clash-verge-rev.clash-verge-rev/config.yaml
~/.config/clash/config.yaml
```

If Clash Verge is not running, the menu bar app tries to launch Clash Verge Rev and reconnect to the controller.

## Usage

After launch, the app appears in the macOS menu bar and does not show a Dock icon.

- Test: measure candidate node latency without switching.
- Switch Now: test and switch current selector groups to the fastest available node.
- Auto Switch: run switching repeatedly at the selected minute interval.
- Logs: show latency, timeout, and selected winner details.

Run Test first, then use Switch Now after confirming that the controller and proxy list are detected correctly.

## Build From Source

```bash
git clone https://github.com/charlesYun/clash-auto-switch-menubar.git
cd clash-auto-switch-menubar/macos-menu-bar
./scripts/build_app.sh
```

Build output:

```text
macos-menu-bar/build/Clash Verge Auto Switch.app
```

Create a Release zip:

```bash
./scripts/package_release.sh
```

Package output:

```text
macos-menu-bar/build/release/Clash-Verge-Auto-Switch-macOS-arm64.zip
```

## Command Line Script

You can also run the underlying script directly:

```bash
/usr/bin/python3 scripts/switch_fastest.py --group-scope current --launch-if-needed
```

Dry run:

```bash
/usr/bin/python3 scripts/switch_fastest.py --group-scope current --launch-if-needed --dry-run
```

List discovered groups:

```bash
/usr/bin/python3 scripts/switch_fastest.py --list-groups
```

## launchd Scheduling

The repository still includes a launchd installer for background scheduling without the menu bar app:

```bash
scripts/install_launch_agent.sh --interval-minutes 30 --group-scope current --launch-if-needed
```

Uninstall:

```bash
scripts/uninstall_launch_agent.sh
```

The menu bar app auto-switcher runs only while the app is open. The launchd job runs independently.

## Credits and License

- Underlying script based on [tankeito/clash-verge-auto-switch](https://github.com/tankeito/clash-verge-auto-switch)
- This repository adds the macOS SwiftUI menu bar app, icon, build scripts, and distribution notes
- License: MIT
