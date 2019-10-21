//
//  TextMessage.swift
//  M2
//
//  Created by Vincent Friedrich on 01.05.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// A model subclass of Message for a text message.
class TextMessage: Message {
    /// The text of the message.
    var text: String
    
    init(id: Int,
         sender: String,
         receiver: String,
         text: String,
         sentDate: TimeInterval,
         isEditing: Bool,
         didCancel: Bool) {
        self.text = text
        super.init(id: id, sender: sender, receiver: receiver, sentDate: sentDate, isEditing: isEditing, didCancel: didCancel)
    }
}
