import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.completionWithItemsHandler = { (_, _, _, _) in
            dismiss()
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}
