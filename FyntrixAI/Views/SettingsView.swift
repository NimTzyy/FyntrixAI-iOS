import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: ChatViewModel
    let onBack: () -> Void
    let storage = StorageService.shared
    
    @State private var endpoint = ""
    @State private var apiKey = ""
    @State private var prompt = ""
    @State private var model = ""
    @State private var temperature = ""
    @State private var maxTokens = ""
    @State private var showKey = false
    @State private var saved = false
    @State private var showImport = false
    @State private var importText = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("API Configuration") {
                    TextField("Endpoint URL", text: $endpoint)
                    HStack {
                        if showKey {
                            TextField("API Key", text: $apiKey)
                        } else {
                            SecureField("API Key", text: $apiKey)
                        }
                        Button(action: { showKey.toggle() }) {
                            Image(systemName: showKey ? "eye.slash" : "eye").foregroundColor(.secondary)
                        }
                    }
                    Text("Stored locally on your device").font(.caption2).foregroundColor(.secondary)
                    TextField("Model", text: $model)
                }
                
                Section("System Prompt") {
                    TextEditor(text: $prompt).frame(minHeight: 80).font(.body)
                    Text("Defines the AI behavior").font(.caption2).foregroundColor(.secondary)
                }
                
                Section("Parameters") {
                    TextField("Temperature", text: $temperature).keyboardType(.decimalPad)
                    TextField("Max Tokens", text: $maxTokens).keyboardType(.numberPad)
                }
                
                Section {
                    Button(action: {
                        viewModel.saveSettings(
                            endpoint: endpoint, key: apiKey, prompt: prompt, model: model,
                            temp: Double(temperature) ?? 0.7, tokens: Int(maxTokens) ?? 4096
                        )
                        saved = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { saved = false }
                    }) {
                        HStack { Spacer(); Text(saved ? "Saved" : "Save Configuration").fontWeight(.semibold); Spacer() }
                    }
                }
                
                Section("Import / Export") {
                    Button(action: {
                        let cfg = "{\"endpoint\":\"\(endpoint)\",\"key\":\"\(apiKey)\",\"prompt\":\"\(prompt.replacingOccurrences(of: "\"", with: "\\\""))\",\"model\":\"\(model)\",\"temperature\":\"\(temperature)\",\"tokens\":\"\(maxTokens)\"}"
                        UIPasteboard.general.string = cfg
                    }) { Label("Export Config", systemImage: "doc.on.doc") }
                    
                    Button(action: { showImport = true }) {
                        Label("Import Config", systemImage: "square.and.arrow.down")
                    }
                }
                
                Section("About") {
                    HStack { Text("Version").foregroundColor(.secondary); Spacer(); Text("1.0.0") }
                    HStack { Text("Channel").foregroundColor(.secondary); Spacer(); Text("@fyntr1x").foregroundColor(.blue) }
                    HStack { Text("Admin").foregroundColor(.secondary); Spacer(); Text("@dumpassnigger").foregroundColor(.blue) }
                }
                
                Section {} footer: {
                    Text("Fyntrix").font(.caption).foregroundColor(.secondary).frame(maxWidth: .infinity)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(hex: "0D0D0D"))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: onBack) { Image(systemName: "chevron.left").foregroundColor(.white) }
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            endpoint = storage.endpoint; apiKey = storage.apiKey; prompt = storage.systemPrompt
            model = storage.model; temperature = String(storage.temperature); maxTokens = String(storage.maxTokens)
        }
        .alert("Import Config", isPresented: $showImport) {
            TextField("Paste JSON...", text: $importText)
            Button("Import") {
                if let data = importText.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    endpoint = json["endpoint"] as? String ?? endpoint
                    apiKey = json["key"] as? String ?? apiKey
                    prompt = json["prompt"] as? String ?? prompt
                    model = json["model"] as? String ?? model
                    temperature = json["temperature"] as? String ?? temperature
                    maxTokens = json["tokens"] as? String ?? maxTokens
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}
