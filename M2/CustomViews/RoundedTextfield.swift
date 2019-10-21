//
//  RoundedTextfield.swift
//  M2
//
//  Created by Vincent Friedrich on 29.03.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation
import UIKit

/// A custom subclass of UITextField with rounded corners and an optional icon.
/// Can be used in interface builder.
@IBDesignable class RoundedTextfield: UITextField {
    
    /// The corner radius of the textfield.
    @IBInspectable var cornerRadius: CGFloat = 20.0 {
        didSet {
            refreshCorners(value: cornerRadius)
        }
    }
    
    /// The border width of the textfield.
    @IBInspectable var borderWidth: CGFloat = 1.0 {
        didSet {
            refreshBorders(value: borderWidth)
        }
    }
    
    /// The border color of the textfield.
    @IBInspectable var borderColor: UIColor = .lightGray {
        didSet {
            refreshBorderColor(value: borderColor)
        }
    }
    
    /// The icon of the textfield. Is not displayed when nil.
    @IBInspectable var icon: UIImage? {
        didSet {
            refreshIcon(value: icon)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    /// Shared initializer.
    func sharedInit() {
        refreshCorners(value: cornerRadius)
        refreshBorders(value: borderWidth)
        refreshBorderColor(value: borderColor)
        refreshIcon(value: icon)
    }
    
    /// Refreshes the border color for a given color.
    ///
    /// - Parameter value: The color.
    func refreshBorderColor(value: UIColor) {
        layer.borderColor = value.cgColor
    }
    
    /// Refreshes the border width for a given value.
    ///
    /// - Parameter value: The border width.
    func refreshBorders(value: CGFloat) {
        layer.borderWidth = value
    }
    
    /// Refreshes the corner radius for a given value.
    ///
    /// - Parameter value: The corner radius.
    func refreshCorners(value: CGFloat) {
        layer.cornerRadius = value
        layer.masksToBounds = true
    }
    
    /// Refreshes the icon for a given radius.
    ///
    /// - Parameter value: The given image for the icon.
    func refreshIcon(value: UIImage?) {
        guard let image = value else { return }
        setIcon(image)
    }
}
