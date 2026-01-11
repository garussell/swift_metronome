import SwiftUI
import SwiftData

struct SetlistView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query(sort: \Setlist.name) private var setlists: [Setlist]

    @State private var newSetlistName: String = ""
    @State private var selectedSetlistForEdit: Setlist?

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                // Title
                Text("Setlists")
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

                // List of setlists
                List {
                    ForEach(setlists) { setlist in
                        HStack {
                            // Select active setlist
                            Button {
                                appState.activeSetlist = setlist
                            } label: {
                                Text(setlist.name)
                                    .font(.headline)
                                    .foregroundStyle(.black)
                                    .padding(10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        appState.activeSetlist == setlist
                                            ? Color.blue.opacity(0.25)
                                            : Color.white
                                    )
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)

                            // Edit button
                            Button("Edit") {
                                selectedSetlistForEdit = setlist
                            }
                            .foregroundStyle(.blue)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: deleteSetlists) // Swipe-to-delete
                }
                .listStyle(.plain)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black)
            .navigationDestination(item: $selectedSetlistForEdit) { setlist in
                EditSetlistView(setlist: setlist)
            }
        }
    }

    // MARK: - CRUD
    private func addSetlist() {
        let setlist = Setlist(name: newSetlistName)
        modelContext.insert(setlist)
        newSetlistName = ""
    }

    private func deleteSetlists(offsets: IndexSet) {
        for index in offsets {
            let setlist = setlists[index]
            // Clear active setlist if it's being deleted
            if appState.activeSetlist == setlist {
                appState.activeSetlist = nil
            }
            modelContext.delete(setlist)
        }
    }
}
