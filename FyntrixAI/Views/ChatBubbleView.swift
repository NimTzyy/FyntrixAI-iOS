import SwiftUI

struct ChatBubbleView: View {
    let message: ChatMessage
    let isUser: Bool
    @State private var copied = false
    
    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 60) }
            
            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(isUser ? "You" : "Fyntrix AI")
                    .font(.caption2).fontWeight(.semibold)
                    .foregroundColor(isUser ? .blue : .secondary)
                    .padding(.horizontal, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(message.content)
                        .font(.body)
                        .foregroundColor(.white)
                        .textSelection(.enabled)
                    
                    HStack {
                        Text(message.timestamp, style: .time)
                            .font(.caption2)
                            .foregroundColor(isUser ? .white.opacity(0.5) : .secondary)
                        
                        Spacer()
                        
                        if !isUser {
                            Button(action: {
                                UIPasteboard.general.string = message.content
                                copied = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { copied = false }
                            }) {
                                Image(systemName: copied ? "checkmark" : "doc.on.doc")
                                    .font(.system(size: 12))
                                    .foregroundColor(copied ? .green : .secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16).padding(.vertical, 12)
                .background(isUser ? Color.blue : Color(hex: "1A1A1A"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isUser ? Color.clear : Color(hex: "2A2A2A"), lineWidth: 0.5)
                )
                .cornerRadius(16)
            }
            
            if !isUser { Spacer(minLength: 60) }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }
}
