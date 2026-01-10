import SwiftUI
import SwiftData

struct EditSetlistView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var setlist: Setlist
    @State private var newName: String = ""

    var body: some View {
        VStack(spacing: 24) {
            Text("Edit Setlist")
                .font(.largeTitle)
                .padding(.top, 40)

            // Rename field
            TextField("Setlist Name", text: $newName)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            // Save button
            Button("Save") {
                saveChanges()
            }
            .disabled(newName.isEmpty || newName == setlist.name)
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)

            Spacer()
        }
        .onAppear {
            newName = setlist.name
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
        .navigationTitle("Edit Setlist")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Actions
    private func saveChanges() {
        setlist.name = newName
        dismiss()
    }
}
