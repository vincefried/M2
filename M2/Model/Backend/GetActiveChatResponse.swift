//
//  GetActiveChatResponse.swift
//  M2
//
//  Created by Vincent Friedrich on 14.07.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// A response from the backend for a get active chat request.
struct GetActiveChatResponse: Codable {
    /// The coding keys for the parser.
    ///
    /// - activeChat: The active chat of the requested user.
    enum CodingKeys: String, CodingKey {
        case activeChat = "active_chat"
    }
    
    /// The active chat of the requested user.
    var activeChat: String?
}
