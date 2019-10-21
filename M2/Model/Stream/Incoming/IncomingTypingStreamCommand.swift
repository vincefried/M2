//
//  TypingStreamResponseCommand.swift
//  M2
//
//  Created by Vincent Friedrich on 08.04.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// An IncomingStreamable for an incoming typing.
struct IncomingTypingStreamCommand: IncomingStreamable {
    var type: StreamCommand = .typing
    
    /// The id of the message.
    let messageID: String
    /// The sender of the message.
    let fromUser: String
    /// The receiver of the message.
    let toUser: String
    /// The message as text.
    let message: String
    /// If the message has been cancelled.
    let didCancel: Bool
    
    init?(object dict: [String : Any]) {
        // Parse stream content into model.
        guard let messageID = dict["i"] as? String,
            let message = dict["m"] as? String,
            let fromUser = dict["f"] as? String,
            let toUser = dict["t"] as? String,
            let didCancel = dict["d"] as? Bool,
            let cmd = dict["cmd"] as? String,
            let cmdType = StreamCommand(rawValue: cmd),
            cmdType == type else { return nil }
        
        self.messageID = messageID
        self.fromUser = fromUser
        self.toUser = toUser
        self.message = message
        self.didCancel = didCancel
    }
    
    /// Convert command model into TextMessage model.
    ///
    /// - Returns: The converted TextMessage model.
    func toMessage() -> TextMessage? {
        guard let id = Int(messageID) else { return nil }
        return TextMessage(id: id,
                           sender: fromUser,
                           receiver: toUser,
                           text: message,
                           sentDate: Date().timeIntervalSince1970,
                           isEditing: true,
                           didCancel: didCancel)
    }
}
