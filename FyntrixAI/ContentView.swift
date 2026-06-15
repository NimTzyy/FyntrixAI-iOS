import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ChatViewModel
    @State private var showSettings = false
    @State private var showConversations = false
    @State private var showShare = false
    
    var body: some View {
        ZStack {
            if showSettings {
                SettingsView(onBack: { showSettings = false })
            } else {
                ChatView(
                    showSettings: { showSettings = true },
                    showConversations: $showConversations,
                    showShare: $showShare
                )
            }
        }
        .sheet(isPresented: $viewModel.showWelcome) {
            WelcomeView(onDismiss: { viewModel.dismissWelcome() })
        }
        .sheet(isPresented: $showConversations) {
            ConversationListView(
                conversations: viewModel.conversations,
                currentId: viewModel.currentConversationId,
                onSelect: { viewModel.switchConversation($0); showConversations = false },
                onDelete: { viewModel.deleteConversation($0) },
                onNew: { viewModel.newConversation(); showConversations = false }
            )
        }
        .confirmationDialog("Share Chat", isPresented: $showShare) {
            Button("Share as Text") { viewModel.shareChat() }
            Button("Copy to Clipboard") { viewModel.copyChat() }
            Button("Cancel", role: .cancel) {}
        }
    }
}
