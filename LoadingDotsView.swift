import SwiftUI

struct LoadingDotsView: View {
    @State private var currentIndex: Int = 0
    
    private let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()
    private let dotCount = 3
    
    var body: some View {
        HStack {
            ForEach(0..<3) { index in
                Circle()
                    .foregroundColor(currentIndex == index ? Color.primary : Color.gray)
                    .frame(width: 8, height: 8)
            }
        }
        .onReceive(timer) { _ in
            currentIndex = (currentIndex + 1) % 3
        }
    }
}
