//
//  IncomingChangedFriendsRequestsCommand.swift
//  M2
//
//  Created by Vincent Friedrich on 17.07.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// An IncomingStreamable for an incoming friends request change.
struct IncomingChangedFriendsRequestsStreamCommand: IncomingStreamable {
    var type: StreamCommand = .changedFriends
    
    /// The requester of the friends request change.
    let requester: String
    /// The receiver of the friends request change.
    let receiver: String
    /// The reason of the friends request change.
    let changeType: FriendsRequestChangeType
    
    init?(object dict: [String : Any]) {
        // Parse stream content into model.
        guard let requester = dict["requester"] as? String,
            let receiver = dict["receiver"] as? String,
            let changeTypeInt = dict["type"] as? Int,
            let changeType = FriendsRequestChangeType(rawValue: changeTypeInt),
            let cmd = dict["cmd"] as? String,
            let cmdType = StreamCommand(rawValue: cmd),
            cmdType == type else { return nil }
        
        self.requester = requester
        self.receiver = receiver
        self.changeType = changeType
    }
}
