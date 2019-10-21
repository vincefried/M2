//
//  MessageStreamResponse.swift
//  M2
//
//  Created by Vincent Friedrich on 30.03.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// An IncomingStreamable for an incoming message.
struct IncomingMessageStreamCommand: IncomingStreamable {
    var type: StreamCommand = .message
    
    /// The id of the message.
    let messageID: String
    /// The sender of the message.
    let fromUser: String
    /// The receiver of the message.
    let toUser: String
    /// The message as text.
    let message: String
    /// The timestamp when the message was sent.
    let sentDate: String
    
    init?(object dict: [String : Any]) {
        // Parse stream content into model.
        guard let messageID = dict["messageID"] as? String,
            let message = dict["message"] as? String,
            let fromUser = dict["from_user"] as? String,
            let toUser = dict["to_user"] as? String,
            let sentDate = dict["sentDate"] as? String,
            let cmd = dict["cmd"] as? String,
            let cmdType = StreamCommand(rawValue: cmd),
            cmdType == type else { return nil }
        
        self.messageID = messageID
        self.fromUser = fromUser
        self.toUser = toUser
        self.message = message
        self.sentDate = sentDate
    }
    
    /// Convert command model into TextMessage model.
    ///
    /// - Returns: The converted TextMessage model.
    func toMessage() -> TextMessage? {
        guard let id = Int(messageID),
            let sentDateInterval = TimeInterval(sentDate) else { return nil }
        return TextMessage(id: id,
                           sender: fromUser,
                           receiver: toUser,
                           text: message,
                           sentDate: sentDateInterval,
                           isEditing: false,
                           didCancel: false)
    }
}
