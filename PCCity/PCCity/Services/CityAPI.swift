import Foundation

actor CityAPI {
    static let shared = CityAPI()

    // Change this to your pc-city server URL
    var baseURL = "http://localhost:3000"

    func fetchMessages() async throws -> [Message] {
        let url = URL(string: "\(baseURL)/api/messages")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let response = try decoder.decode(MessagesResponse.self, from: data)
        return response.messages
    }

    func sendMessage(_ message: Message) async throws {
        let url = URL(string: "\(baseURL)/api/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(message)
        let (_, _) = try await URLSession.shared.data(for: request)
    }

    func fetchRoles() async throws -> [Role] {
        let url = URL(string: "\(baseURL)/api/roles")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(RolesResponse.self, from: data)
        return response.roles
    }

    func setBaseURL(_ url: String) {
        baseURL = url
    }

    func updateRole(id: String, onDuty: Bool) async throws {
        let url = URL(string: "\(baseURL)/api/roles")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["id": id, "onDuty": onDuty])
        let (_, _) = try await URLSession.shared.data(for: request)
    }
}
