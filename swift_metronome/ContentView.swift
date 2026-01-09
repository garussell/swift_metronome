import SwiftUI
import SwiftData
import AVFoundation

// MARK: - SwiftData Model
@Model
final class Tempo {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var bpm: Int

    init(name: String, bpm: Int) {
        self.name = name
        self.bpm = bpm
    }
}

// MARK: - Synthesized Metronome
class SynthMetronome {
    static let shared = SynthMetronome()

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private var buffer: AVAudioPCMBuffer?

    private init() {
        engine.attach(player)

        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        engine.connect(player, to: engine.mainMixerNode, format: format)

        // Generate a short sine wave beep (50ms)
        let frameCount = AVAudioFrameCount(format.sampleRate * 0.05)
        buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer?.frameLength = frameCount

        let freq: Float = 1000 // 1kHz beep
        let sampleRate = Float(format.sampleRate)
        let amplitude: Float = 0.5
        let data = buffer!.floatChannelData![0]

        for i in 0..<Int(frameCount) {
            data[i] = sin(2 * Float.pi * freq * Float(i) / sampleRate) * amplitude
        }

        do {
            try engine.start()
        } catch {
            print("Failed to start AVAudioEngine:", error)
        }

        // Activate audio session for iPhone
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("Failed to activate audio session:", error)
        }
    }

    func playClick() {
        guard let buffer = buffer else { return }
        player.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
        player.play()
    }
}

// MARK: - ContentView
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tempo.name) private var tempos: [Tempo] // specify Tempo as root type

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

            // BPM wheel picker
            Picker("Tempo", selection: $bpm) {
                ForEach(40...240, id: \.self) { value in
                    Text("\(value) BPM").tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
            .clipped()
            .onChange(of: bpm) { restartPulse() }

            // Mute toggle
            Toggle(isOn: $isMuted) {
                Label("Mute", systemImage: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
            }
            .padding(.horizontal)

            // Pulsing circle
            Circle()
                .fill(Color.blue)
                .frame(width: 100, height: 100)
                .opacity(isPulsing ? 1.0 : 0.2)
                .animation(.easeInOut(duration: 0.1), value: isPulsing)

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
        .onAppear { startPulse() }
        .onDisappear { timer?.invalidate() }
    }

    // MARK: - BPM Pulse
    func startPulse() {
        timer?.invalidate()
        let interval = 60.0 / Double(bpm)

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            isPulsing = true

            if !isMuted {
                SynthMetronome.shared.playClick()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + interval / 2) {
                isPulsing = false
            }
        }
    }

    func restartPulse() { startPulse() }

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
}

// MARK: - Preview
#Preview {
    ContentView()
        .modelContainer(for: Tempo.self, inMemory: true)
}
