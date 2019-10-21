//
//  AudioPlayingWorker.swift
//  M2
//
//  Created by Vincent Friedrich on 08.05.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation
import AVFoundation

/// A delegate for the AudioPlayingWorker.
protocol AudioPlayingWorkerDelegate: class {
    /// Indicates if the play state changed.
    ///
    /// - Parameter isPlaying: If the player is currently playing.
    func playStateChanged(isPlaying: Bool)
    /// Indicates if the duration changed.
    ///
    /// - Parameters:
    ///   - current: The current duration.
    ///   - min: The minimum duration.
    ///   - max: The maximum duration.
    func durationChanged(current: TimeInterval, min: TimeInterval, max: TimeInterval)
}

/// A worker class for playing audio.
class AudioPlayingWorker {
    /// An instance of an AVAudioPlayer for playing audio.
    private let player: AVAudioPlayer
    
    /// An instance of a CADisplayLink for linking to CADisplay for animating duration changes.
    private var displayLink: CADisplayLink?

    /// A delegate for the AudioPlayingWorker.
    weak var delegate: AudioPlayingWorkerDelegate?

    /// If the player is currently playing audio.
    var isPlaying: Bool {
        return player.isPlaying
    }
    
    /// The current time of the audio player.
    var currentTime: TimeInterval {
        return player.currentTime
    }
    
    /// The current duration of the audio player.
    var duration: TimeInterval {
        return player.duration
    }
    
    /// The file url of the audio file that is currently being played.
    var url: URL? {
        return player.url
    }

    /// Initializes the AudioPlayingWorker with a file url.
    ///
    /// - Parameter url: The file url to be initialized with.
    init?(url: URL) {
        guard let player = try? AVAudioPlayer(contentsOf: url) else { return nil }
        self.player = player
        self.displayLink = CADisplayLink(target: self, selector: #selector(durationChanged))
    }
    
    /// Convenience initializer for being initialized with a specific sound.
    ///
    /// - Parameter sound: The sound to be initialized with.
    convenience init?(sound: Sound) {
        guard let url = sound.url else { return nil }
        XCGLogger.default.debug("Init with sound \(sound)")
        self.init(url: url)
    }
    
    /// Adds itself to the display link for animating duration changes.
    func startMonitoringDuration() {
        displayLink?.add(to: .current, forMode: .common)
    }
    
    /// Removes itself from the display link for animating duration changes.
    func stopMonitoringDuration() {
        displayLink?.remove(from: .current, forMode: .common)
    }
    
    /// Gets called by the display link.
    @objc private func durationChanged() {
        // Invoke delegate that the duration changed.
        delegate?.durationChanged(current: currentTime, min: 0.0, max: duration)
    }
    
    /// Plays audio from the initialized audio file.
    func play() {
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord)
        try? AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        if player.isPlaying {
            player.stop()
        }
        player.play()
        startMonitoringDuration()
        delegate?.playStateChanged(isPlaying: isPlaying)
    }
    
    /// Pauses currently being played audio.
    func pause() {
        player.pause()
        stopMonitoringDuration()
        delegate?.playStateChanged(isPlaying: isPlaying)
    }
    
    /// Stops playing audio.
    func stop() {
        player.stop()
        stopMonitoringDuration()
        delegate?.playStateChanged(isPlaying: isPlaying)
    }
}
