import SwiftUI

struct ContentView: View {
    @State private var chats: [ChatThread] = ChatThread.samples
    @State private var showModels = false
    @State private var activeModel = "Opus 5.5"

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach($chats) { $chat in
                        NavigationLink {
                            ChatView(chat: $chat)
                        } label: {
                            ThreadRow(chat: chat)
                        }
                        .listRowBackground(Color.white.opacity(0.05))
                    }
                } header: {
                    Text("Recent").foregroundStyle(.white.opacity(0.4))
                }
            }
            .scrollContentBackground(.hidden)
            .background(
                LinearGradient(colors: [Color(red: 0.04, green: 0.05, blue: 0.09),
                                        Color(red: 0.08, green: 0.04, blue: 0.13)],
                               startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            )
            .navigationTitle("FreeMilk client")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showModels = true } label: {
                        HStack(spacing: 4) {
                            Circle().fill(Color.cyan).frame(width: 7, height: 7)
                            Text(activeModel).font(.caption).bold()
                        }
                        .foregroundStyle(.white)
                    }
                }
            }
            .sheet(isPresented: $showModels) {
                ModelPicker(selected: $activeModel)
            }
            .preferredColorScheme(.dark)
        }
    }
}

struct ThreadRow: View {
    let chat: ChatThread

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(chat.title).font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                Spacer()
                Text(chat.updated, style: .relative).font(.caption2).foregroundStyle(.white.opacity(0.35))
            }
            HStack(spacing: 6) {
                Text(chat.model)
                    .font(.caption2).bold()
                    .padding(.horizontal, 7).padding(.vertical, 3)
                    .background(Color.cyan.opacity(0.18))
                    .foregroundStyle(Color.cyan)
                    .clipShape(Capsule())
                Text(chat.messages.last?.text ?? "")
                    .font(.caption).foregroundStyle(.white.opacity(0.45)).lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ModelPicker: View {
    @Binding var selected: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Thirsty Models - daily free allowance") {
                    ForEach(ChatThread.sampleModels.filter { $0.thirsty }) { m in
                        row(m)
                    }
                }
                Section("Open models - always free") {
                    ForEach(ChatThread.sampleModels.filter { !$0.thirsty }) { m in
                        row(m)
                    }
                }
            }
            .navigationTitle("Pick model")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.foregroundStyle(.cyan)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func row(_ m: ModelInfo) -> some View {
        Button {
            selected = m.name
            dismiss()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(m.name).foregroundStyle(.white).font(.system(size: 15, weight: .semibold))
                    Text(m.vendor).font(.caption2).foregroundStyle(.white.opacity(0.4))
                }
                Spacer()
                if selected == m.name {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.cyan)
                }
            }
        }
    }
}
