import SwiftUI

struct ConversationListView: View {
    let conversations: [Conversation]
    let currentId: String?
    let onSelect: (String) -> Void
    let onDelete: (String) -> Void
    let onNew: () -> Void
    
    var body: some View {
        NavigationView {
            List {
                ForEach(conversations) { conv in
                    Button(action: { onSelect(conv.id) }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(conv.title)
                                .font(.body).fontWeight(.medium)
                                .foregroundColor(conv.id == currentId ? .blue : .white)
                                .lineLimit(1)
                            Text("\(conv.messages.count) messages")
                                .font(.caption).foregroundColor(.secondary)
                        }
                    }
                    .swipeActions { Button("Delete", role: .destructive) { onDelete(conv.id) } }
                }
            }
            .listStyle(.plain)
            .background(Color(hex: "0D0D0D"))
            .navigationTitle("Chats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: onNew) {
                        Image(systemName: "plus").foregroundColor(.blue)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
