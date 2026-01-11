import SwiftUI
import SwiftData

struct EditSetlistView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var setlist: Setlist

    @State private var newName: String = ""
    @State private var newTempoName: String = ""
    @State private var bpm: Int = 120

    @Query(sort: \Tempo.name) private var allTempos: [Tempo]

    var temposInSetlist: [Tempo] {
        allTempos.filter { $0.setlist == setlist }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // Title
                Text("Edit Setlist")
                    .font(.largeTitle)
                    .padding(.top, 20)

                // Rename setlist
                TextField("Setlist name", text: $newName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                Divider()

                // Add Song
                VStack(spacing: 16) {
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
                    .frame(height: 120)

                    Button("Add to Setlist") {
                        addTempo()
                    }
                    .disabled(newTempoName.isEmpty)
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)

                Divider()

                // Songs in this setlist
                VStack(alignment: .leading) {
                    Text("Songs")
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach(temposInSetlist) { tempo in
                        HStack {
                            Text(tempo.name)
                            Spacer()
                            Text("\(tempo.bpm) BPM")
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                    }
                    .onDelete(perform: deleteTempos)
                }

                Button("Save Setlist") {
                    saveChanges()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)

            }
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
        let tempo = Tempo(
            name: newTempoName,
            bpm: bpm,
            setlist: setlist
        )
        modelContext.insert(tempo)
        newTempoName = ""
    }

    private func deleteTempos(offsets: IndexSet) {
        for index in offsets {
            let tempo = temposInSetlist[index]
            modelContext.delete(tempo)
        }
    }
}
