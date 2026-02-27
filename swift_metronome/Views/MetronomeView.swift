import SwiftUI
import SwiftData

struct MetronomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState

    @Query private var allTempos: [Tempo]

    var tempos: [Tempo] {
        guard let setlist = appState.activeSetlist else {
            return allTempos
                .filter { $0.setlist == nil }
                .sorted { $0.order < $1.order }
        }

        return allTempos
            .filter { $0.setlist == setlist }
            .sorted { $0.order < $1.order }
    }

    @State private var bpm: Int = 120
    @State private var selectedTempoID: UUID?
    @State private var isPlaying = false
    @State private var isSoundEnabled = true
    @State private var tapFlashID = 0
    @State private var lastTapTime: Date?
    @State private var tapIntervals: [TimeInterval] = []
    @State private var showAddTempo = false
    @State private var newTempoName = ""

    private let maxTapSamples = 5
    private let tapResetThreshold: TimeInterval = 2.0

    var selectedTempo: Tempo? {
        tempos.first { $0.id == selectedTempoID }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Active setlist banner
            if let setlist = appState.activeSetlist {
                Label(setlist.name, systemImage: "music.note.list")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 12)
                    .padding(.bottom, 2)
            }

            // Song / state title
            Text(selectedTempo?.name ?? "Metronome")
                .font(.title2.bold())
                .padding(.top, appState.activeSetlist == nil ? 40 : 8)
                .padding(.bottom, 8)

            BeatIndicatorView(
                bpm: bpm,
                accentPattern: appState.activeAccentPattern,
                isPlaying: isPlaying,
                isSoundEnabled: $isSoundEnabled,
                tapFlashID: tapFlashID
            )

            // Large BPM display
            Text("\(bpm)")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .monospacedDigit()
                .padding(.top, 12)

            Text("BPM")
                .font(.caption)
                .foregroundStyle(.secondary)

            // Picker with ± buttons
            HStack(spacing: 20) {
                Button {
                    bpm = max(40, bpm - 1)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                        .foregroundStyle(.blue)
                }

                Picker("BPM", selection: $bpm) {
                    ForEach(40...240, id: \.self) { value in
                        Text("\(value)").tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 80, height: 100)
                .clipped()
                .onChange(of: bpm) {
                    // Deselect tempo when user manually changes BPM
                    if let id = selectedTempoID,
                       let tempo = tempos.first(where: { $0.id == id }),
                       tempo.bpm != bpm {
                        selectedTempoID = nil
                    }
                }

                Button {
                    bpm = min(240, bpm + 1)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundStyle(.blue)
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 4)

            // Action row: Play/Stop | Tap | Sound
            HStack(spacing: 12) {
                Button {
                    isPlaying.toggle()
                } label: {
                    Label(
                        isPlaying ? "Stop" : "Play",
                        systemImage: isPlaying ? "stop.fill" : "play.fill"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(isPlaying ? .red : .blue)

                Button {
                    registerTap()
                } label: {
                    Label("Tap", systemImage: "hand.tap")
                }
                .buttonStyle(.bordered)

                Button {
                    isSoundEnabled.toggle()
                } label: {
                    Image(systemName: isSoundEnabled
                          ? "speaker.wave.2.fill"
                          : "speaker.slash.fill")
                        .font(.title3)
                }
                .buttonStyle(.bordered)
                .tint(isSoundEnabled ? .primary : .secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)

            Divider()

            List {
                ForEach(tempos) { tempo in
                    Button {
                        bpm = tempo.bpm
                        selectedTempoID = tempo.id
                    } label: {
                        HStack {
                            Text(tempo.name)
                            Spacer()
                            Text("\(tempo.bpm) BPM")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(
                        tempo.id == selectedTempoID
                            ? Color.blue.opacity(0.12)
                            : Color.clear
                    )
                }
                .onDelete(perform: deleteTempos)

                // Add Tempo (free play mode only)
                if appState.activeSetlist == nil {
                    if showAddTempo {
                        HStack {
                            TextField("Tempo name", text: $newTempoName)
                                .textFieldStyle(.roundedBorder)
                                .submitLabel(.done)
                                .onSubmit { addStandaloneTempo() }
                            Button("Add") {
                                addStandaloneTempo()
                            }
                            .disabled(newTempoName.isEmpty)
                        }
                    } else {
                        Button {
                            showAddTempo = true
                        } label: {
                            Label("Add Tempo", systemImage: "plus")
                        }
                        .foregroundStyle(.blue)
                    }
                }
            }
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            SynthMetronome.shared.setClickStyle(appState.selectedClickSound.synthStyle)
        }
        .onChange(of: appState.selectedClickSound) {
            SynthMetronome.shared.setClickStyle(appState.selectedClickSound.synthStyle)
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            isPlaying = false
        }
    }

    // MARK: - Tap Tempo

    private func registerTap() {
        tapFlashID += 1

        let now = Date()

        defer { lastTapTime = now }

        guard let last = lastTapTime else {
            tapIntervals.removeAll()
            return
        }

        let interval = now.timeIntervalSince(last)

        // Reset if user paused too long
        if interval > tapResetThreshold {
            tapIntervals.removeAll()
            return
        }

        tapIntervals.append(interval)

        // Keep recent samples only
        if tapIntervals.count > maxTapSamples {
            tapIntervals.removeFirst()
        }

        let averageInterval = tapIntervals.reduce(0, +) / Double(tapIntervals.count)
        let newBPM = Int(round(60.0 / averageInterval))

        // Clamp to sane range
        bpm = min(max(newBPM, 40), 240)
    }

    // MARK: - CRUD

    private func deleteTempos(offsets: IndexSet) {
        for index in offsets {
            let tempo = tempos[index]
            if tempo.id == selectedTempoID {
                selectedTempoID = nil
            }
            modelContext.delete(tempo)
        }
    }

    private func addStandaloneTempo() {
        guard !newTempoName.isEmpty else { return }
        let nextOrder = tempos.count
        let tempo = Tempo(
            name: newTempoName,
            bpm: bpm,
            setlist: nil,
            order: nextOrder
        )
        modelContext.insert(tempo)
        newTempoName = ""
        showAddTempo = false
    }
}

// MARK: - Beat Indicator

struct BeatIndicatorView: View {
    let bpm: Int
    let accentPattern: [Bool]
    let isPlaying: Bool
    @Binding var isSoundEnabled: Bool
    let tapFlashID: Int

    @State private var isPulsing = false
    @State private var isAccentBeat = false
    @State private var beatIndex = 0
    @State private var timer: Timer?

    var body: some View {
        Circle()
            .fill(
                isPulsing
                ? (isAccentBeat ? Color.red : Color.blue)
                : Color.gray.opacity(0.3)
            )
            .frame(width: 80, height: 80)
            .scaleEffect(isPulsing ? 1.2 : 1.0)
            .animation(.easeOut(duration: 0.1), value: isPulsing)
            .onAppear {
                if isPlaying { startPulse() }
            }
            .onDisappear { stopPulse() }
            .onChange(of: bpm) { if isPlaying { restartPulse() } }
            .onChange(of: accentPattern) { if isPlaying { restartPulse() } }
            .onChange(of: isPlaying) {
                if isPlaying {
                    restartPulse()
                } else {
                    stopPulse()
                }
            }
            .onChange(of: tapFlashID) {
                if isSoundEnabled {
                    SynthMetronome.shared.play(.tap)
                }
                isPulsing = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPulsing = false
                }
            }
    }

    // MARK: - Pulse Logic

    private func startPulse() {
        timer?.invalidate()

        let interval = 60.0 / Double(bpm)

        fireBeat(interval: interval)

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            fireBeat(interval: interval)
        }
    }

    private func stopPulse() {
        timer?.invalidate()
        timer = nil
        isPulsing = false
        beatIndex = 0
    }

    private func fireBeat(interval: Double) {
        isPulsing = true

        let index = beatIndex % accentPattern.count
        let isAccent = accentPattern[index]

        isAccentBeat = isAccent

        if isSoundEnabled {
            SynthMetronome.shared.play(isAccent ? .accent : .tap)
        }

        beatIndex = (beatIndex + 1) % accentPattern.count

        DispatchQueue.main.asyncAfter(deadline: .now() + interval / 2) {
            isPulsing = false
        }
    }

    private func restartPulse() {
        beatIndex = 0
        startPulse()
    }
}

// MARK: - Preview

#Preview {
    MetronomeView()
        .modelContainer(for: Tempo.self, inMemory: true)
}
