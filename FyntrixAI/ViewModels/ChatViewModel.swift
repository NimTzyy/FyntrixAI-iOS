import SwiftUI
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var showWelcome = false
    @Published var conversations: [Conversation] = []
    @Published var currentConversationId: String?
    
    private let storage = StorageService.shared
    private let api = APIService.shared
    private var currentTask: Task<Void, Never>?
    
    init() {
        conversations = storage.loadConversations()
        showWelcome = storage.isFirstLaunch
        if let last = conversations.first {
            switchConversation(last.id)
        } else {
            newConversation()
        }
    }
    
    func newConversation() {
        let conv = Conversation(title: "New Chat", messages: [])
        currentConversationId = conv.id
        messages = []
        error = nil
        conversations.insert(conv, at: 0)
        saveCurrentConversation()
    }
    
    func switchConversation(_ id: String) {
        guard let conv = conversations.first(where: { $0.id == id }) else { return }
        currentConversationId = id
        messages = conv.messages
        error = nil
    }
    
    func deleteConversation(_ id: String) {
        conversations.removeAll { $0.id == id }
        storage.deleteConversation(id)
        if currentConversationId == id {
            if let first = conversations.first { switchConversation(first.id) }
            else { newConversation() }
        }
    }
    
    func sendMessage(_ content: String) {
        guard !content.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let userMsg = ChatMessage(role: "user", content: content.trimmingCharacters(in: .whitespaces))
        messages.append(userMsg)
        error = nil
        isLoading = true
        saveCurrentConversation()
        
        currentTask = Task {
            do {
                let response = try await api.sendMessage(
                    endpoint: storage.endpoint,
                    apiKey: storage.apiKey,
                    model: storage.model,
                    messages: messages,
                    systemPrompt: storage.systemPrompt,
                    temperature: storage.temperature,
                    maxTokens: storage.maxTokens
                )
                if !Task.isCancelled {
                    messages.append(ChatMessage(role: "assistant", content: response))
                    saveCurrentConversation()
                }
            } catch {
                if !Task.isCancelled {
                    self.error = error.localizedDescription
                }
            }
            if !Task.isCancelled { isLoading = false }
        }
    }
    
    func stopGeneration() {
        currentTask?.cancel()
        currentTask = nil
        isLoading = false
    }
    
    func regenerateLast() {
        guard let lastUser = messages.last(where: { $0.role == "user" }),
              let lastAI = messages.last, lastAI.role == "assistant" else { return }
        messages.removeLast()
        messages.removeAll { $0.id == lastUser.id }
        sendMessage(lastUser.content)
    }
    
    func retryLast() {
        guard let lastUser = messages.last(where: { $0.role == "user" }) else { return }
        if messages.last?.role == "assistant" { messages.removeLast() }
        messages.removeAll { $0.id == lastUser.id }
        sendMessage(lastUser.content)
    }
    
    func clearChat() {
        messages = []
        error = nil
        currentTask?.cancel()
        isLoading = false
        saveCurrentConversation()
    }
    
    func dismissWelcome() {
        showWelcome = false
        storage.isFirstLaunch = false
    }
    
    func saveSettings(endpoint: String, key: String, prompt: String, model: String, temp: Double, tokens: Int) {
        storage.endpoint = endpoint
        storage.apiKey = key
        storage.systemPrompt = prompt
        storage.model = model
        storage.temperature = temp
        storage.maxTokens = tokens
    }
    
    func shareChat() {
        let text = exportChat()
        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = windowScene.windows.first?.rootViewController {
            root.present(av, animated: true)
        }
    }
    
    func copyChat() {
        UIPasteboard.general.string = exportChat()
    }
    
    private func exportChat() -> String {
        var text = "Fyntrix AI - Chat Export\n\n"
        for msg in messages {
            text += "\(msg.role == "user" ? "You" : "Fyntrix AI"):\n\(msg.content)\n---\n"
        }
        return text
    }
    
    private func saveCurrentConversation() {
        guard let id = currentConversationId else { return }
        let title: String
        if let firstUser = messages.first(where: { $0.role == "user" }) {
            title = String(firstUser.content.prefix(40))
        } else {
            title = "New Chat"
        }
        if let idx = conversations.firstIndex(where: { $0.id == id }) {
            conversations[idx].title = title
            conversations[idx].messages = messages
            conversations[idx].updatedAt = Date()
        }
        storage.saveConversations(conversations)
    }
}
