# SwiftUI 菜单栏版

这是 Clash Auto Switch Menubar 的 macOS 原生菜单栏入口。它会调用 App 内置的 `scripts/switch_fastest.py`，对当前 Clash Verge Rev / Mihomo 链路里的 selector 组测速，并切换到最快可用节点。

底层脚本基于 [tankeito/clash-verge-auto-switch](https://github.com/tankeito/clash-verge-auto-switch)。本目录提供 SwiftUI 菜单栏封装、图标、构建脚本和 Release 打包脚本。

## 功能

- Dry Run 测速，不切换节点
- 一键切换当前链路 selector 组到最快节点
- 定时自动测速并切换最快节点
- Controller 离线时自动尝试打开 Clash Verge Rev
- 日志窗口实时显示候选节点测速、最快节点和切换结果

## 安装下载版

从 GitHub Release 下载 zip：

```text
https://github.com/charlesYun/clash-auto-switch-menubar/releases/latest
```

解压后得到：

```text
Clash Verge Auto Switch.app
```

可以直接运行，也可以拖到 `/Applications`。

当前 App 未做 Apple Developer ID 签名和公证。首次打开如果 macOS 提示无法验证开发者，请在 Finder 里右键 App，选择“打开”。

## 构建

```bash
cd macos-menu-bar
./scripts/build_app.sh
```

构建结果：

```text
build/Clash Verge Auto Switch.app
```

构建脚本会生成并写入 `AppIcon.icns`，Finder、启动项和系统权限提示中会显示 App 图标。

## 打包 Release

```bash
./scripts/package_release.sh
```

打包结果：

```text
build/release/Clash-Verge-Auto-Switch-macOS-arm64.zip
```

该 zip 可上传到 GitHub Release，作为用户下载入口。

## 使用

直接打开构建出的 app。它是菜单栏应用，不会显示 Dock 图标。

首次使用建议顺序：

1. 点击“测速”，只检查最快节点，不切换。
2. 确认输出正常后，再点击“立即切换”。
3. 需要长期使用时，打开“自动切换最快节点”，设置间隔分钟。

## 注意

- “切换”会实际修改 Clash/Mihomo selector 组，可能影响系统代理和 Codex 网络。
- 自动切换固定使用当前链路，相当于 `--group-scope current --launch-if-needed`。
- 自动切换只在菜单栏 App 运行时生效；退出 App 后不会继续执行。
- 菜单栏 app 会调用内置的 `switch_fastest.py` 副本；如果修改了主脚本，需要重新运行 `./scripts/build_app.sh`。
- 当前版本要求 macOS 13 或更高版本。
- 当前 release 包面向 Apple Silicon Mac。
