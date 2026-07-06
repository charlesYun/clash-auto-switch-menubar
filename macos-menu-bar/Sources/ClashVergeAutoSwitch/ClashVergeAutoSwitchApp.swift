import SwiftUI

@main
struct ClashVergeAutoSwitchApp: App {
    @StateObject private var model = SwitchModel()

    var body: some Scene {
        MenuBarExtra("Clash Auto Switch", systemImage: model.statusIcon) {
            ContentView()
                .environmentObject(model)
        }
        .menuBarExtraStyle(.window)
    }
}
