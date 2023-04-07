import SwiftUI
import OpenAI

class OpenAIService: ObservableObject {
    @ObservedObject var settings: Settings
    
    init(settings: Settings) {
        self.settings = settings
    }
    
    public var openAI: OpenAI {
        OpenAI(apiToken: settings.openAIAPIToken)
    }
    
    // ... rest of the OpenAIService code ...
}
