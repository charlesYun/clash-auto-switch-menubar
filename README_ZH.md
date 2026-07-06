**中文** | [English](README.md)

# Clash Auto Switch Menubar

macOS 菜单栏工具，用来对 Clash Verge Rev / Mihomo 当前链路里的 selector 组测速，并一键切换到延迟最低的可用节点。

本仓库主要提供 macOS 菜单栏封装、构建脚本和下载包发布。底层自动测速与切换脚本基于 [tankeito/clash-verge-auto-switch](https://github.com/tankeito/clash-verge-auto-switch)。

## 下载

直接下载当前版本：

[下载 Clash Verge Auto Switch.app](https://github.com/charlesYun/clash-auto-switch-menubar/raw/main/downloads/Clash-Verge-Auto-Switch-macOS-arm64.zip)

下载后解压 `Clash-Verge-Auto-Switch-macOS-arm64.zip`，把 `Clash Verge Auto Switch.app` 拖到 `Applications` 或直接双击运行。

> 当前下载包未做 Apple Developer ID 签名和公证。如果 macOS 提示无法验证开发者，请在 Finder 中右键点击 App，选择“打开”。

## 系统要求

- macOS 13 或更高版本
- Apple Silicon Mac，包含 M1 / M2 / M3 / M4
- 已安装并运行 Clash Verge Rev 或兼容 Mihomo 控制器的客户端
- Clash 外部控制器可访问
- 系统可用 `/usr/bin/python3` 和 `curl`

## Clash 配置要求

工具会自动读取常见 Clash 配置里的控制器地址：

```yaml
external-controller: 127.0.0.1:9097
secret: ""
```

也支持 Unix socket：

```yaml
external-controller-unix: /path/to/socket
```

默认检查路径：

```text
~/Library/Application Support/io.github.clash-verge-rev.clash-verge-rev/config.yaml
~/.config/clash/config.yaml
```

如果 Clash Verge 没有运行，菜单栏 App 会尝试自动打开 Clash Verge Rev，然后重试连接控制器。

## 使用方式

打开 App 后，它会出现在 macOS 顶部菜单栏，不显示 Dock 图标。

- “测速”：只测试当前链路 selector 组的候选节点，不切换。
- “立即切换”：测试后把当前链路 selector 组切换到最快可用节点。
- “自动切换最快节点”：按设置的间隔分钟自动执行切换。
- 日志区域会显示每个候选节点的延迟、超时和最终选择结果。

建议首次使用先点“测速”，确认控制器和节点列表正常后，再点“立即切换”。

## 从源码构建

```bash
git clone https://github.com/charlesYun/clash-auto-switch-menubar.git
cd clash-auto-switch-menubar/macos-menu-bar
./scripts/build_app.sh
```

构建结果：

```text
macos-menu-bar/build/Clash Verge Auto Switch.app
```

打包 Release zip：

```bash
./scripts/package_release.sh
```

打包结果：

```text
macos-menu-bar/build/release/Clash-Verge-Auto-Switch-macOS-arm64.zip
```

## 命令行脚本

如果不想使用菜单栏 App，也可以直接运行底层脚本：

```bash
/usr/bin/python3 scripts/switch_fastest.py --group-scope current --launch-if-needed
```

只测速不切换：

```bash
/usr/bin/python3 scripts/switch_fastest.py --group-scope current --launch-if-needed --dry-run
```

列出自动发现的组：

```bash
/usr/bin/python3 scripts/switch_fastest.py --list-groups
```

## 定时任务脚本

项目仍保留 launchd 安装脚本，适合不打开菜单栏 App 时做后台定时切换：

```bash
scripts/install_launch_agent.sh --interval-minutes 30 --group-scope current --launch-if-needed
```

卸载：

```bash
scripts/uninstall_launch_agent.sh
```

菜单栏 App 自带的自动切换只在 App 运行时生效；launchd 任务则不依赖菜单栏 App。

## 来源和许可

- 底层脚本基于 [tankeito/clash-verge-auto-switch](https://github.com/tankeito/clash-verge-auto-switch)
- 本仓库增加 macOS SwiftUI 菜单栏 App、图标、构建和分发说明
- License: MIT
