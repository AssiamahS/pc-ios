import SwiftUI

@MainActor @Observable
final class InboxViewModel {
    var messages: [Message] = []
    var isLoading = false
    var error: String?
    var showCompose = false

    // Demo messages for offline/initial state
    static let demoMessages: [Message] = [
        Message(id: "d1", from: "Will Rosenblom, MD", to: "You", fromRole: "On-Call Cardiologist", toRole: "Emergency Department MD", body: "Patient Ryan's results indicate pericardial effusion due to a possible viral infection. Must be prepped for pericardiocentesis.", priority: .urgent, timestamp: Date().addingTimeInterval(-300), buildingId: "hospital"),
        Message(id: "d2", from: "System", to: "You", fromRole: "System", toRole: "Emergency Department MD", body: "You're On Duty: Emergency Department", priority: .priority, timestamp: Date().addingTimeInterval(-600), buildingId: "hospital"),
        Message(id: "d3", from: "Adrian", to: "Floor Nurse, House Supervisor", fromRole: "Floor Nurse", toRole: "House Supervisor", body: "Update please?", priority: .normal, timestamp: Date().addingTimeInterval(-900), buildingId: "hospital"),
        Message(id: "d4", from: "Alexandria Brooks, MD", to: "You", fromRole: "Hospitalist", toRole: "Emergency Department MD", body: "Good news. Labs been sent, results pending.", priority: .normal, timestamp: Date().addingTimeInterval(-1200), buildingId: "hospital"),
        Message(id: "d5", from: "Felicia Yang, RN", to: "You", fromRole: "Floor Nurse", toRole: "Emergency Department MD", body: "Patient in room 6343 has...", priority: .normal, timestamp: Date().addingTimeInterval(-1800), buildingId: "hospital"),
    ]

    func load() async {
        isLoading = true
        do {
            let fetched = try await CityAPI.shared.fetchMessages()
            messages = fetched.isEmpty ? Self.demoMessages : fetched
        } catch {
            messages = Self.demoMessages
            self.error = nil // silently use demo data
        }
        isLoading = false
    }
}

struct InboxView: View {
    @State private var vm = InboxViewModel()
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Priority banner
                if vm.messages.contains(where: { $0.priority == .urgent }) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.white)
                        Text("You are receiving Priority Messages")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.red)
                }

                // Inbox / Groups picker
                Picker("", selection: $selectedTab) {
                    Text("INBOX").tag(0)
                    Text("GROUPS").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)

                // Messages list
                List {
                    ForEach(vm.messages) { msg in
                        MessageRow(message: msg)
                    }
                }
                .listStyle(.plain)
                .refreshable { await vm.load() }
            }
            .navigationTitle("Memorial Hospital")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { vm.showCompose = true } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $vm.showCompose) {
                ComposeView()
            }
        }
        .task { await vm.load() }
    }
}

struct MessageRow: View {
    let message: Message

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar circle
            Circle()
                .fill(message.isPriority ? Color.red : Color.gray.opacity(0.3))
                .frame(width: 44, height: 44)
                .overlay {
                    Text(String(message.from.prefix(1)))
                        .font(.headline)
                        .foregroundStyle(message.isPriority ? .white : .primary)
                }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(message.from)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    if message.isPriority {
                        Text(message.priority == .urgent ? "PRIORITY" : "ALERT")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.red)
                    }
                }
                Text(message.fromRole)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(message.body)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}
