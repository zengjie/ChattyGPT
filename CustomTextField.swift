import SwiftUI

struct InputBox: UIViewRepresentable {
    var onCommit: ((String) -> Void)?
    
    func makeUIView(context: Context) -> CustomTextView {
        let textView = CustomTextView()
        textView.delegate = context.coordinator
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.gray.cgColor
        textView.returnKeyType = .default
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        textView.onShiftReturnPressed = {
            textView.insertText("\n")
        }
        return textView
    }
    
    func updateUIView(_ uiView: CustomTextView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onCommit: onCommit)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var onCommit: ((String) -> Void)?
        
        init(onCommit: ((String) -> Void)?) {
            self.onCommit = onCommit
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text == "\n" {
                print("commit")
                textView.resignFirstResponder()
                if let textViewText = textView.text, !textViewText.isEmpty {
                    onCommit?(textViewText)
                    textView.text = ""
                }
                return false
            }
            return true
        }
    }

}
