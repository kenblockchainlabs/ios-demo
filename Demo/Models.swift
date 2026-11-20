import Foundation

struct ChatMessage: Identifiable, Hashable {
    let id = UUID()
    var text: String
    var isUser: Bool
    var date: Date = Date()
    var failed: Bool = false
}

struct ChatThread: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var model: String
    var messages: [ChatMessage]
    var updated: Date

    static let defaultModel = "cb-cn/glm-5.2"

    static let samples: [ChatThread] = [
        .init(title: "Test koneksi ZevAI",
              model: defaultModel,
              messages: [
                .init(text: "Halo, lo model apa?", isUser: true),
                .init(text: "Isi API key di Settings dulu, lalu kirim pesan - reply-nya datang dari router ZevAI langsung.", isUser: false)
              ],
              updated: Date()),
        .init(title: "Ide app",
              model: "nous/upstage/solar-mini4:free",
              messages: [.init(text: "Bikin rencana fitur chat client", isUser: true)],
              updated: Date().addingTimeInterval(-3600))
    ]
}
