//
//  MessagesListViewModel.swift
//  M2
//
//  Created by Vincent Friedrich on 23.02.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation
import UIKit

/// A delegate for the MessagesListViewModel.
protocol MessagesListViewModelDelegate: class {
    /// Indicates that the UI needs to be updated.
    func updateUINeeded()
}

/// A ListViewModel for the MessagesViewController.
class MessagesListViewModel: ListViewModel<Message, MessageCellViewModel> {
    /// Private var for the ViewModel data for change observing implementation.
    private var _data: [MessageCellViewModel] = []
    
    /// The ViewModel data. Always gets returned in reversed order because of the MessagesViewController UITableView reversed implementation.
    override var data: [MessageCellViewModel] {
        get {
            return _data.reversed()
        }
        
        set {
            _data = newValue
        }
    }
        
    /// An AudioPlayingWorker instance for playing a sound when the user received a message.
    let messageAudioPlayingWorker = AudioPlayingWorker(sound: .message)
    /// An AudioPlayingWorker instance for playing a sound when the user received a new typed letter in a message.
    let messageEditingAudioPlayingWorker = AudioPlayingWorker(sound: .messageEditing)
    /// An AudioPlayingWorker instance for playing a sound when the user goes online.
    let onlineAudioPlayingWorker = AudioPlayingWorker(sound: .online)
    /// An AudioPlayingWorker instance for playing a sound when the user goes offline.
    let offlineAudioPlayingWorker = AudioPlayingWorker(sound: .offline)
    
    /// An AudioRecordingWOrker instance for recording audio for the voice memos.
    var recordingWorker: AudioRecordingWorker?
    
    /// The number of maximum lines of the messages text view.
    let messagesTextFieldMaxLines: Int = 4
    
    /// The title of the ViewController.
    let title: String
    
    /// A temp variable for saving the old number of lines before updating the View.
    var oldNumberOfLines: Int = 0
    
    /// If the toolbar with the messages text view and all buttons is hidden.
    var isToolbarHidden: Bool {
        return !messagesProvider.chat.isComplete
    }
    
    /// If the messages list needs to be scrolled to the bottom.
    var needsBottomScroll: Bool {
        guard let message = messagesProvider.messages.last as? TextMessage else { return false }
        return message.isEditing && message.text.count == 1
    }
    
    /// If the other user is online.
    var isOnline: Bool {
        return messagesProvider.chat.otherUserIsActive
    }
    
    /// If the ViewController's UITableView for displaying the messages should be reversed.
    var reverseTableView: Bool {
        return !messagesProvider.messages.isEmpty
    }
    
    /// If a placeholder should be shown if the other chat partner is missing.
    var showsOtherMissingPlaceholder: Bool {
        return !messagesProvider.chat.isComplete
    }
    
    /// The image for the missing placeholder.
    var emptyDataSetImage: UIImage? {
        return messagesProvider.chat.isComplete ? UIImage(named: "chat") : UIImage(named: "sleep")
    }
    
    /// The description for the missing placeholder.
    var emptyDataSetDescription: NSAttributedString {
        let rawString = isOnline ? "Noch keine Nachrichten" : "\(messagesProvider.chat.otherUser) ist nicht im Chat"
        let string = NSMutableAttributedString(string: rawString, attributes: [NSAttributedString.Key.font : UIFont(name: "Futura", size: 16)!])
        return string
    }
    
    /// A delegate for the MessagesListViewModel.
    weak var delegate: MessagesListViewModelDelegate?
    
    private let messagesProvider: MessagesProvider
    
    init(messagesProvider: MessagesProvider) {
        self.messagesProvider = messagesProvider
        self.title = messagesProvider.chat.otherUser
        
        super.init(provider: messagesProvider)
        
        self.messagesProvider.delegate = self
    }

    /// Starts the chat.
    ///
    /// - Parameter completion: Called on async call completion with success.
    func handleStartedChat(completion: @escaping (Bool) -> Void) {
        messagesProvider.chat.startChat(completion: completion)
    }
    
    /// Leaves the chat.
    ///
    /// - Parameter completion: Called on async call completion with success.
    func handleLeftChat(completion: @escaping (Bool) -> Void) {
        messagesProvider.chat.leaveChat(completion: completion)
    }
    
    /// Checks if the chat is complete.
    ///
    /// - Parameter completion: Called on async call completion with if chat is complete.
    func checkIfChatComplete(_ completion: ((Bool) -> Void)? = nil) {
        messagesProvider.chat.checkIfIsComplete { [weak self] complete in
            completion?(complete)
            // Indicate that the UI needs to be updated
            self?.delegate?.updateUINeeded()
        }
    }
    
    /// Handles a typed letter of the messages text view.
    ///
    /// - Parameter text: The text content of the messages text view.
    func handleTyping(with text: String) {
        messagesProvider.typeMessage(text: text)
    }
    
    /// Handles a tap on the send button.
    ///
    /// - Parameter text: The text content of the messages text view.
    func handleSendButtonTapped(with text: String) {
        // Trim the text to remove leading or trailing whitespaces or new lines
        let trimmedText = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        // Stop if the trimmed text is empty
        guard !trimmedText.isEmpty else { return }
        // Send message with trimmed text
        messagesProvider.sendMessage(text: trimmedText)
    }
    
    /// Handles a touch down (user holds record button) of the record button.
    func handleRecordButtonTouchDown() {
        // Get a reference date to create a unique recording id
        guard let referenceDate = "01.01.2019".toDate()?.date else { return }
        // Initialize the AudioPlayingWorker with the id
        recordingWorker = AudioRecordingWorker(id: Int(Date().timeIntervalSince(referenceDate)))
        // Start the recording
        recordingWorker?.record()
    }
    
    /// Handles a touch up (user releases record button) of the record button.
    func handleRecordButtonTouchUp() {
        // Stop the recording worker and get its response
        guard let response = recordingWorker?.stop() else { return }
        // Send the voice memo with the file url
        messagesProvider.sendVoiceMemo(id: response.id, fileUrl: response.fileURL)
    }
    
    /// Maps the messages model data to instances of TextMessageCellViewModel or VoiceMemoCellViewModel.
    private func mapData() {
        _data = messagesProvider.messages.map({ message -> MessageCellViewModel in
            switch message {
            case let textMessage as TextMessage:
                return TextMessageCellViewModel(data: textMessage)
            case let voiceMessage as VoiceMemoMessage:
                return VoiceMemoCellViewModel(data: voiceMessage)
            default:
                fatalError()
            }
        })
    }
}

// MARK: - MessagesProviderDelegate
extension MessagesListViewModel: MessagesProviderDelegate {
    func didAppend(message: Message) {
        // Map the new state of data to ViewModels
        mapData()
        
        // Play a matching message sound
        if message.isEditing  {
            messageEditingAudioPlayingWorker?.play()
        } else {
            messageAudioPlayingWorker?.play()
        }
        
        // Indicate that the UI needs to be updated
        delegate?.updateUINeeded()
    }
    
    func didUpdate(message: Message, at index: Int) {
        // Map the new state of data to ViewModels
        mapData()
        
        // Play a send sound if the message finished editing
        if !message.isEditing  {
            messageAudioPlayingWorker?.play()
        }
        
        // Indicate that the UI needs to be updated
        delegate?.updateUINeeded()
    }
    
    func didRemove(message: Message, at index: Int) {
        // Map the new state of data to ViewModels
        mapData()
        // Indicate that the UI needs to be updated
        delegate?.updateUINeeded()
    }
    
    func didChangeActiveStatus(username: String) {
        // Check if the chat is complete
        checkIfChatComplete { [weak self] _ in
            // If chat is complete, play online sound, otherwise play offline sound
            if self?.messagesProvider.chat.otherUserIsActive ?? false {
                self?.onlineAudioPlayingWorker?.play()
            } else {
                self?.offlineAudioPlayingWorker?.play()
            }
        }
        // Indicate that the UI needs to be updated
        delegate?.updateUINeeded()
    }
}
