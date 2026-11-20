import Foundation

struct ChatMessage: Identifiable, Hashable {
    let id = UUID()
    var text: String
    var isUser: Bool
    var date: Date = Date()
}

struct ModelInfo: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var vendor: String
    var thirsty: Bool
}

struct ChatThread: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var model: String
    var messages: [ChatMessage]
    var updated: Date

    static let sampleModels: [ModelInfo] = [
        .init(name: "Opus 5.5", vendor: "Thirsty Models", thirsty: true),
        .init(name: "Sonnet 5", vendor: "Thirsty Models", thirsty: true),
        .init(name: "GPT-5.2", vendor: "Open model", thirsty: false),
        .init(name: "Qwen 4 Coder", vendor: "Open model", thirsty: false)
    ]

    static let samples: [ChatThread] = [
        .init(title: "Fix slow Xcode build",
              model: "Opus 5.5",
              messages: [
                .init(text: "Why does my CI build take 7 minutes?", isUser: true),
                .init(text: "Most of it is dependency setup. Cache DerivedData and pin the Xcode version, then it drops to about 2 minutes.", isUser: false)
              ],
              updated: Date()),
        .init(title: "SwiftUI chat bubble",
              model: "Sonnet 5",
              messages: [.init(text: "Bikin bubble chat SwiftUI yang bisa auto-scroll", isUser: true)],
              updated: Date().addingTimeInterval(-3600)),
        .init(title: "Signing without dev account",
              model: "GPT-5.2",
              messages: [.init(text: "Can I install an unsigned ipa?", isUser: true)],
              updated: Date().addingTimeInterval(-86400))
    ]
}
