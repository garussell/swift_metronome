import AVFoundation

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
