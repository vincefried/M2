//
//  FriendsRequestChangeType.swift
//  M2
//
//  Created by Vincent Friedrich on 18.07.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// Indicates the reason why a friends request changed in the backend.
///
/// - accepted: Because the request was accepted.
/// - declined: Because the request was declined.
/// - sent: Because the request was sent.
/// - deleted: Because the request was deleted.
enum FriendsRequestChangeType: Int {
    case accepted = 0
    case declined = 1
    case sent = 2
    case deleted = 3
}
