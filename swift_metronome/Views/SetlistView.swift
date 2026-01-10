import SwiftUI
import SwiftData

struct SetlistView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query(sort: \Setlist.name) private var setlists: [Setlist]

    @State private var newSetlistName: String = ""

    // Push-navigation state
    @State private var selectedSetlistForEdit: Setlist?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {

                // Title
                Text("Setlist")
                    .font(.largeTitle)
                    .padding(.top, 40)
                    .foregroundStyle(.white)

                // Add setlist row
                HStack {
                    TextField("New setlist", text: $newSetlistName)
                        .textFieldStyle(.roundedBorder)

                    Button("Add") {
                        addSetlist()
                    }
                    .disabled(newSetlistName.isEmpty)
                }
                .padding(.horizontal)

                // Setlist list
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(setlists) { setlist in
                            setlistRow(setlist)
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black)
            .navigationDestination(item: $selectedSetlistForEdit) { setlist in
                EditSetlistView(setlist: setlist)
            }
        }
    }

    // MARK: - Setlist Row
    @ViewBuilder
    private func setlistRow(_ setlist: Setlist) -> some View {
        HStack {

            // Select setlist (active for metronome)
            Button {
                appState.activeSetlist = setlist
            } label: {
                Text(setlist.name)
                    .font(.headline)
                    .foregroundStyle(.black)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(
                        appState.activeSetlist == setlist
                            ? Color.blue.opacity(0.25)
                            : Color.white
                    )
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            // Edit → push navigation
            Button("Edit") {
                selectedSetlistForEdit = setlist
            }
            .foregroundStyle(.blue)
        }
    }

    // MARK: - Actions
    private func addSetlist() {
        let setlist = Setlist(name: newSetlistName)
        modelContext.insert(setlist)
        newSetlistName = ""
    }
}
