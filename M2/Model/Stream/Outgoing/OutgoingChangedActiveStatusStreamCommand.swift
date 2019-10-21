//
//  OutgoingChangedActiveStatusStreamCommand.swift
//  M2
//
//  Created by Vincent Friedrich on 14.07.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// An OutgoingStreamable for an outgoing active status change.
struct OutgoingChangedActiveStatusStreamCommand: OutgoingStreamable {
    var type: StreamCommand = .changedActive
    
    var representation: [String : Any]
    
    init(requester: String, receiver: String, isOnline: Bool) {
        self.representation = [
            "cmd" : self.type.rawValue,
            "requester" : requester,
            "receiver" : receiver,
            "is_online" : isOnline
        ]
    }
}
