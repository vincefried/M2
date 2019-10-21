//
//  GetMemoResponse.swift
//  M2
//
//  Created by Vincent Friedrich on 07.05.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// A response from the backend for a get memo request.
struct GetMemoResponse: Codable {
    /// The coding keys for the parser.
    ///
    /// - messageId: The id of the memo message.
    /// - owner: The owner of the memo audio file.
    /// - filename: The name of the memo audio file.
    enum CodingKeys: String, CodingKey {
        case messageId = "message_id"
        case owner
        case filename
    }
    
    /// The id of the memo message.
    let messageId: String
    /// The owner of the memo audio file.
    let owner: String
    /// The name of the memo audio file.
    let filename: String
}
