import SwiftUI
import SwiftData
import AVFoundation

@Model
final class Tempo {
    @Attribute(.unique) var id: UUID
    var name: String
    var bpm: Int

    init(name: String, bpm: Int) {
        self.id = UUID()
        self.name = name
        self.bpm = bpm
    }
}

var clickPlayer: AVAudioPlayer?

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tempos: [Tempo] // Fetch all saved tempos

    @State private var bpm: Int = 120
    @State private var isPulsing: Bool = false
    @State private var timer: Timer?
    @State private var newTempoName: String = ""
    @State private var selectedTempoName: String? = nil
    @State private var isMuted: Bool = false

    var body: some View {
        VStack(spacing: 30) {
            Text(selectedTempoName == nil ? "Tempo" : "\(selectedTempoName!)")
                .font(.title)
                .padding(.top, 50)

            // BPM adjuster
            Picker("Tempo", selection: $bpm) {
                ForEach(40...240, id: \.self) { value in
                    Text("\(value) BPM")
                        .tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
            .clipped()
            .onChange(of: bpm) {
                restartPulse()
            }

            // Mute button
            
            Toggle(isOn: $isMuted) {
                Label("Mute", systemImage: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
            }
            .padding(.horizontal)
            
            // Pulsing circle
            Circle()
                .fill(Color.blue)
                .frame(width: 100, height: 100)
                .opacity(isPulsing ? 1.0 : 0.2)

            // Add tempo form
            HStack {
                TextField("Name", text: $newTempoName)
                    .textFieldStyle(.roundedBorder)
                Button("Add") { addTempo() }
            }
            .padding(.horizontal)

            // List of saved tempos
            List {
                ForEach(tempos, id: \.id) { tempo in
                    Button {
                        bpm = tempo.bpm
                        selectedTempoName = tempo.name
                        restartPulse()
                    } label: {
                        HStack {
                            Text(tempo.name)
                            Spacer()
                            Text("\(tempo.bpm) BPM")
                        }
                    }
                }
                .onDelete(perform: deleteTempos)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
        .onAppear {
            setupClick()
            startPulse()
        }
        .onDisappear { timer?.invalidate() }
    }

    // MARK: - BPM Pulse
    func startPulse() {
        if !isMuted {
            clickPlayer?.play()
        }
        
        timer?.invalidate()
        let interval = 60.0 / Double(bpm)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            isPulsing = true
            DispatchQueue.main.asyncAfter(deadline: .now() + interval / 2) { isPulsing = false }
        }
    }

    func restartPulse() { startPulse() }
    
    func updateBPM(by delta: Int) { bpm = max(1, min(300, bpm + delta)); restartPulse() }

    // MARK: - CRUD
    func addTempo() {
        guard !newTempoName.isEmpty else { return }
        let newTempo = Tempo(name: newTempoName, bpm: bpm)
        modelContext.insert(newTempo)
        newTempoName = ""
    }

    func deleteTempos(offsets: IndexSet) {
        for index in offsets {
            let tempo = tempos[index]
            
            if tempo.name == selectedTempoName {
                selectedTempoName = nil
            }
            
            modelContext.delete(tempos[index])
        }
    }
    
    func setupClick() {
        guard let url = Bundle.main.url(forResource: "click", withExtension: "wav") else { return }
        clickPlayer = try? AVAudioPlayer(contentsOf: url)
        clickPlayer?.prepareToPlay()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Tempo.self, inMemory: true)
}
