import SwiftUI

struct DirectoryView: View {
    let staff = [
        ("Alexandria Brooks, MD", "Hospitalist", "hospital"),
        ("Will Rosenblom, MD", "On-Call Cardiologist", "doctor"),
        ("T.J. Whitmore, MD", "On-Call Pediatrician", "doctor"),
        ("Alice Stevens, MD", "On-Call Radiologist", "lab"),
        ("Deborah Wilson, CPhT", "Pharmacist", "pharmacy"),
        ("Felicia Yang, RN", "Floor Nurse", "hospital"),
        ("Adrian", "Floor Nurse", "hospital"),
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(staff, id: \.0) { name, role, building in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .overlay {
                                Text(String(name.prefix(1)))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                            }
                        VStack(alignment: .leading) {
                            Text(name).font(.subheadline).fontWeight(.medium)
                            Text(role).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Directory")
        }
    }
}
