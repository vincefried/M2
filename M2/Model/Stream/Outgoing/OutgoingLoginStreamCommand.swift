//
//  LoginStreamCommand.swift
//  M2
//
//  Created by Vincent Friedrich on 27.03.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// An OutgoingStreamable for an outgoing login command.
struct OutgoingLoginStreamCommand: OutgoingStreamable {
    var type: StreamCommand = .login
    
    var representation: [String : Any]
    
    init(user: User) {
        self.representation = [
            "cmd" : self.type.rawValue,
            "username" : user.username
        ]
    }
}
