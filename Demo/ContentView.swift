import SwiftUI

struct ContentView: View {
    @State private var chats: [ChatThread] = ChatThread.samples
    @State private var showModels = false
    @State private var showSettings = false
    @State private var activeModel = ChatThread.defaultModel
    @State private var configured = APIClient.shared.isConfigured

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
                    Button {
                        chats.insert(.init(title: "New chat", model: activeModel, messages: [], updated: Date()), at: 0)
                    } label: {
                        Label("New chat", systemImage: "square.and.pencil")
                            .foregroundStyle(.cyan)
                    }
                    .listRowBackground(Color.white.opacity(0.05))
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
                ToolbarItem(placement: .topBarLeading) {
                    Button { showSettings = true } label: {
                        Image(systemName: configured ? "gearshape.fill" : "gearshape")
                            .foregroundStyle(configured ? Color.cyan : Color.white.opacity(0.6))
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showModels = true } label: {
                        HStack(spacing: 4) {
                            Circle().fill(Color.cyan).frame(width: 7, height: 7)
                            Text(activeModel.split(separator: "/").last.map(String.init) ?? activeModel)
                                .font(.caption).bold().lineLimit(1)
                        }
                        .foregroundStyle(.white)
                    }
                }
            }
            .sheet(isPresented: $showModels) {
                ModelPicker(selected: $activeModel)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .onAppear { configured = APIClient.shared.isConfigured }
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
                    .font(.caption2).bold().lineLimit(1)
                    .padding(.horizontal, 7).padding(.vertical, 3)
                    .background(Color.cyan.opacity(0.18))
                    .foregroundStyle(Color.cyan)
                    .clipShape(Capsule())
                Text(chat.messages.last?.text ?? "empty")
                    .font(.caption).foregroundStyle(.white.opacity(0.45)).lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ModelPicker: View {
    @Binding var selected: String
    @Environment(\.dismiss) private var dismiss
    @State private var models: [String] = []
    @State private var loading = false
    @State private var error: String?
    @State private var filter = ""

    var filtered: [String] {
        filter.isEmpty ? models : models.filter { $0.localizedCaseInsensitiveContains(filter) }
    }

    var body: some View {
        NavigationStack {
            List {
                if let error { Text(error).font(.caption).foregroundStyle(.orange) }
                ForEach(filtered, id: \.self) { id in
                    Button {
                        selected = id
                        dismiss()
                    } label: {
                        HStack {
                            Text(id).font(.system(size: 14)).foregroundStyle(.white)
                            Spacer()
                            if selected == id { Image(systemName: "checkmark.circle.fill").foregroundStyle(.cyan) }
                        }
                    }
                }
            }
            .searchable(text: $filter)
            .overlay { if loading { ProgressView().tint(.cyan) } }
            .navigationTitle("\(models.count) models")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() }.foregroundStyle(.cyan) }
            }
            .task { await load() }
        }
        .preferredColorScheme(.dark)
    }

    private func load() async {
        guard APIClient.shared.isConfigured else { error = "API key belum diisi (Settings)"; return }
        loading = true
        defer { loading = false }
        do { models = try await APIClient.shared.models() }
        catch { self.error = error.localizedDescription }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var base = APIClient.shared.baseURL
    @State private var key = APIClient.shared.apiKey
    @State private var probe: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Endpoint (OpenAI-compatible)") {
                    TextField("http://host:port", text: $base)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                Section("API key") {
                    SecureField("Bearer token", text: $key)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    Text("Disimpan lokal di device ini, tidak dikirim ke mana pun selain endpoint di atas.")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Section {
                    Button("Test koneksi") {
                        Task {
                            APIClient.shared.baseURL = base
                            APIClient.shared.apiKey = key
                            do {
                                let m = try await APIClient.shared.models()
                                probe = "OK - \(m.count) model"
                            } catch { probe = "GAGAL - \(error.localizedDescription)" }
                        }
                    }
                    if !probe.isEmpty {
                        Text(probe).font(.caption)
                            .foregroundStyle(probe.hasPrefix("OK") ? .green : .orange)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        APIClient.shared.baseURL = base
                        APIClient.shared.apiKey = key
                        dismiss()
                    }.foregroundStyle(.cyan)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
