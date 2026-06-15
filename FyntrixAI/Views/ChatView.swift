import SwiftUI

struct ChatView: View {
    @EnvironmentObject var viewModel: ChatViewModel
    var showSettings: () -> Void
    @Binding var showConversations: Bool
    @Binding var showShare: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { showConversations = true }) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("Fyntrix AI").font(.headline).fontWeight(.semibold)
                Spacer()
                HStack(spacing: 4) {
                    Button(action: { showShare = true }) {
                        Image(systemName: "square.and.arrow.up").font(.system(size: 16)).foregroundColor(.secondary)
                    }
                    Button(action: { viewModel.newConversation() }) {
                        Image(systemName: "plus").font(.system(size: 18)).foregroundColor(.secondary)
                    }
                    Button(action: { viewModel.clearChat() }) {
                        Image(systemName: "trash").font(.system(size: 16)).foregroundColor(.secondary)
                    }
                    Button(action: showSettings) {
                        Image(systemName: "gearshape").font(.system(size: 18)).foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemBackground))
            
            Divider()
            
            // Error
            if let error = viewModel.error {
                HStack {
                    Text(error).font(.caption).foregroundColor(.red)
                    Spacer()
                    Button("Retry") { viewModel.retryLast() }.font(.caption).foregroundColor(.blue)
                    Button("Dismiss") { viewModel.error = nil }.font(.caption).foregroundColor(.secondary)
                }
                .padding(.horizontal, 16).padding(.vertical, 8)
                .background(Color.red.opacity(0.1))
            }
            
            // Messages
            if viewModel.messages.isEmpty && !viewModel.isLoading {
                EmptyStateView()
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.messages) { msg in
                                ChatBubbleView(message: msg, isUser: msg.role == "user", onEdit: msg.role == "user" ? { newText in viewModel.editMessage(msg.id, newText: newText) } : nil)
                            }
                            if viewModel.isLoading {
                                HStack {
                                    ProgressView().scaleEffect(0.7)
                                    Text("Thinking…").font(.caption).foregroundColor(.secondary)
                                    Spacer()
                                    Button("Stop") { viewModel.stopGeneration() }
                                        .font(.caption).foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 24).padding(.vertical, 12)
                            }
                        }
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let last = viewModel.messages.last {
                            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                }
            }
            
            // Regenerate
            if !viewModel.isLoading && !viewModel.messages.isEmpty {
                HStack { Spacer()
                    Button(action: { viewModel.regenerateLast() }) {
                        Label("Regenerate", systemImage: "arrow.clockwise").font(.caption).foregroundColor(.blue)
                    }
                }.padding(.horizontal, 16).padding(.vertical, 2)
            }
            
            // Input
            MessageInputView(onSend: { viewModel.sendMessage($0) }, enabled: !viewModel.isLoading)
        }
        .background(Color(hex: "0D0D0D"))
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 8) {
            Spacer()
            Text("Fyntrix AI").font(.title).fontWeight(.bold)
            Text("How can I help you today?").foregroundColor(.secondary)
            Spacer().frame(height: 24)
            VStack(spacing: 12) {
                HintRow(emoji: "💬", text: "Send a message to start chatting")
                HintRow(emoji: "⚙️", text: "Configure your API in Settings")
                HintRow(emoji: "📂", text: "View past conversations in History")
            }
            .padding(20).background(Color(hex: "141414")).cornerRadius(12).padding(.horizontal, 32)
            Spacer().frame(height: 24)
            Text("Fyntrix").font(.caption).foregroundColor(.secondary)
            Spacer()
        }
    }
}

struct HintRow: View {
    let emoji: String; let text: String
    var body: some View { HStack(spacing: 10) { Text(emoji); Text(text).font(.caption).foregroundColor(.secondary); Spacer() } }
}

// Color hex helper
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(red: Double((rgb >> 16) & 0xFF)/255, green: Double((rgb >> 8) & 0xFF)/255, blue: Double(rgb & 0xFF)/255)
    }
}
