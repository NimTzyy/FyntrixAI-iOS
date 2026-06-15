import Foundation

class APIService {
    static let shared = APIService()
    
    func sendMessage(
        endpoint: String,
        apiKey: String,
        model: String,
        messages: [ChatMessage],
        systemPrompt: String,
        temperature: Double,
        maxTokens: Int
    ) async throws -> String {
        var url = endpoint.trimmingCharacters(in: .whitespaces)
        if !url.hasPrefix("http") { url = "https://\(url)" }
        if !url.hasSuffix("/") { url += "/" }
        url += "chat/completions"
        
        guard let requestURL = URL(string: url) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var apiMessages: [APIMessage] = []
        if !systemPrompt.isEmpty {
            apiMessages.append(APIMessage(role: "system", content: systemPrompt))
        }
        for msg in messages {
            apiMessages.append(APIMessage(role: msg.role, content: msg.content))
        }
        
        let body = ChatRequest(
            model: model,
            messages: apiMessages,
            temperature: temperature,
            maxTokens: maxTokens,
            stream: false
        )
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let auth = apiKey.hasPrefix("Bearer ") ? apiKey : "Bearer \(apiKey)"
        request.setValue(auth, forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(body)
        request.timeoutInterval = 120
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        if httpResponse.statusCode != 200 {
            let errorMsg = String(data: data, encoding: .utf8) ?? "HTTP \(httpResponse.statusCode)"
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
        
        let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
        guard let content = chatResponse.choices.first?.message.content else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No response"])
        }
        return content
    }
}
