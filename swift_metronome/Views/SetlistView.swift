import SwiftUI
import SwiftData

struct SetlistView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query(sort: \Setlist.name) private var setlists: [Setlist]

    @State private var newSetlistName: String = ""
    @State private var selectedSetlistForEdit: Setlist?
    @State private var showAddField = false

    var body: some View {
        NavigationStack {
            List {
                // Always-visible option to clear the active setlist
                Button {
                    appState.activeSetlist = nil
                } label: {
                    Text("All Tempos")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            appState.activeSetlist == nil
                                ? Color.blue.opacity(0.25)
                                : Color.clear
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.vertical, 4)

                if setlists.isEmpty {
                    Text("No setlists yet. Tap + to add one.")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }

                ForEach(setlists) { setlist in
                    HStack {
                        Button {
                            appState.activeSetlist = setlist
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(setlist.name)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text("\(setlist.tempos.count) \(setlist.tempos.count == 1 ? "song" : "songs")")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                appState.activeSetlist == setlist
                                    ? Color.blue.opacity(0.25)
                                    : Color.clear
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)

                        Button("Edit") {
                            selectedSetlistForEdit = setlist
                        }
                        .foregroundStyle(.blue)
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Setlists")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddField.toggle()
                        newSetlistName = ""
                    } label: {
                        Image(systemName: showAddField ? "xmark" : "plus")
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if showAddField {
                    HStack {
                        TextField("Setlist name", text: $newSetlistName)
                            .textFieldStyle(.roundedBorder)
                            .submitLabel(.done)
                            .onSubmit { addSetlist() }

                        Button("Add") {
                            addSetlist()
                        }
                        .disabled(newSetlistName.isEmpty)
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(.regularMaterial)
                }
            }
            .navigationDestination(item: $selectedSetlistForEdit) { setlist in
                EditSetlistView(setlist: setlist)
            }
        }
    }

    // MARK: - CRUD

    private func addSetlist() {
        guard !newSetlistName.isEmpty else { return }
        let setlist = Setlist(name: newSetlistName)
        modelContext.insert(setlist)
        newSetlistName = ""
        showAddField = false
    }
}
