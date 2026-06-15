import SwiftUI

struct WelcomeView: View {
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 20)
            
            Text("Fyntrix AI")
                .font(.largeTitle).fontWeight(.bold).foregroundColor(.white)
            
            Text("Your AI assistant")
                .font(.body).foregroundColor(.secondary)
            
            Spacer().frame(height: 12)
            
            // Channel link
            LinkCard(emoji: "📢", label: "Channel", handle: "@fyntr1x") {
                openTelegram("fyntr1x")
            }
            
            // Admin link
            LinkCard(emoji: "👤", label: "Admin", handle: "@dumpassnigger") {
                openTelegram("dumpassnigger")
            }
            
            Spacer().frame(height: 8)
            
            Divider().padding(.horizontal, 40)
            
            Text("Fyntrix")
                .font(.caption).foregroundColor(.secondary)
            
            Spacer().frame(height: 12)
            
            Button(action: onDismiss) {
                Text("Get Started")
                    .fontWeight(.semibold).frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.blue).foregroundColor(.white).cornerRadius(12)
            }
            .padding(.horizontal, 40)
            
            Spacer().frame(height: 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "1A1A1A"))
    }
    
    private func openTelegram(_ username: String) {
        if let url = URL(string: "https://t.me/\(username)") {
            UIApplication.shared.open(url)
        }
    }
}

struct LinkCard: View {
    let emoji: String; let label: String; let handle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(emoji).font(.title3)
                VStack(alignment: .leading) {
                    Text(label).font(.caption).foregroundColor(.secondary)
                    Text(handle).font(.body).fontWeight(.medium).foregroundColor(.blue)
                }
                Spacer()
                Text("→").foregroundColor(.secondary)
            }
            .padding(14)
            .background(Color(hex: "141414"))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "2A2A2A"), lineWidth: 0.5))
            .cornerRadius(12)
        }
        .padding(.horizontal, 40)
    }
}
