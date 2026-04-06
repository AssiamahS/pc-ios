import Foundation

struct Role: Identifiable, Codable {
    let id: String
    let title: String
    let assignee: String
    let credential: String
    let buildingId: String
    var onDuty: Bool
}

struct RolesResponse: Codable {
    let roles: [Role]
}
