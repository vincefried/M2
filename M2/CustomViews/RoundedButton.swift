//
//  RoundedButton.swift
//  M2
//
//  Created by Vincent Friedrich on 28.03.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import UIKit

/// A custom subclass of UIButton with rounded corners and a light shadow.
/// Can be used in interface builder.
@IBDesignable class RoundedButton: UIButton {
    
    /// The corner radius of the button
    @IBInspectable var cornerRadius: CGFloat = 20.0 {
        didSet {
            refreshCorners(value: cornerRadius)
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
    
    override var buttonType: UIButton.ButtonType {
        return .custom
    }
    
    /// Shared initializer.
    func sharedInit() {
        refreshCorners(value: cornerRadius)
    }

    /// Refreshes the button corners for a given corner radius.
    ///
    /// - Parameter value: The corner radius.
    func refreshCorners(value: CGFloat) {
        // Set corner radius
        clipsToBounds = true
        
        layer.cornerRadius = value
        layer.masksToBounds = false
        
        // Set shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 2
    }
}
