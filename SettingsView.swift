import SwiftUI
import AVFoundation

struct SettingsView: View {
    @ObservedObject var settings: Settings
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Voice Selection")) {
                    Picker("Select Voice", selection: $settings.selectedVoice) {
                        ForEach(availableVoices(), id: \.identifier) { voice in
                            Text(voice.name).tag(voice.identifier)
                        }
                    }
                }
                Section(header: Text("OpenAI API Token")) {
                    TextField("Enter your API token", text: $settings.openAIAPIToken)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Settings")
        }
    }
    
    private func availableVoices() -> [AVSpeechSynthesisVoice] {
        return AVSpeechSynthesisVoice.speechVoices().sorted(by: { $0.name < $1.name })
    }

}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(settings: Settings())
    }
}
