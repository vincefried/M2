//
//  SpeechRecognitionWorker.swift
//  M2
//
//  Created by Vincent Friedrich on 24.05.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation
import Speech

/// A worker class for recognizing text in a given audio file.
class SpeechRecognitionWorker: NSObject {
    /// An instance of the SFSpeechRecognizer for recognizing text in a given audio file.
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "de-DE"))
    /// The file url of the audio file to be recognized.
    private let fileURL: URL
        
    /// If the SFSpeechRecognizer is authorized.
    var isAuthorized: Bool {
        return SFSpeechRecognizer.authorizationStatus() == .authorized
    }
    
    /// If the SFSpeechRecognizer is currently recognizing.
    var isRecognizing: Bool = false
    
    init(fileURL: URL) {
        self.fileURL = fileURL
    }
    
    /// Requests authorization to recognize text.
    ///
    /// - Parameter completion: If the authorization was granted.
    func authorize(_ completion: ((SFSpeechRecognizerAuthorizationStatus) -> Void)? = nil) {
        SFSpeechRecognizer.requestAuthorization { completion?($0) }
    }
    
    /// Recognizes text in the audio file at the file url that the SpeechRecognitionWorker was initializes with.
    ///
    /// - Parameter completion: When the recognizer completed a new text section of the audio file.
    func recognize(_ completion: @escaping (Result<String, Error>) -> Void) {
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            XCGLogger.default.warning("Not authorized")
            return
        }
        
        isRecognizing = true
        
        let request = SFSpeechURLRecognitionRequest(url: fileURL)
        recognizer?.recognitionTask(with: request, resultHandler: { [weak self] result, error in
            if let result = result {
                completion(.success(result.bestTranscription.formattedString))
            } else if let error = error {
                completion(.failure(error))
            }
            
            self?.isRecognizing = false
        })
    }
}
