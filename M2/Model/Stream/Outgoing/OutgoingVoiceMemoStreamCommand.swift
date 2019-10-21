//
//  OutgoingVoiceMemoStreamCommand.swift
//  M2
//
//  Created by Vincent Friedrich on 01.05.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// An OutgoingStreamable for an outgoing voice memo message.
struct OutgoingVoiceMemoStreamCommand: OutgoingStreamable {
    var type: StreamCommand = .voicememo
    
    var representation: [String : Any]
    
    init(message: VoiceMemoMessage) {
        self.representation = [
            "cmd" : self.type.rawValue,
            "from_user" : message.sender,
            "to_user" : message.receiver,
            "messageID" : String(message.id),
            "sentDate" : String(message.sentDate)
        ]
    }
}
