//
//  CheckUsernameResponse.swift
//  M2
//
//  Created by Vincent Friedrich on 29.03.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// A response from the backend for a check username request.
struct CheckUsernameResponse: Codable {
    /// The username that has been checked.
    let username: String
    /// If the username is available.
    let isAvailable: Bool
}
