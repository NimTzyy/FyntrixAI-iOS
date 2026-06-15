# Fyntrix AI - iOS

**Bundle:** com.fyntrix.ai  
**Version:** 1.0.0  
**Platform:** iOS 16+  
**Swift:** 5.9 / SwiftUI

## Features
- Chat with any OpenAI-compatible API (DeepSeek, GPT, Claude)
- Custom system prompt
- Copy AI responses with one tap
- Conversation history (save, switch, delete)
- Regenerate & stop generation
- Share/export chats
- Import/export config
- Clean dark DeepSeek-style UI

## Build
1. Open this folder in Xcode 15+
2. Select target: FyntrixAI
3. Build & Run (Cmd+R)

## Contacts
- Channel: @fyntr1x
- Admin: @dumpassnigger

## Architecture
```
FyntrixAI/
├── App.swift, ContentView.swift, Info.plist
├── Models/ChatModels.swift
├── Services/APIService.swift, StorageService.swift
├── ViewModels/ChatViewModel.swift
└── Views/
    ├── ChatView.swift, ChatBubbleView.swift
    ├── MessageInputView.swift, SettingsView.swift
    ├── WelcomeView.swift, ConversationListView.swift
```
