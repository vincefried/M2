//
//  IncomingVoiceMemoStreamCommand.swift
//  M2
//
//  Created by Vincent Friedrich on 13.05.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// An IncomingStreamable for an incoming voice message.
struct IncomingVoiceMessageStreamCommand: IncomingStreamable {
    var type: StreamCommand = .voicememo
    
    /// The id of the voice message.
    let messageID: String
    /// The sender of the voice message.
    let fromUser: String
    /// The receiver of the voice message.
    let toUser: String
    /// The timestamp when the message was sent.
    let sentDate: String
    
    init?(object dict: [String : Any]) {
        // Parse stream content into model.
        guard let messageID = dict["messageID"] as? String,
            let fromUser = dict["from_user"] as? String,
            let toUser = dict["to_user"] as? String,
            let sentDate = dict["sentDate"] as? String,
            let cmd = dict["cmd"] as? String,
            let cmdType = StreamCommand(rawValue: cmd),
            cmdType == type else { return nil }
        
        self.messageID = messageID
        self.fromUser = fromUser
        self.toUser = toUser
        self.sentDate = sentDate
    }
    
    /// Convert command model into VoiceMemoMessage model.
    ///
    /// - Returns: The converted VoiceMemoMessage model.
    func toMessage() -> VoiceMemoMessage? {
        guard let id = Int(messageID),
            let sentDateInterval = TimeInterval(sentDate) else { return nil }
        return VoiceMemoMessage(id: id,
                                sender: fromUser,
                                receiver: toUser,
                                sentDate: sentDateInterval,
                                isEditing: false,
                                didCancel: false)
    }
}
