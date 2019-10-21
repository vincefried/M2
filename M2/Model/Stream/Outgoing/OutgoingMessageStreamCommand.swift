//
//  MessageStreamCommand.swift
//  M2
//
//  Created by Vincent Friedrich on 27.03.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// An OutgoingStreamable for an outgoing message.
struct OutgoingMessageStreamCommand: OutgoingStreamable {
    var type: StreamCommand = .message
    
    var representation: [String : Any]
        
    init(message: TextMessage) {
        self.representation = [
            "cmd" : self.type.rawValue,
            "message" : message.text,
            "from_user" : message.sender,
            "to_user" : message.receiver,
            "messageID" : String(message.id),
            "sentDate" : String(message.sentDate)
        ]
    }
}
