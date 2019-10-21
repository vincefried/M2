//
//  IncomingChangedActiveStatusStreamCommand.swift
//  M2
//
//  Created by Vincent Friedrich on 14.07.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// An IncomingStreamable for an incoming change of the active status message.
struct IncomingChangedActiveStatusStreamCommand: IncomingStreamable {
    var type: StreamCommand = .changedActive
    
    /// The requester of the active status change.
    let requester: String
    /// The receiver of the active status change.
    let receiver: String
    /// If the new status is online or offline.
    let isOnline: Bool
    
    init?(object dict: [String : Any]) {
        // Parse stream content into model.
        guard let requester = dict["requester"] as? String,
            let receiver = dict["receiver"] as? String,
            let isOnline = dict["is_online"] as? Bool,
            let cmd = dict["cmd"] as? String,
            let cmdType = StreamCommand(rawValue: cmd),
            cmdType == type else { return nil }
        
        self.requester = requester
        self.receiver = receiver
        self.isOnline = isOnline
    }
}
