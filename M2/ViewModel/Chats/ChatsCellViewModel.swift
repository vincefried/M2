//
//  ChatsCellViewModel.swift
//  M2
//
//  Created by Vincent Friedrich on 23.02.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation
import UIKit

/// A CellViewModel for a chats cell.
class ChatsCellViewModel: CellViewModel<Chat> {
    /// The title of the cell.
    let title: String
    /// The initials text of the user of the chats cell.
    let initialsText: String
    /// The action button text of the chats cell.
    let buttonText: String
    /// If the online indicator should be hidden.
    let isOnlineIndicatorHidden: Bool
    /// The accessory type of the cell.
    let accessoryType: UITableViewCell.AccessoryType = .disclosureIndicator
    
    override init(data: Chat) {
        self.title = data.otherUser
        self.initialsText = String(data.otherUser.first ?? Character("")).uppercased()
        self.buttonText = data.otherUserIsActive ? "Chat beitreten" : "Chat starten"
        self.isOnlineIndicatorHidden = !data.otherUserIsActive
        super.init(data: data)
    }
}
