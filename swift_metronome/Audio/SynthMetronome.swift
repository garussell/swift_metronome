import AVFoundation

// MARK: - Synthesized Metronome
final class SynthMetronome {

    static let shared = SynthMetronome()

    // MARK: - Types

    enum Sound {
        case tap
        case accent
    }

    enum ClickStyle {
        case classic
        case soft
        case sharp
    }

    // MARK: - Audio Engine

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let sampleRate: Double = 44_100

    // MARK: - Buffers

    private var tapBuffers: [ClickStyle: AVAudioPCMBuffer] = [:]
    private var accentBuffers: [ClickStyle: AVAudioPCMBuffer] = [:]

    // MARK: - State

    private var currentStyle: ClickStyle = .classic

    // MARK: - Init

    private init() {
        engine.attach(player)

        let format = AVAudioFormat(
            standardFormatWithSampleRate: sampleRate,
            channels: 1
        )!

        engine.connect(player, to: engine.mainMixerNode, format: format)

        generateBuffers(format: format)
        startEngine()
        activateAudioSession()
    }

    // MARK: - Public API

    func setClickStyle(_ style: ClickStyle) {
        currentStyle = style
    }
    
    func setClickSound(_ sound: AppState.ClickSound) {
        switch sound {
        case .classic:
            setClickStyle(.classic)
        case .soft:
            setClickStyle(.soft)
        case .sharp:
            setClickStyle(.sharp)
        }
    }

    func play(_ sound: Sound) {
        let buffer: AVAudioPCMBuffer?

        switch sound {
        case .tap:
            buffer = tapBuffers[currentStyle]
        case .accent:
            buffer = accentBuffers[currentStyle]
        }

        guard let buffer else { return }

        player.scheduleBuffer(
            buffer,
            at: nil,
            options: .interrupts,
            completionHandler: nil
        )

        if !player.isPlaying {
            player.play()
        }
    }

    // MARK: - Buffer Setup

    private func generateBuffers(format: AVAudioFormat) {

        // Classic (what you already had)
        tapBuffers[.classic] = makeBeepBuffer(
            frequency: 900,
            amplitude: 0.35,
            duration: 0.05,
            format: format
        )

        accentBuffers[.classic] = makeBeepBuffer(
            frequency: 1500,
            amplitude: 0.7,
            duration: 0.05,
            format: format
        )

        // Soft
        tapBuffers[.soft] = makeBeepBuffer(
            frequency: 700,
            amplitude: 0.25,
            duration: 0.06,
            format: format
        )

        accentBuffers[.soft] = makeBeepBuffer(
            frequency: 1100,
            amplitude: 0.45,
            duration: 0.06,
            format: format
        )

        // Sharp
        tapBuffers[.sharp] = makeBeepBuffer(
            frequency: 1200,
            amplitude: 0.4,
            duration: 0.03,
            format: format
        )

        accentBuffers[.sharp] = makeBeepBuffer(
            frequency: 2000,
            amplitude: 0.8,
            duration: 0.03,
            format: format
        )
    }

    // MARK: - Beep Generator

    private func makeBeepBuffer(
        frequency: Float,
        amplitude: Float,
        duration: Float,
        format: AVAudioFormat
    ) -> AVAudioPCMBuffer {

        let frameCount = AVAudioFrameCount(format.sampleRate * Double(duration))

        let buffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: frameCount
        )!

        buffer.frameLength = frameCount

        let channelData = buffer.floatChannelData![0]
        let sr = Float(format.sampleRate)

        for i in 0..<Int(frameCount) {
            let sample = sin(2.0 * Float.pi * frequency * Float(i) / sr)
            channelData[i] = sample * amplitude
        }

        return buffer
    }

    // MARK: - Engine / Session

    private func startEngine() {
        do {
            try engine.start()
        } catch {
            print("AVAudioEngine failed to start:", error)
        }
    }

    private func activateAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Failed to activate audio session:", error)
        }
    }
}
