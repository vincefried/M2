//
//  OutgoingChangedFriendsRequestsCommand.swift
//  M2
//
//  Created by Vincent Friedrich on 17.07.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// An OutgoingStreamable for an outgoing friends requests change.
struct OutgoingChangedFriendsRequestsStreamCommand: OutgoingStreamable {
    var type: StreamCommand = .changedFriends
    
    var representation: [String : Any]
    
    init(requester: String, receiver: String, changeType: FriendsRequestChangeType) {
        self.representation = [
            "cmd" : self.type.rawValue,
            "requester" : requester,
            "receiver" : receiver,
            "type" : changeType.rawValue
        ]
    }
}
