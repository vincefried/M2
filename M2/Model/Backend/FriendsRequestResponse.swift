//
//  FriendsRequestResponse.swift
//  M2
//
//  Created by Vincent Friedrich on 29.03.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation
import DifferenceKit

/// A response from the backend for a friends request request.
struct FriendsRequestResponse: Codable, Equatable {
    /// The state of the friends request.
    ///
    /// - unanswered: The friends request has not yet been answered.
    /// - accepted: The friends request has been accepted.
    /// - declined: The friends request has been declined.
    enum FriendsRequestState: Int, Codable {
        case unanswered = 0
        case accepted = 1
        case declined = 2
    }
    
    /// The coding keys for the parser.
    ///
    /// - id: The id of the friends request.
    /// - requester: The requester of the friends request.
    /// - receiver: The receiver of the friends request.
    /// - dateCreated: The date that the friends request was created.
    /// - state: The state of the friends request.
    private enum CodingKeys : String, CodingKey {
        case id
        case requester
        case receiver
        case dateCreated = "date_created"
        case state
    }
    
    /// The id of the friends request.
    let id: Int
    /// The requester of the friends request.
    let requester: String
    /// The receiver of the friends request.
    let receiver: String
    /// The date that the friends request was created.
    let dateCreated: TimeInterval
    /// The state of the friends request.
    let state: FriendsRequestState
}

extension FriendsRequestResponse: Differentiable {
    // Implementation for DifferenceKit
    
    var differenceIdentifier: Int {
        return self.id
    }
    
    func isContentEqual(to source: FriendsRequestResponse) -> Bool {
        return self.id == source.id && self.state == source.state
    }
}
