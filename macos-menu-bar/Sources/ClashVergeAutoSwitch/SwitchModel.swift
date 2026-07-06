import AppKit
import Foundation

@MainActor
final class SwitchModel: ObservableObject {
    @Published var statusText = "未检测"
    @Published var lastOutput = "点击“测速”检查当前链路最快节点。"
    @Published var isRunning = false
    @Published var autoSwitchEnabled = false {
        didSet {
            if autoSwitchEnabled {
                scheduleNextAutoSwitch()
            } else {
                stopAutoSwitch()
            }
        }
    }
    @Published var intervalMinutes = 30 {
        didSet {
            if intervalMinutes < 1 {
                intervalMinutes = 1
            }
            if autoSwitchEnabled {
                scheduleNextAutoSwitch()
            }
        }
    }
    @Published var nextRunText = "未开启"
    @Published var lastAutoRunText = "尚未自动执行"

    var statusIcon: String {
        if isRunning {
            return "arrow.triangle.2.circlepath"
        }
        if statusText.contains("可用") || statusText.contains("完成") {
            return "bolt.horizontal.circle"
        }
        if statusText.contains("失败") || statusText.contains("不可用") {
            return "exclamationmark.triangle"
        }
        return "bolt.horizontal"
    }

    private let projectRoot: URL
    private let scriptPath: URL
    private var autoSwitchTimer: Timer?

    init() {
        let executable = Bundle.main.executableURL ?? URL(fileURLWithPath: CommandLine.arguments[0])
        let bundleRoot = executable
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()

        let bundledScript = bundleRoot.appendingPathComponent("Resources/scripts/switch_fastest.py")
        if FileManager.default.fileExists(atPath: bundledScript.path) {
            self.projectRoot = bundleRoot.appendingPathComponent("Resources")
            self.scriptPath = bundledScript
            return
        }

        let sourceRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        self.projectRoot = sourceRoot
        self.scriptPath = sourceRoot.appendingPathComponent("scripts/switch_fastest.py")
    }

    func refreshStatus() {
        runScript(label: "刷新状态", arguments: ["--list-groups"])
    }

    func dryRun() {
        runScript(label: "测速", arguments: scriptArguments(extra: ["--dry-run"]))
    }

    func switchFastest() {
        runScript(label: "切换最快节点", arguments: scriptArguments(extra: []))
    }

    func quit() {
        NSApplication.shared.terminate(nil)
    }

    private func scriptArguments(extra: [String]) -> [String] {
        var arguments = extra
        arguments.append(contentsOf: ["--group-scope", "current", "--launch-if-needed"])
        return arguments
    }

    private func scheduleNextAutoSwitch() {
        autoSwitchTimer?.invalidate()

        let seconds = TimeInterval(max(intervalMinutes, 1) * 60)
        let nextRun = Date().addingTimeInterval(seconds)
        nextRunText = Self.timeFormatter.string(from: nextRun)

        autoSwitchTimer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.runAutoSwitch()
            }
        }
    }

    private func stopAutoSwitch() {
        autoSwitchTimer?.invalidate()
        autoSwitchTimer = nil
        nextRunText = "未开启"
    }

    private func runAutoSwitch() {
        guard autoSwitchEnabled else {
            return
        }

        if isRunning {
            lastAutoRunText = "上次跳过：任务运行中"
            scheduleNextAutoSwitch()
            return
        }

        lastAutoRunText = "正在自动切换"
        runScript(label: "自动切换", arguments: scriptArguments(extra: [])) { [weak self] result in
            guard let self else { return }
            self.lastAutoRunText = result.exitCode == 0
                ? "上次成功：\(Self.timeFormatter.string(from: Date()))"
                : "上次失败：\(Self.timeFormatter.string(from: Date()))"
            if self.autoSwitchEnabled {
                self.scheduleNextAutoSwitch()
            }
        }
    }

    private func runScript(label: String, arguments: [String]) {
        runScript(label: label, arguments: arguments, completion: nil)
    }

    private func runScript(
        label: String,
        arguments: [String],
        completion: ((CommandResult) -> Void)?
    ) {
        guard FileManager.default.fileExists(atPath: scriptPath.path) else {
            statusText = "脚本不存在"
            lastOutput = scriptPath.path
            return
        }

        Task {
            isRunning = true
            statusText = "\(label)中"
            lastOutput = "[\(Self.timeFormatter.string(from: Date()))] \(label)中...\n"
            let result = await CommandRunner.run(
                "/usr/bin/python3",
                arguments: [scriptPath.path] + arguments,
                workingDirectory: projectRoot,
                onOutput: { [weak self] text in
                    Task { @MainActor in
                        self?.appendLog(text)
                    }
                }
            )
            isRunning = false
            statusText = result.exitCode == 0 ? "\(label)完成" : "\(label)失败：\(result.exitCode)"
            appendLog(
                "\n[\(Self.timeFormatter.string(from: Date()))] "
                + (result.exitCode == 0 ? "\(label)完成" : "\(label)失败：\(result.exitCode)")
            )
            if result.output.isEmpty {
                appendLog("\n无脚本输出。")
            }
            completion?(result)
        }
    }

    private func appendLog(_ text: String) {
        if lastOutput.isEmpty {
            lastOutput = text
        } else {
            lastOutput += text
        }
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}
