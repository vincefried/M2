//
//  Message.swift
//  M2
//
//  Created by Vincent Friedrich on 23.02.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// A model calls for a message.
class Message {
    /// The id of the message.
    var id: Int
    /// The timestamp at which the message was sent.
    var sentDate: TimeInterval
    /// The sender of the message.
    var sender: String
    /// The receiver of the message.
    var receiver: String
    /// If the message is editing (typing).
    var isEditing: Bool
    /// If the message was cancelled.
    var didCancel: Bool
    
    init(id: Int,
         sender: String,
         receiver: String,
         sentDate: TimeInterval,
         isEditing: Bool,
         didCancel: Bool) {
        self.id = id
        self.sender = sender
        self.receiver = receiver
        self.sentDate = sentDate
        self.isEditing = isEditing
        self.didCancel = didCancel
    }
}

extension Message: Equatable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
}
