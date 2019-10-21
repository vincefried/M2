//
//  User.swift
//  M2
//
//  Created by Vincent Friedrich on 26.03.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// A model struct for a user.
struct User: Equatable {
    /// The id of the user.
    var id: UUID
    /// The username of the user.
    let username: String
    /// The password of the user.
    let password: String
    
    /// The device token of the user.
    /// Used for receiving push notifications.
    var deviceToken: String? {
        set {
            PersistanceWorker.deviceToken = newValue
        }
        
        get {
            return PersistanceWorker.deviceToken
        }
    }
    
    init(id: UUID, username: String, password: String) {
        self.id = id
        self.username = username
        self.password = password
    }
}
