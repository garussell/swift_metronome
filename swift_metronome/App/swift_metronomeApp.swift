import SwiftUI
import SwiftData

@main
struct swift_metronomeApp: App {
    var sharedModelContainer: ModelContainer = {
        // Include both Item and Tempo in the schema
        let schema = Schema([
            Item.self,
            Tempo.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
