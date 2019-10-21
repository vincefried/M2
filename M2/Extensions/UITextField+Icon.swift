//
//  UITextField+Icon.swift
//  M2
//
//  Created by Vincent Friedrich on 29.03.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    /// Adds an icon to the left of a UITextField.
    ///
    /// - Parameter image: The image that should be used as an icon.
    func setIcon(_ image: UIImage) {
        let iconView = UIImageView(frame: CGRect(x: 10, y: 5, width: 20, height: 20))
        iconView.image = image
        let iconContainerView: UIView = UIView(frame: CGRect(x: 20, y: 0, width: 30, height: 30))
        iconContainerView.addSubview(iconView)
        leftView = iconContainerView
        leftViewMode = .always
    }
}
