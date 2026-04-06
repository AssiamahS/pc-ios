import Foundation

struct Message: Identifiable, Codable {
    let id: String
    let from: String
    let to: String
    let fromRole: String
    let toRole: String
    let body: String
    let priority: Priority
    let timestamp: Date
    let buildingId: String?

    enum Priority: String, Codable {
        case normal
        case priority
        case urgent
    }

    var isPriority: Bool { priority == .priority || priority == .urgent }
}

struct MessagesResponse: Codable {
    let messages: [Message]
}
