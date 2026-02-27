import SwiftUI
import SwiftData

struct EditSetlistView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var setlist: Setlist

    @State private var newName: String = ""
    @State private var newTempoName: String = ""
    @State private var bpm: Int = 120
    @State private var showDeleteConfirmation = false
    @State private var showAddSong = false

    @FocusState private var tempoNameFocused: Bool

    @Query(sort: \Tempo.order) private var allTempos: [Tempo]

    var temposInSetlist: [Tempo] {
        allTempos.filter { $0.setlist == setlist }
    }

    var body: some View {
        VStack(spacing: 16) {
            renameSection

            Divider()

            addSongSection

            Divider()

            songsList
        }
        .safeAreaInset(edge: .bottom) {
            actionButtons
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(.regularMaterial)
        }
        .alert("Delete \"\(setlist.name)\"?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) { deleteSetlist() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete the setlist and all its songs.")
        }
        .onAppear {
            newName = setlist.name
        }
        .navigationTitle("Edit Setlist")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                EditButton()
            }
        }
    }

    // MARK: - View Components

    private var renameSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Setlist Name")
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("Setlist name", text: $newName)
                .textFieldStyle(.roundedBorder)
        }
        .padding(.horizontal)
    }

    private var addSongSection: some View {
        DisclosureGroup("Add Song", isExpanded: $showAddSong) {
            VStack(spacing: 12) {
                TextField("Song name", text: $newTempoName)
                    .textFieldStyle(.roundedBorder)
                    .focused($tempoNameFocused)
                    .submitLabel(.done)
                    .onSubmit { addTempo() }

                Picker("BPM", selection: $bpm) {
                    ForEach(40...240, id: \.self) { value in
                        Text("\(value) BPM").tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 100)

                Button("Add to Setlist") {
                    addTempo()
                }
                .disabled(newTempoName.isEmpty)
                .buttonStyle(.borderedProminent)
            }
            .padding(.top, 8)
        }
        .padding(.horizontal)
    }

    private var songsList: some View {
        List {
            ForEach(temposInSetlist) { tempo in
                TempoRow(tempo: tempo, onDelete: {
                    modelContext.delete(tempo)
                })
            }
            .onMove(perform: moveTempos)
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button("Save Setlist") {
                saveChanges()
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)

            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label("Delete Setlist", systemImage: "trash")
            }
        }
    }

    // MARK: - Actions

    private func saveChanges() {
        setlist.name = newName
        dismiss()
    }

    private func addTempo() {
        guard !newTempoName.isEmpty else { return }
        let nextOrder = temposInSetlist.count

        let tempo = Tempo(
            name: newTempoName,
            bpm: bpm,
            setlist: setlist,
            order: nextOrder
        )

        modelContext.insert(tempo)
        newTempoName = ""
        tempoNameFocused = false
    }

    private func moveTempos(from source: IndexSet, to destination: Int) {
        var reordered = temposInSetlist
        reordered.move(fromOffsets: source, toOffset: destination)

        for (index, tempo) in reordered.enumerated() {
            tempo.order = index
        }
    }

    private func deleteSetlist() {
        for tempo in temposInSetlist {
            modelContext.delete(tempo)
        }

        modelContext.delete(setlist)
        dismiss()
    }
}

// MARK: - Supporting Views

struct TempoRow: View {
    let tempo: Tempo
    let onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(tempo.name)
                Text("\(tempo.bpm) BPM")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                onDelete()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.red)
                    .font(.title3)
            }
            .buttonStyle(.plain)
        }
    }
}
