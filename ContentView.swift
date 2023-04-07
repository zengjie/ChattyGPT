import SwiftUI
import OpenAI
import AVFoundation

struct ContentView: View {
    @EnvironmentObject private var openAIService: OpenAIService;
    @State private var messages: [ChatMessage] = []
    @State private var userInput: String = ""
    @State private var synthesizer = AVSpeechSynthesizer()
    @ObservedObject var settings = Settings()
    @State private var showSettingsView = false
    @FocusState private var isInputFocused: Bool

    let hiddenMessages: [Chat] = [
        Chat(role: "system", content: "You are an English coach with a sense of humor. You will correct grammatical or idiomatic errors during the conversation. You are going to play yourself as a young girl in her 20s. The conversation should be coherent, funny and friendly."),
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollViewReader { scrollView in
                    ScrollView { 
                        VStack(spacing:20) {
                            ForEach(messages) { message in
                                ChatBubble(message: message, onSpeak: {speak(message.text)})
                                    .id(message.id)
                            }
                        }
                        .onChange(of:messages) { _ in
                            withAnimation {
                                scrollView.scrollTo(messages.last?.id)
                            }
                        }
                    }
                }
                .padding()
                
                HStack {
                    InputBox(onCommit: { text in
                        userInput = text
                        sendMessage()
                    })
                    .frame(height: userInputHeight(userInput))
                    .padding(.horizontal)
                    .focused($isInputFocused)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(.horizontal)
                    }
                    
                    Button(action: regenerateResponse) {
                        Image(systemName: "arrow.clockwise")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(.trailing)
                    }
                }
                .padding()
            }
            .navigationViewStyle(.stack)
            .navigationBarItems(trailing: Button(action: {
                showSettingsView = true
            }) {
                Image(systemName: "gearshape")
            })
            .sheet(isPresented: $showSettingsView) {
                SettingsView(settings: Settings())
            }
        }
    }
    
    private func prepareMessagesForAPI() -> [Chat] {
        var apiMessages: [Chat] = hiddenMessages
        
        for message in messages {
            let role = message.isUser ? "user" : "assistant"
            let content = message.text
            let apiMessage = Chat(role: role, content: content)
            apiMessages.append(apiMessage)
        }
        
        return apiMessages
    }
    
    private func sendResponse(with history: [Chat]) {
        let pendingMessage = ChatMessage(text: "", isUser: false, isLoading: true)
        messages.append(pendingMessage)
        
        let query = ChatQuery(model: .gpt3_5Turbo, messages: history)
        Task {
            do {
                let result = try await openAIService.openAI.chats(query: query)
                if let response = result.choices.first?.message.content {
                    let botMessage = ChatMessage(text: response.trimmingCharacters(in: .whitespacesAndNewlines), isUser: false)
                    DispatchQueue.main.async {
                        messages.removeLast() // Remove the pending message with loading animation
                        messages.append(botMessage)
                    }
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func sendMessage() {
        guard !userInput.isEmpty else { return }
        
        let userMessage = ChatMessage(text: userInput, isUser: true)
        messages.append(userMessage)
        userInput = ""
        
        let messageHistory = prepareMessagesForAPI()
        sendResponse(with: messageHistory)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isInputFocused = true
        }
    }
    
    func regenerateResponse() {
        guard let lastUserMessageIndex = messages.lastIndex(where: { $0.isUser }) else { return }
        
        // Remove the last bot message
        if lastUserMessageIndex + 1 < messages.count {
            messages.remove(at: lastUserMessageIndex + 1)
        }
        
        let messageHistory = prepareMessagesForAPI()
        sendResponse(with: messageHistory)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isInputFocused = true
        }
    }
    
    private func userInputHeight(_ text: String) -> CGFloat {
        let minHeight: CGFloat = 40
        let maxHeight: CGFloat = 100
        
        let textWidth = UIScreen.main.bounds.width - 88
        let constraintRect = CGSize(width: textWidth, height: .greatestFiniteMagnitude)
        
        let boundingBox = text.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: UIFont.systemFont(ofSize: 17)], context: nil)
        
        let calculatedHeight = boundingBox.height + 16
        
        return min(max(minHeight, calculatedHeight), maxHeight)
    }

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(identifier: settings.selectedVoice)
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        synthesizer.speak(utterance)
    }
}

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isUser: Bool
    var isLoading: Bool = false
}

struct ChatBubble: View {
    @State private var showShareSheet = false
    
    let message: ChatMessage
    var onSpeak: (() -> Void)?
    
    var body: some View {
        HStack(alignment: .bottom) {
            if message.isLoading {
                LoadingDotsView()
                    .frame(width: 50, height: 25)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(15)
            } else {
                if message.isUser {
                    Spacer()
                }
                Text(message.text)
                    .padding(10)
                    .background(message.isUser ? Color.blue : Color.gray.opacity(0.15))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(15)
                if !message.isUser {
                    Spacer()
                }
            }
        }
        .contextMenu {
            Button(action: {
                UIPasteboard.general.string = message.text
            }) {
                Label("Copy", systemImage: "doc.on.doc")
            }
            
            Button(action: {
                onSpeak?()
            }) {
                Label("Speak", systemImage: "speaker.wave.3")
            }
            
            Button(action: {
                showShareSheet = true
            }) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [message.text])
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
