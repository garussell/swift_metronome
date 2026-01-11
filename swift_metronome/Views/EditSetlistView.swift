import SwiftUI
import SwiftData

struct EditSetlistView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var setlist: Setlist

    @State private var newName: String = ""
    @State private var newTempoName: String = ""
    @State private var bpm: Int = 120

    @Query(sort: \Tempo.order) private var allTempos: [Tempo]

    var temposInSetlist: [Tempo] {
        allTempos.filter { $0.setlist == setlist }
    }

    var body: some View {
        VStack(spacing: 16) {

            // Title
            Text("Edit Setlist")
                .font(.largeTitle)
                .padding(.top, 16)

            // Rename setlist
            TextField("Setlist name", text: $newName)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            Divider()

            // Add Song
            VStack(spacing: 12) {
                Text("Add Song")
                    .font(.headline)

                TextField("Song name", text: $newTempoName)
                    .textFieldStyle(.roundedBorder)

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
            .padding(.horizontal)

            Divider()

            // Songs list with drag reordering
            List {
                ForEach(temposInSetlist) { tempo in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(tempo.name)
                            Text("\(tempo.bpm) BPM")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Button {
                            modelContext.delete(tempo)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red)
                                .font(.title3)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .onMove(perform: moveTempos)
            }
            .frame(maxHeight: 300)
            .toolbar {
                EditButton() // enables drag handles
            }

            Button("Save Setlist") {
                saveChanges()
            }
            .buttonStyle(.borderedProminent)

            Button(role: .destructive) {
                deleteSetlist()
            } label: {
                Label("Delete Setlist", systemImage: "trash")
            }
            .padding(.bottom, 20)

        }
        .onAppear {
            newName = setlist.name
        }
        .navigationTitle("Edit Setlist")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Actions

    private func saveChanges() {
        setlist.name = newName
        dismiss()
    }

    private func addTempo() {
        let nextOrder = temposInSetlist.count

        let tempo = Tempo(
            name: newTempoName,
            bpm: bpm,
            setlist: setlist,
            order: nextOrder
        )

        modelContext.insert(tempo)
        newTempoName = ""
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
