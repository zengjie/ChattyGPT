import AVFoundation

import SwiftUI

class Settings: ObservableObject {
    @AppStorage("SelectedVoice") var selectedVoice: String = AVSpeechSynthesisVoice(language: "en-US")?.identifier ?? ""
    @AppStorage("OpenAIAPIToken") var openAIAPIToken: String = ""
}
