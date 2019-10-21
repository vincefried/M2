//
//  LoginResponse.swift
//  M2
//
//  Created by Vincent Friedrich on 29.03.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// A response from the backend for a login request.
struct LoginResponse: Codable {
    /// The id of the logged in user.
    let id: String
    /// The username of the logged in user.
    let username: String
}
