import Foundation

enum APIError: LocalizedError {
    case badURL
    case http(Int, String)
    case empty

    var errorDescription: String? {
        switch self {
        case .badURL: return "base URL invalid"
        case let .http(code, body): return "HTTP \(code): \(body.prefix(120))"
        case .empty: return "empty response"
        }
    }
}

final class APIClient {
    static let shared = APIClient()

    var baseURL: String {
        get { UserDefaults.standard.string(forKey: "baseURL") ?? "http://89.144.42.210:1997" }
        set { UserDefaults.standard.set(newValue, forKey: "baseURL") }
    }

    var apiKey: String {
        get { UserDefaults.standard.string(forKey: "apiKey") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "apiKey") }
    }

    var isConfigured: Bool { !apiKey.isEmpty }

    private func req(_ path: String, method: String = "GET") throws -> URLRequest {
        let base = baseURL.hasSuffix("/") ? String(baseURL.dropLast()) : baseURL
        guard let url = URL(string: base + path) else { throw APIError.badURL }
        var r = URLRequest(url: url)
        r.httpMethod = method
        r.timeoutInterval = 90
        r.setValue("application/json", forHTTPHeaderField: "Content-Type")
        r.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        return r
    }

    func models() async throws -> [String] {
        let (data, resp) = try await URLSession.shared.data(for: try req("/v1/models"))
        guard let http = resp as? HTTPURLResponse else { throw APIError.empty }
        guard http.statusCode == 200 else {
            throw APIError.http(http.statusCode, String(data: data, encoding: .utf8) ?? "")
        }
        struct List: Decodable { struct M: Decodable { let id: String }; let data: [M] }
        let list = try JSONDecoder().decode(List.self, from: data)
        return list.data.map(\.id).sorted()
    }

    func chat(model: String, history: [ChatMessage]) async throws -> String {
        struct Msg: Encodable { let role: String; let content: String }
        struct Body: Encodable { let model: String; let messages: [Msg]; let stream: Bool }
        let msgs = history.map { Msg(role: $0.isUser ? "user" : "assistant", content: $0.text) }
        var r = try req("/v1/chat/completions", method: "POST")
        r.httpBody = try JSONEncoder().encode(Body(model: model, messages: msgs, stream: false))

        let (data, resp) = try await URLSession.shared.data(for: r)
        guard let http = resp as? HTTPURLResponse else { throw APIError.empty }
        guard http.statusCode == 200 else {
            throw APIError.http(http.statusCode, String(data: data, encoding: .utf8) ?? "")
        }
        struct Resp: Decodable {
            struct Choice: Decodable {
                struct M: Decodable { let content: String? }
                let message: M
            }
            let choices: [Choice]
        }
        let parsed = try JSONDecoder().decode(Resp.self, from: data)
        guard let text = parsed.choices.first?.message.content, !text.isEmpty else { throw APIError.empty }
        return text
    }
}
