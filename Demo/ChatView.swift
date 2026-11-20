import SwiftUI

struct ChatView: View {
    @Binding var chat: ChatThread
    @State private var draft: String = ""
    @State private var thinking = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(chat.messages) { m in
                            MessageBubble(message: m).id(m.id)
                        }
                        if thinking {
                            HStack(spacing: 8) {
                                ProgressView().tint(.cyan)
                                Text("thinking...")
                                    .font(.caption).foregroundStyle(.white.opacity(0.5))
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .id("thinking")
                        }
                    }
                    .padding(.vertical, 14)
                }
                .onChange(of: chat.messages.count) { _, _ in
                    withAnimation { proxy.scrollTo(chat.messages.last?.id, anchor: .bottom) }
                }
            }

            HStack(spacing: 10) {
                TextField("Message", text: $draft, axis: .vertical)
                    .lineLimit(1...4)
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .foregroundStyle(.white)

                Button(action: send) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .bold))
                        .frame(width: 40, height: 40)
                        .background(draft.isEmpty || thinking ? Color.white.opacity(0.12) : Color.cyan)
                        .foregroundStyle(draft.isEmpty || thinking ? Color.white.opacity(0.4) : Color.black)
                        .clipShape(Circle())
                }
                .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty || thinking)
            }
            .padding(12)
            .background(.ultraThinMaterial)
        }
        .background(
            LinearGradient(colors: [Color(red: 0.04, green: 0.05, blue: 0.09),
                                    Color(red: 0.09, green: 0.04, blue: 0.14)],
                           startPoint: .top, endPoint: .bottom).ignoresSafeArea()
        )
        .navigationTitle(chat.model)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func send() {
        let text = draft.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        chat.messages.append(.init(text: text, isUser: true))
        chat.updated = Date()
        if chat.title == "New chat" { chat.title = String(text.prefix(28)) }
        draft = ""
        thinking = true

        Task {
            let api = APIClient.shared
            if !api.isConfigured {
                try? await Task.sleep(nanoseconds: 400_000_000)
                chat.messages.append(.init(text: "API key kosong. Buka Settings (ikon gear) dan tempel key ZevAI.", isUser: false, failed: true))
            } else {
                do {
                    let reply = try await api.chat(model: chat.model, history: chat.messages)
                    chat.messages.append(.init(text: reply, isUser: false))
                } catch {
                    chat.messages.append(.init(text: error.localizedDescription, isUser: false, failed: true))
                }
            }
            thinking = false
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser { Spacer(minLength: 40) }
            Text(message.text)
                .font(.system(size: 15))
                .foregroundStyle(message.isUser ? Color.black : (message.failed ? Color.orange : Color.white))
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(message.isUser ? Color.cyan : Color.white.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            if !message.isUser { Spacer(minLength: 40) }
        }
        .padding(.horizontal, 12)
    }
}
