import SwiftUI

struct ChatBubbleView: View {
    let message: ChatMessage; let isUser: Bool
    var onEdit: ((String) -> Void)? = nil
    @State private var copied = false
    @State private var editing = false
    @State private var editText = ""
    @State private var codeCopied = false
    
    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 60) }
            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(isUser ? "You" : "Fyntrix AI").font(.caption2).fontWeight(.semibold).foregroundColor(isUser ? .blue : .secondary).padding(.horizontal, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    if editing && isUser {
                        TextEditor(text: $editText).font(.body).foregroundColor(.white).frame(minHeight: 60).padding(8).background(Color(hex: "1A1A1A")).cornerRadius(8)
                        HStack { Spacer()
                            Button("Cancel") { editing = false }.font(.caption).foregroundColor(.secondary)
                            Button("Save & Resend") { onEdit?(editText.trimmingCharacters(in: .whitespaces)); editing = false }.font(.caption).foregroundColor(.blue)
                        }
                    } else {
                        RenderContent(message.content)
                        HStack {
                            Text(message.timestamp, style: .time).font(.caption2).foregroundColor(isUser ? .white.opacity(0.5) : .secondary)
                            Spacer()
                            if isUser && onEdit != nil {
                                Button(action: { editText = message.content; editing = true }) {
                                    Image(systemName: "pencil").font(.system(size: 12)).foregroundColor(.secondary)
                                }
                            }
                            Button(action: { UIPasteboard.general.string = message.content; copied = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { copied = false }
                            }) {
                                Image(systemName: copied ? "checkmark" : "doc.on.doc").font(.system(size: 12)).foregroundColor(copied ? .green : .secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16).padding(.vertical, 12)
                .background(isUser ? Color.blue : Color(hex: "1A1A1A"))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(isUser ? Color.clear : Color(hex: "2A2A2A"), lineWidth: 0.5))
                .cornerRadius(16)
            }
            if !isUser { Spacer(minLength: 60) }
        }
        .padding(.horizontal, 12).padding(.vertical, 6)
    }
    
    @ViewBuilder
    private func RenderContent(_ text: String) -> some View {
        if text.contains("```") {
            let parts = parseCodeBlocks(text)
            ForEach(Array(parts.enumerated()), id: \.offset) { _, part in
                switch part {
                case .code(let code): CodeBlockView(code: code)
                case .text(let t): Text(t).font(.body).foregroundColor(.white).textSelection(.enabled)
                }
            }
        } else {
            Text(text).font(.body).foregroundColor(.white).textSelection(.enabled)
        }
    }
    
    @ViewBuilder
    private func CodeBlockView(code: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("CODE").font(.caption2).foregroundColor(.secondary); Spacer()
                Button(action: { UIPasteboard.general.string = code; codeCopied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { codeCopied = false }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: codeCopied ? "checkmark" : "doc.on.doc").font(.system(size: 11))
                        Text(codeCopied ? "Copied" : "Copy code").font(.caption2)
                    }.foregroundColor(codeCopied ? .green : .secondary)
                }
            }
            Divider().background(Color(hex: "2A2A2A"))
            Text(code).font(.system(size: 12, design: .monospaced)).foregroundColor(.green)
        }.padding(12).background(Color(hex: "141414")).cornerRadius(8)
    }
    
    enum ContentPart { case text(String); case code(String) }
    func parseCodeBlocks(_ text: String) -> [ContentPart] {
        var parts: [ContentPart] = []; let lines = text.components(separatedBy: "\n"); var i = 0; var current = ""
        while i < lines.count {
            if lines[i].trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                if !current.isEmpty { parts.append(.text(current)); current = "" }
                i += 1; var code = ""
                while i < lines.count && !lines[i].trimmingCharacters(in: .whitespaces).hasPrefix("```") { code += (code.isEmpty ? "" : "\n") + lines[i]; i += 1 }
                i += 1; parts.append(.code(code))
            } else { current += (current.isEmpty ? "" : "\n") + lines[i]; i += 1 }
        }
        if !current.isEmpty { parts.append(.text(current)) }
        return parts
    }
}

extension Color {
    init(hex: String) { let s = Scanner(string: hex); var r: UInt64 = 0; s.scanHexInt64(&r)
        self.init(red: Double((r>>16)&0xFF)/255, green: Double((r>>8)&0xFF)/255, blue: Double(r&0xFF)/255) }
}
