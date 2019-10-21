//
//  VoiceMemoCellViewModel.swift
//  M2
//
//  Created by Vincent Friedrich on 01.05.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

/// A delegate for VoiceMemoCellViewModel
protocol VoiceMemoCellViewModelDelegate: class {
    /// Indicates that the UI needs to be updated.
    func updateUINeeded()
    /// Indicates that the UI needs to be relayouted.
    func layoutReloadNeeded()
}

/// A MessageCellViewModel for voice memos.
class VoiceMemoCellViewModel: MessageCellViewModel {
    /// An AudioPlayingWorker instance for playing the voice memo's content.
    private var playingWorker: AudioPlayingWorker?
    
    /// A SpeechRecognitionWorker instance for recognizing text content of the voice memo.
    private lazy var recognizer: SpeechRecognitionWorker? = {
        guard let data = data as? VoiceMemoMessage, let url = data.url else { return nil }
        return SpeechRecognitionWorker(fileURL: url)
    }()
    
    /// The CellState for recognition animation.
    ///
    /// - memoOnly: Only the voice memo gets displayed with the ability to show text.
    /// - loadingText: The text is currently loading and a spinner is shown.
    /// - memoAndText: The memo and the text are shown. The user can also hide the text.
    /// - disabled: The whole cell is disabled because the memo is still downloading.
    enum CellState {
        case memoOnly, loadingText, memoAndText, disabled
    }
    
    /// The CellState for recognition animation.
    var cellState: CellState = .memoOnly {
        didSet {
            XCGLogger.default.debug("cellstate \(cellState)")
            // Indicate that the UI needs to be updated
            delegate?.updateUINeeded()
            // Indicate that the UI needs to be relayted because of an added or hidden text view
            delegate?.layoutReloadNeeded()
        }
    }
    
    /// A delegate for VoiceMemoCellViewModel
    weak var delegate: VoiceMemoCellViewModelDelegate?
    
    /// The image name of the play button.
    var playButtonImageName: String {
        return playingWorker?.isPlaying ?? false ? "pause" : "play"
    }
    
    /// The button title of the show text button.
    var showTextButtonTitle: String {
        return cellState == .memoAndText ? "    Text verstecken    " : "    Text zeigen    "
    }
    
    /// If the show text button should be available.
    var showsTextButton: Bool {
        return playingWorker?.duration.toUnit(.second) ?? 0 < 60
    }
    
    /// If a hairline should be shown between memo and text.
    var showsHairline: Bool {
        return cellState != .memoOnly && cellState != .disabled
    }
    
    /// If the textcontent should be shown.
    var showsTextContent: Bool {
        return cellState == .memoAndText
    }
    
    /// If an activity indicator should be shown.
    var showsActivityIndicator: Bool {
        return cellState == .loadingText
    }
    
    /// If the play button should be enabled.
    var isPlayButtonEnabled: Bool {
        return cellState != .disabled
    }
    
    /// If the show text button should be enabled.
    var isShowTextButtonEnabled: Bool {
        return cellState != .disabled
    }
    
    /// If the slider should be hidden.
    var isSliderHidden: Bool {
        return cellState == .disabled
    }
    
    /// The text content of the voice memo.
    var textContent: String?
    
    /// The minimum duration of the slider.
    var sliderDurationMinimum: Float = 0
    /// The maximum duration of the slider.
    var sliderDurationMaximum: Float = 0
    /// The current value of the duration slider progress.
    var sliderCurrentValue: Float = 0
    
    required init(data: VoiceMemoMessage) {
        // Initialize cell type with receiver
        var cellType: MessageCellType = .receiver
        
        // Change celltype to sender if sender or to editing if editing
        if data.sender == BackendWorker.shared.currentUser?.username {
            cellType = .sender
        } else if data.isEditing {
            cellType = .editing
        }
        
        super.init(cellType: cellType, data: data)
        
        guard let url = data.url else { return }
        
        // If the voice memo audio file was downloaded correctly, switch state to .memoOnly,
        // otherwise to .disabled and try to redownload it
        if FileManager.default.fileExists(atPath: url.path) {
            cellState = .memoOnly
            playingWorker = AudioPlayingWorker(url: url)
        } else {
            cellState = .disabled
            data.downloadMemo { [weak self] success in
                if success {
                    self?.cellState = .memoOnly
                    self?.playingWorker = AudioPlayingWorker(url: url)
                } else {
                    self?.cellState = .disabled
                }
            }
        }
    }
    
    /// Handles a tap on the play button
    func handlePlayButtonTapped() {
        guard let data = data as? VoiceMemoMessage, let url = data.url else { return }
        
        // Pause the voice memo if it is currently playing, otherwise play the memo
        if playingWorker?.isPlaying ?? false {
            playingWorker?.pause()
        } else {
            if let oldURL = playingWorker?.url {
                if url != oldURL {
                    playingWorker = AudioPlayingWorker(url: url)
                }
            }
            playingWorker?.delegate = self
            playingWorker?.play()
        }
    }
    
    /// Handles a tap on the show text button
    func handleShowTextButtonTapped() {
        guard let recognizer = recognizer else { return }
        
        // Reset cell state to .memoOnly if it is already collapsed, otherwise load and show text
        if cellState != .memoOnly {
            cellState = .memoOnly
        } else {
            cellState = .loadingText
            
            // Check for recognizer authorization and if no authorization, ask for it and recognize text
            guard recognizer.isAuthorized else {
                recognizer.authorize { [weak self] status in
                    if status == .authorized {
                        DispatchQueue.main.async {
                            self?.handleRecognition()
                        }
                    }
                }
                return
            }
            
            // Recognize text
            handleRecognition()
        }        
    }
    
    /// Recignizes the text content of the voice memo.
    private func handleRecognition() {
        guard let recognizer = recognizer, !recognizer.isRecognizing else { return }
        // Recognize text content
        // If success update text content with latest transcription
        // If faliure reset cell state
        //
        // There is no need to indicate that the UI needs to be updated, because the
        // cell state gets set everytime, and it already triggers a UI update
        recognizer.recognize { [weak self] result in
            switch result {
            case .success(let transcription):
                self?.textContent = transcription
                self?.cellState = .memoAndText
            case .failure(let error):
                self?.cellState = .memoOnly
                XCGLogger.default.error("Error recognizing memo \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - AudioPlayingWorkerDelegate
extension VoiceMemoCellViewModel: AudioPlayingWorkerDelegate {
    func durationChanged(current: TimeInterval, min: TimeInterval, max: TimeInterval) {
        // Update duration values for slider
        sliderDurationMinimum = Float(min)
        sliderDurationMaximum = Float(max)
        sliderCurrentValue = Float(current)
        
        // Indicate that the UI needs to be updated
        delegate?.updateUINeeded()
    }
    
    func playStateChanged(isPlaying: Bool) {
        // Indicate that the UI needs to be updated
        delegate?.updateUINeeded()
    }
}

// MARK: - Equatable
extension VoiceMemoCellViewModel: Equatable {
    static func == (lhs: VoiceMemoCellViewModel, rhs: VoiceMemoCellViewModel) -> Bool {
        return lhs.data == rhs.data
    }
}
