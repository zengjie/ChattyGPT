import SwiftUI
import OpenAI

@main
struct MyApp: App {
    private let openAIService = OpenAIService(settings: Settings())
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(openAIService)
        }
    }
}
