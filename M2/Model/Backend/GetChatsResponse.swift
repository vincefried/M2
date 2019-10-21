//
//  GetChatsResponse.swift
//  M2
//
//  Created by Vincent Friedrich on 29.03.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// A response from the backend for a get chats request.
struct GetChatsResponse: Codable {
    /// The id of the chat.
    let id: String
    /// The first user of the chat.
    let a: String
    /// The second user of the chat.
    let b: String
}
