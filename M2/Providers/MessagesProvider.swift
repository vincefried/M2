//
//  MessageWorker.swift
//  M2
//
//  Created by Vincent Friedrich on 17.02.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation
import SwiftDate

/// A delegate for the MessagesProvider.
protocol MessagesProviderDelegate: class {
    /// Gets called before a message gets appended to the list of messages.
    ///
    /// - Parameter message: The message that is about to be appended.
    func willAppend(message: Message)
    /// Gets called after a message got appended to the list of messages.
    ///
    /// - Parameter message: The message that got appended.
    func didAppend(message: Message)
    
    /// Gets called before a message gets updated in the list of messages.
    ///
    /// - Parameters:
    ///   - message: The message that is about to be updated.
    ///   - index: The index at which the message is about to be updated at.
    func willUpdate(message: Message, at index: Int)
    /// Gets called after a message got updated in the list of messages.
    ///
    /// - Parameters:
    ///   - message: The message that got updated.
    ///   - index: The index at which the message got updated.
    func didUpdate(message: Message, at index: Int)
    
    /// Gets called before a message gets removed from the list of messages.
    ///
    /// - Parameters:
    ///   - message: The message that is about to be removed.
    ///   - index: The index at which the message is about to be removed at.
    func willRemove(message: Message, at index: Int)
    /// Gets called after a message got removed from the list of messages.
    ///
    /// - Parameters:
    ///   - message: The message that got removed.
    ///   - index: The index at which the message got removed at.
    func didRemove(message: Message, at index: Int)
    
    /// Gets called if the active status changed.
    ///
    /// - Parameter username: The username of the user that changed the active status.
    func didChangeActiveStatus(username: String)
}

extension MessagesProviderDelegate {
    // Boilerplate implementation of MessagesProviderDelegate
    
    func willAppend(message: Message) { }
    func didAppend(message: Message) { }
    
    func willUpdate(message: Message, at index: Int) { }
    func didUpdate(message: Message, at index: Int) { }
    
    func willRemove(message: Message, at index: Int) { }
    func didRemove(message: Message, at index: Int) { }
    
    func didChangeActiveStatus(username: String) { }
}

/// An observable provider class, containting a list of instances of Message models.
class MessagesProvider: Observable {
    
    /// Private var to allow sorted implementation of public list.
    /// Notifies observers for a change.
    var _messages: [Message] = [] {
        didSet {
            notifyObservers()
        }
    }
    
    /// The list of instances of Message models.
    /// Gets returned sorted in alphabetic order.
    var messages: [Message] {
        set {
            _messages = newValue
        }
        
        get {
            return _messages.sorted { $0.sentDate < $1.sentDate }
        }
    }
    
    /// A delegate for the MessagesProvider.
    weak var delegate: MessagesProviderDelegate?
    
    /// The message that is currently in the state of typing before being sent.
    var currentMessage: Message?
    
    /// An instane of a feedback generator to generate haptic feedback.
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    /// The current chat that the messages are sent to and from.
    let chat: Chat
    
    init(chat: Chat) {
        self.chat = chat
        
        super.init()
        
        // Bind the StreamWorker to the MessagesProvider
        StreamWorker.shared.unbind(observer: self)
        StreamWorker.shared.bind(delegate: self, observer: self)
    }
    
    deinit {
        StreamWorker.shared.unbind(observer: self)
    }
    
    /// Cleans the list of messages for messages that are in editing or cancelled state.
    func cleanMessages() {
        for (index, message) in messages.enumerated() {
            if message.isEditing || message.didCancel {
                remove(message: message, at: index)
            }
        }
    }
    
    /// Sends a typed part of a given text to the chat.
    ///
    /// - Parameter text: The typing text.
    func typeMessage(text: String) {
        // Check that text is not empty or current message is not nil
        guard !text.isEmpty || currentMessage != nil else { return }

        // If a message is currently editing, set new text for that message
        // Otherwise, create a new current message with the given text
        if let currentMessage = currentMessage as? TextMessage {
            currentMessage.text = text
            currentMessage.sentDate = Date().timeIntervalSince1970

            // Cancel current message if new text is empty, otherwise update current message
            if currentMessage.text.isEmpty {
                currentMessage.didCancel = true
                let typingCommand = OutgoingTypingStreamCommand(message: currentMessage)
                StreamWorker.shared.send(streamable: typingCommand)
                
                self.currentMessage = nil
                return
            } else {
                self.currentMessage = currentMessage
            }
        } else {
            currentMessage = TextMessage(id: messages.count,
                                         sender: chat.thisUser,
                                         receiver: chat.otherUser,
                                         text: text,
                                         sentDate: Date().timeIntervalSince1970,
                                         isEditing: true,
                                         didCancel: false)
        }
        
        // Send typing command to StreamWorker
        if let message = currentMessage as? TextMessage {
            let typingCommand = OutgoingTypingStreamCommand(message: message)
            StreamWorker.shared.send(streamable: typingCommand)
        }
    }
    
    /// Sends a message that has finished typing to the chat.
    ///
    /// - Parameter text: The finished text.
    func sendMessage(text: String) {
        XCGLogger.default.debug(text)
        // Initialize new text message
        let id = currentMessage?.id ?? messages.count
        let message = TextMessage(id: id,
                                  sender: chat.thisUser,
                                  receiver: chat.otherUser,
                                  text: text,
                                  sentDate: Date().timeIntervalSince1970,
                                  isEditing: false,
                                  didCancel: false)
        
        // Append text message to list of messages
        append(message: message)
        
        // Reset current message
        currentMessage = nil
        
        // Trigger haptic feedback
        feedbackGenerator.impactOccurred()
        
        // Send message command to StreamWorker
        let messageCommand = OutgoingMessageStreamCommand(message: message)
        StreamWorker.shared.send(streamable: messageCommand)
    }
    
    /// Sends a voice memo to the chat.
    ///
    /// - Parameters:
    ///   - id: The id of the voice memo message.
    ///   - fileUrl: The file url to the audio file of the voice memo.
    func sendVoiceMemo(id: Int, fileUrl: URL) {
        // Get data from the audio file
        guard let data = try? Data(contentsOf: fileUrl) else { return }
        
        let fileName = fileUrl.lastPathComponent
        let mimeType = "audio/x-m4a"
        
        // Upload memo to the backend
        let uploadRequest = VoiceMemoEndpoint.uploadMemo(id: String(id), owner: chat.thisUser)
        
        // Initialize new voice memo message
        let message = VoiceMemoMessage(id: id,
                                       sender: chat.thisUser,
                                       receiver: chat.otherUser,
                                       sentDate: Date().timeIntervalSince1970,
                                       isEditing: false,
                                       didCancel: false)
        
        // Append voice memo message to the list of messages
        append(message: message)
        
        // Trigger haptic feedback
        feedbackGenerator.impactOccurred()
        
        // Send upload request to the backend using the BackendWorker
        BackendWorker.shared.upload(endpoint: uploadRequest, fileName: fileName, mimeType: mimeType, data: data, progressClosure: { progress in
            XCGLogger.default.debug("Upload progress \(progress.fractionCompleted)")
        }) { result in
            if case .success(()) = result {
                XCGLogger.default.debug("SUCCESS uploading")
                // Send voice memo message command to the StreamWorker if upload finished successfully
                let messageCommand = OutgoingVoiceMemoStreamCommand(message: message)
                StreamWorker.shared.send(streamable: messageCommand)
            }
        }
    }
    
    /// Appends a message to the list of messages and triggers the delegate calls.
    ///
    /// - Parameter message: The message to be appended.
    private func append(message: Message) {
        delegate?.willAppend(message: message)
        messages.append(message)
        delegate?.didAppend(message: message)
    }
    
    /// Updates a message in the list of messages at a given index and triggers the delegate calls.
    ///
    /// - Parameters:
    ///   - message: The message to be updated.
    ///   - index: The index at which the message should be updated.
    private func update(message: Message, at index: Int) {
        delegate?.willUpdate(message: message, at: index)
        messages[index] = message
        delegate?.didUpdate(message: message, at: index)
    }
    
    /// Removes a message from the list of messages at a given index and triggers the delegate calls.
    ///
    /// - Parameters:
    ///   - message: The message to be removed.
    ///   - index: The index at which the message should be removed at.
    private func remove(message: Message, at index: Int) {
        delegate?.willRemove(message: message, at: index)
        messages.remove(at: index)
        delegate?.didRemove(message: message, at: index)
    }
}

// MARK: - StreamWorkerDelegate
extension MessagesProvider: StreamWorkerDelegate {
    func streamDidReceive(message: Message) {
        // If message was found in list of messages, update message or if it got cancelled, remove message
        // Otherwise append message to the list of messages
        if let messageIndex = messages.firstIndex(where: { $0.id == message.id }) {
            if message.didCancel {
                // Remove message
                remove(message: message, at: messageIndex)
                // Clean messages if message got cancelled
                cleanMessages()
            } else {
                // Trigger haptic feedback
                feedbackGenerator.impactOccurred()
                // Update message
                update(message: message, at: messageIndex)
            }
        } else {
            // Clean messages with left editing messages to be sure before adding a new one
            cleanMessages()
            // Trigger haptic feedback
            feedbackGenerator.impactOccurred()
            // Append message
            append(message: message)
        }
    }
    
    func streamDidReceiveChangedActiveStatus(username: String) {
        // Trigger delegate for active status change
        if username == chat.otherUser {
            delegate?.didChangeActiveStatus(username: username)
        }
    }
}
