import SwiftUI

@MainActor @Observable
final class RolesViewModel {
    var roles: [Role] = []
    var isLoading = false
    var selectedTab = 0 // 0 = Roles, 1 = My Roles

    static let demoRoles: [Role] = [
        Role(id: "r1", title: "Emergency Department MD", assignee: "Alexandria Brooks, MD", credential: "MD", buildingId: "hospital", onDuty: true),
        Role(id: "r2", title: "Hospitalist", assignee: "Alexandria Brooks, MD", credential: "MD", buildingId: "hospital", onDuty: false),
        Role(id: "r3", title: "House Supervisor", assignee: "Will Rosenblom, MD", credential: "MD", buildingId: "hospital", onDuty: false),
        Role(id: "r4", title: "On-Call Cardiologist", assignee: "Will Rosenblom, MD", credential: "MD", buildingId: "doctor", onDuty: false),
        Role(id: "r5", title: "On-Call Pediatrician", assignee: "T.J. Whitmore, MD", credential: "MD", buildingId: "doctor", onDuty: false),
        Role(id: "r6", title: "On-Call Radiologist", assignee: "Alice Stevens, MD", credential: "MD", buildingId: "lab", onDuty: false),
        Role(id: "r7", title: "Pharmacist", assignee: "Deborah Wilson, CPhT", credential: "CPhT", buildingId: "pharmacy", onDuty: false),
    ]

    func load() async {
        isLoading = true
        do {
            let fetched = try await CityAPI.shared.fetchRoles()
            roles = fetched.isEmpty ? Self.demoRoles : fetched
        } catch {
            roles = Self.demoRoles
        }
        isLoading = false
    }

    func toggleDuty(_ role: Role) async {
        guard let idx = roles.firstIndex(where: { $0.id == role.id }) else { return }
        roles[idx].onDuty.toggle()
        try? await CityAPI.shared.updateRole(id: role.id, onDuty: roles[idx].onDuty)
    }
}

struct RolesView: View {
    @State private var vm = RolesViewModel()
    @State private var search = ""

    var filteredRoles: [Role] {
        if search.isEmpty { return vm.roles }
        return vm.roles.filter { $0.title.localizedCaseInsensitiveContains(search) || $0.assignee.localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Roles / My Roles picker
                Picker("", selection: $vm.selectedTab) {
                    Text("Roles").tag(0)
                    Text("My Roles").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)

                List {
                    ForEach(filteredRoles) { role in
                        RoleRow(role: role) {
                            Task { await vm.toggleDuty(role) }
                        }
                    }
                }
                .listStyle(.plain)
                .refreshable { await vm.load() }
            }
            .searchable(text: $search, prompt: "Filter")
            .navigationTitle("Memorial Hospital of Santa Mon...")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task { await vm.load() }
    }
}

struct RoleRow: View {
    let role: Role
    let onToggle: () -> Void

    private var buildingColor: Color {
        switch role.buildingId {
        case "hospital": return .red
        case "doctor": return .blue
        case "pharmacy": return .green
        case "lab": return .purple
        case "insurance": return .orange
        default: return .gray
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(buildingColor)
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: iconName)
                        .foregroundStyle(.white)
                        .font(.system(size: 18))
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(role.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                if role.onDuty {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.caption)
                        Text("You're on Duty")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }

                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(role.assignee)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture { onToggle() }
        .padding(.vertical, 4)
    }

    private var iconName: String {
        switch role.buildingId {
        case "hospital": return "cross.fill"
        case "doctor": return "stethoscope"
        case "pharmacy": return "pill.fill"
        case "lab": return "flask.fill"
        default: return "person.fill"
        }
    }
}
