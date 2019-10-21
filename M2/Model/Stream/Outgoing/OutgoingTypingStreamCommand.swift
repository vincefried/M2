//
//  TypingStreamCommand.swift
//  M2
//
//  Created by Vincent Friedrich on 08.04.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// An OutgoingStreamable for an outgoing typing message.
struct OutgoingTypingStreamCommand: OutgoingStreamable {
    var type: StreamCommand = .typing
    
    var representation: [String : Any]
    
    init(message: TextMessage) {
        self.representation = [
            "cmd" : self.type.rawValue,
            "f" : message.sender,
            "t" : message.receiver,
            "m" : message.text,
            "i" : String(message.id),
            "d" : message.didCancel
        ]
    }
}
