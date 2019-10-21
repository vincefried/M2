//
//  Sound.swift
//  M2
//
//  Created by Vincent Friedrich on 17.07.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// A sound that can be played using the AudioPlayingWorker.
///
/// - messageEditing: A sound for a typed letter in a message.
/// - message: A sound for receiving a message.
/// - notification: A sound for a notification.
/// - offline: A sound for a user that went offline.
/// - online: A sound for a user that went online.
enum Sound: String {
    case messageEditing = "message_editing"
    case message
    case notification
    case offline
    case online
    
    /// The url file path for the audio file of the sound.
    var url: URL? {
        guard let url = Bundle.main.resourceURL else { return nil }
        return url.appendingPathComponent("\(self.rawValue).m4a")
    }
}
