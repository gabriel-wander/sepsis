import SwiftUI

@main
struct SepseAppApp: App {
    @StateObject private var store = DataStore()

    var body: some Scene {
        WindowGroup {
            PatientListView()
                .environmentObject(store)
        }
    }
}
