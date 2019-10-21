//
//  MessageCellViewModel.swift
//  M2
//
//  Created by Vincent Friedrich on 01.05.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// An enum for a message cell style.
///
/// - sender: The cell style shows it has been sent by the sender. The bubble view has gray background and black text.
/// - receiver: The cell style shows it has been sent by the receiver. The bubble view has blue background and white text.
/// - editing: The cell style shows it is currently editing by the receiver. The bubble view has a white background and black text.
enum MessageCellType {
    case sender, receiver, editing
}

/// A CellViewModel for a message cell.
class MessageCellViewModel: CellViewModel<Message> {
    /// The message cell style.
    let cellType: MessageCellType
    
    init(cellType: MessageCellType, data: Message) {
        self.cellType = cellType
        super.init(data: data)
    }
}
