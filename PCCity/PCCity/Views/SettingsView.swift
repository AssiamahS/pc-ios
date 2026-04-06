import SwiftUI

struct SettingsView: View {
    @State private var serverURL = "http://localhost:3000"
    @State private var saved = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Server Connection") {
                    TextField("PC City Server URL", text: $serverURL)
                        .textContentType(.URL)
                        .textInputAutocapitalization(.never)
                    Button("Save") {
                        Task {
                            await CityAPI.shared.setBaseURL(serverURL)
                            saved = true
                        }
                    }
                    if saved {
                        Text("Saved!").foregroundStyle(.green).font(.caption)
                    }
                }

                Section("About") {
                    LabeledContent("App", value: "PC City iOS")
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Connects to", value: "pc-city webapp")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
