import SwiftUI

@main
struct KurzspielApp: App {
    @StateObject private var store = ClubStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
