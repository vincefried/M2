//
//  VoiceMemoMessage.swift
//  M2
//
//  Created by Vincent Friedrich on 01.05.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// A model subclass of Message for a voice message.
class VoiceMemoMessage: Message {
    /// The url to the audio file of the voice message.
    var url: URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documentsDirectory.appendingPathComponent("\(String(id)).m4a")
    }
    
    /// Downloads the audio file of the voice memo from the backend.
    ///
    /// - Parameter completion: If the download completed with success.
    func downloadMemo(completion: @escaping (Bool) -> Void) {
        // Check if file doesn't already exist and if the correct user invoked the download
        guard let path = url?.absoluteString,
            !FileManager.default.fileExists(atPath: path),
            let currentUser = BackendWorker.shared.currentUser,
            sender != currentUser.username else { return }
        
        // Download the audio file
        let request = VoiceMemoEndpoint.downloadMemo(id: String(id))
        BackendWorker.shared.download(request, filename: "\(id).m4a") { result in
            guard let data = try? result.get() else {
                completion(false)
                return
            }
            completion(true)
            XCGLogger.default.debug("download completed: \(data)")
        }
    }
}
