//
//  AudioRecordingWorker.swift
//  M2
//
//  Created by Vincent Friedrich on 07.05.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation
import AVFoundation

/// A worker class for recording audio.
class AudioRecordingWorker {
    /// An instance of an AVAudioRecorder for recording audio.
    private let recorder: AVAudioRecorder

    /// The id to save the file with.
    private let id: Int
    
    init?(id: Int) {
        self.id = id
        
        // Get documents directory and create file url from id
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let url = documentsDirectory.appendingPathComponent("\(id).m4a")
        
        // Specify recording settings
        let recordSettings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ] as [String : Any]
        
        // Initialize AVAudioRecorder with file url and recording settings
        guard let recorder = try? AVAudioRecorder(url: url, settings: recordSettings) else { return nil }
        self.recorder = recorder
        self.recorder.prepareToRecord()
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord)
    }
    
    /// Record audio.
    func record() {
        recorder.record()
    }
    
    /// Stop recording audio.
    ///
    /// - Returns: The file id and its matching file url.
    func stop() -> (id: Int, fileURL: URL) {
        recorder.stop()
        return (id, recorder.url)
    }
    
    /// Requests recording authorization.
    ///
    /// - Parameter completion: The completion with success.
    static func requestAuthorization(completion: ((Bool) -> Void)? = nil) {
        AVAudioSession.sharedInstance().requestRecordPermission( { success in completion?(success) })
    }
}
