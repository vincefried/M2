//
//  UITableView+ScrollToBottom.swift
//  M2
//
//  Created by Vincent Friedrich on 06.03.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    /// Scrolls a UITableView to the bottom.
    ///
    /// - Parameter animated: If the scrolling should be animated.
    public func scrollToBottom(animated: Bool) {
        let numberOfRows = self.numberOfRows(inSection: 0)
        if numberOfRows == 0 { return }
        
        scrollToRow(at: IndexPath(row: numberOfRows - 1, section: 0), at: .bottom, animated: animated)
    }
}
