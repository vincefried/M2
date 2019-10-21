//
//  MessagesCellViewModel.swift
//  M2
//
//  Created by Vincent Friedrich on 23.02.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation
import UIKit
import SwiftDate

/// A MessageCellViewModel for a text message.
class TextMessageCellViewModel: MessageCellViewModel {
    /// If the text message is currently editing.
    let isEditingLabelHidden: Bool
    /// If the date label should be hidden.
    let isDateLabelHidden: Bool
    /// The title text above the message while in editing mode.
    let editingText: String
    /// The text of the message.
    let text: String
    /// The text of the date.
    let dateText: String
    
    init(data: TextMessage) {
        self.editingText = "\(data.sender) schreibt..."
        self.text = data.text
        self.dateText = Date(timeIntervalSince1970: data.sentDate)
            .convertTo(region: Region(calendar: Calendars.gregorian,
                                      zone: Zones.europeBerlin,
                                      locale: Locales.german))
            .toFormat("HH:mm")
        
        // Initialize cell type with receiver
        var cellType: MessageCellType = .receiver
        
        // Change celltype to sender if sender or to editing if editing
        if data.sender == BackendWorker.shared.currentUser?.username {
            cellType = .sender
        } else if data.isEditing {
            cellType = .editing
        }
        
        self.isEditingLabelHidden = cellType != .editing
        self.isDateLabelHidden = cellType == .editing
        
        super.init(cellType: cellType, data: data)
    }
}

// MARK: - Equatable
extension TextMessageCellViewModel: Equatable {
    static func == (lhs: TextMessageCellViewModel, rhs: TextMessageCellViewModel) -> Bool {
        return lhs.data == rhs.data
    }
}
