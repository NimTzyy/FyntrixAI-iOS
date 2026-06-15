import SwiftUI

@main
struct FyntrixAIApp: App {
    @StateObject private var viewModel = ChatViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .preferredColorScheme(.dark)
        }
    }
}
