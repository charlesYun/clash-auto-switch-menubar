import Foundation

struct CommandResult: Sendable {
    let exitCode: Int32
    let output: String
}

final class OutputCollector: @unchecked Sendable {
    private let lock = NSLock()
    private var value = ""

    func append(_ text: String) {
        lock.lock()
        value.append(text)
        lock.unlock()
    }

    func trimmedOutput() -> String {
        lock.lock()
        let output = value.trimmingCharacters(in: .whitespacesAndNewlines)
        lock.unlock()
        return output
    }
}

enum CommandRunner {
    static func run(_ executable: String, arguments: [String], workingDirectory: URL) async -> CommandResult {
        await run(executable, arguments: arguments, workingDirectory: workingDirectory, onOutput: nil)
    }

    static func run(
        _ executable: String,
        arguments: [String],
        workingDirectory: URL,
        onOutput: (@Sendable (String) -> Void)?
    ) async -> CommandResult {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let process = Process()
                let outputPipe = Pipe()
                let errorPipe = Pipe()
                let collectedOutput = OutputCollector()

                process.executableURL = URL(fileURLWithPath: executable)
                process.arguments = arguments
                process.currentDirectoryURL = workingDirectory
                process.standardOutput = outputPipe
                process.standardError = errorPipe

                let consume: @Sendable (FileHandle) -> Void = { handle in
                    let data = handle.availableData
                    guard !data.isEmpty else {
                        return
                    }
                    let text = String(data: data, encoding: .utf8) ?? ""
                    guard !text.isEmpty else {
                        return
                    }
                    collectedOutput.append(text)
                    onOutput?(text)
                }

                outputPipe.fileHandleForReading.readabilityHandler = consume
                errorPipe.fileHandleForReading.readabilityHandler = consume

                do {
                    try process.run()
                    process.waitUntilExit()
                } catch {
                    outputPipe.fileHandleForReading.readabilityHandler = nil
                    errorPipe.fileHandleForReading.readabilityHandler = nil
                    continuation.resume(
                        returning: CommandResult(
                            exitCode: 127,
                            output: "Failed to run \(executable): \(error.localizedDescription)"
                        )
                    )
                    return
                }

                outputPipe.fileHandleForReading.readabilityHandler = nil
                errorPipe.fileHandleForReading.readabilityHandler = nil
                consume(outputPipe.fileHandleForReading)
                consume(errorPipe.fileHandleForReading)

                let combined = collectedOutput.trimmedOutput()

                continuation.resume(
                    returning: CommandResult(exitCode: process.terminationStatus, output: combined)
                )
            }
        }
    }
}
