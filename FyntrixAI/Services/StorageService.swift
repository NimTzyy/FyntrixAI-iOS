import Foundation

class StorageService {
    static let shared = StorageService()
    private let defaults = UserDefaults.standard
    
    private let kEndpoint = "api_endpoint"
    private let kApiKey = "api_key"
    private let kPrompt = "system_prompt"
    private let kModel = "model_name"
    private let kTemp = "temperature"
    private let kTokens = "max_tokens"
    private let kFirstLaunch = "first_launch"
    private let kConversations = "conversations"
    private let kCurrentConv = "current_conv"
    
    let defaultEndpoint = "https://api.deepseek.com/v1"
    let defaultModel = "deepseek-chat"
    let defaultPrompt = "You are Fyntrix AI, a helpful assistant. Be concise and useful."
    
    var endpoint: String {
        get { defaults.string(forKey: kEndpoint) ?? defaultEndpoint }
        set { defaults.set(newValue, forKey: kEndpoint) }
    }
    var apiKey: String {
        get { defaults.string(forKey: kApiKey) ?? "" }
        set { defaults.set(newValue, forKey: kApiKey) }
    }
    var systemPrompt: String {
        get { defaults.string(forKey: kPrompt) ?? defaultPrompt }
        set { defaults.set(newValue, forKey: kPrompt) }
    }
    var model: String {
        get { defaults.string(forKey: kModel) ?? defaultModel }
        set { defaults.set(newValue, forKey: kModel) }
    }
    var temperature: Double {
        get { defaults.double(forKey: kTemp) == 0 ? 0.7 : defaults.double(forKey: kTemp) }
        set { defaults.set(newValue, forKey: kTemp) }
    }
    var maxTokens: Int {
        get { defaults.integer(forKey: kTokens) == 0 ? 4096 : defaults.integer(forKey: kTokens) }
        set { defaults.set(newValue, forKey: kTokens) }
    }
    var isFirstLaunch: Bool {
        get { !defaults.bool(forKey: kFirstLaunch) }
        set { defaults.set(!newValue, forKey: kFirstLaunch) }
    }
    
    func loadConversations() -> [Conversation] {
        guard let data = defaults.data(forKey: kConversations),
              let convs = try? JSONDecoder().decode([Conversation].self, from: data) else { return [] }
        return convs.sorted { $0.updatedAt > $1.updatedAt }
    }
    
    func saveConversations(_ conversations: [Conversation]) {
        if let data = try? JSONEncoder().encode(conversations) {
            defaults.set(data, forKey: kConversations)
        }
    }
    
    func saveConversation(_ conversation: Conversation) {
        var convs = loadConversations()
        if let idx = convs.firstIndex(where: { $0.id == conversation.id }) {
            convs[idx] = conversation
        } else {
            convs.insert(conversation, at: 0)
        }
        saveConversations(convs)
    }
    
    func deleteConversation(_ id: String) {
        var convs = loadConversations()
        convs.removeAll { $0.id == id }
        saveConversations(convs)
    }
}
