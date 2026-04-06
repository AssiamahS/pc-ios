import SwiftUI

struct ComposeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var recipient = ""
    @State private var messageBody = ""
    @State private var priority = Message.Priority.normal
    @State private var isSending = false

    var body: some View {
        NavigationStack {
            Form {
                TextField("To (name or role)", text: $recipient)
                Picker("Priority", selection: $priority) {
                    Text("Normal").tag(Message.Priority.normal)
                    Text("Priority").tag(Message.Priority.priority)
                    Text("Urgent").tag(Message.Priority.urgent)
                }
                Section("Message") {
                    TextEditor(text: $messageBody)
                        .frame(minHeight: 120)
                }
            }
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send") {
                        Task { await send() }
                    }
                    .disabled(recipient.isEmpty || messageBody.isEmpty || isSending)
                }
            }
        }
    }

    private func send() async {
        isSending = true
        let msg = Message(
            id: UUID().uuidString,
            from: "You",
            to: recipient,
            fromRole: "Emergency Department MD",
            toRole: recipient,
            body: messageBody,
            priority: priority,
            timestamp: Date(),
            buildingId: "hospital"
        )
        try? await CityAPI.shared.sendMessage(msg)
        dismiss()
    }
}
