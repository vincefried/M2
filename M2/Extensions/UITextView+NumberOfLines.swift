//
//  UITextView+NumberOfLines.swift
//  M2
//
//  Created by Vincent Friedrich on 08.03.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation
import UIKit

extension UITextView {
    /// Calculates the number of lines, contained in a UITextView.
    var numberOfLines: Int {
        guard let font = self.font else { return 0 }
        let contentHeight = self.contentSize.height - self.textContainerInset.top - self.textContainerInset.bottom
        return Int(contentHeight / font.lineHeight)
    }
}
