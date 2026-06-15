import SwiftUI

struct MessageInputView: View {
    let onSend: (String) -> Void
    let enabled: Bool
    @State private var text = ""
    @FocusState private var focused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(alignment: .bottom, spacing: 8) {
                TextField("Message", text: $text, axis: .vertical)
                    .focused($focused)
                    .lineLimit(1...5)
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(Color(hex: "1A1A1A"))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "333333"), lineWidth: 1))
                    .foregroundColor(.white)
                    .font(.body)
                
                Button(action: {
                    guard !text.trimmingCharacters(in: .whitespaces).isEmpty, enabled else { return }
                    onSend(text.trimmingCharacters(in: .whitespaces))
                    text = ""
                    focused = false
                }) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(text.trimmingCharacters(in: .whitespaces).isEmpty || !enabled ? Color.blue.opacity(0.2) : Color.blue)
                        .cornerRadius(12)
                }
                .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty || !enabled)
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
        }
        .background(Color(hex: "0D0D0D"))
    }
}
