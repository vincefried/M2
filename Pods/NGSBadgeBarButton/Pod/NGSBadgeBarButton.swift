//
//  NGSBadgeBarButton.swift
//  BadgeBarButtonExample
//
//  Created by Vindzigelskis, Paulius on 2/12/18.
//  Copyright © 2018 New Guy Studio. All rights reserved.
//

import UIKit
/**
    Custom UIBarButtonItem subclass with added Badge on corner.
 
    Parameters:
    - kDefaultBadgeInsets : UIEdgeInsets
    - badgeLabel : UILabel
    - badgeBackgroundColor : UIColor
 
    Use these designated initializers to access badge properties:
 
    ```
    init(badgeButtonWithImage: UIImage,
                       target: Any,
                     selector: Selector,
                     position: CGPoint, //Optional
                       insets: UIEdgeInsets //Optional
    )
 
    init(badgeButtonWithTitle: String,
                       target: Any,
                     selector: Selector,
                     position: CGPoint, //Optional
                       insets: UIEdgeInsets //Optional
    )
 
    init(badgeButtonWithTitle: String,
                       target: Any,
                     selector: Selector,
                     position: CGPoint, //Optional
                       insets: UIEdgeInsets //Optional
    )
 
    ```
*/
open class NGSBadgeBarButton : UIBarButtonItem
{
    //MARK:- Public accessible Properties
    
/**
     Default Badge Bar Button insets
*/
    public static let kDefaultBadgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: -5, right: -5)
    
/**
     Read only access to Badge Label to control text color, font and text itself
*/
    public private(set) weak var badgeLabel:UILabel! = nil
    
/**
     The color of badge bubble. Defaults to Red
*/
    public var badgeBackgroundColor:UIColor?
    {
        get {
            return self.badgeContainer.backgroundColor
        }
        
        set (newValue)
        {
            self.badgeContainer.backgroundColor = newValue
        }
    }
    
    //MARK:- Private Properties
    private var badgeSizeConstraints:[NSLayoutConstraint] = []
    private weak var badgeContainer:UIView! = nil
    
    //MARK:- Public API
    
/**
     Badge Bar Button with Image
     
     - parameter image: Button image
     - parameter target: The object that receives the action message
     - parameter selector: The action to send to target when this item is selected
     - parameter position: Reposition badge in relation to button's top right corner. Default is CGPoint.zero
     - parameter insets: Badge text (label) insets inside it's bubble (red container). Default is (5, 5, -5, -5)
     
     - note: Pass template image to react to tint color
*/
    
    public convenience init(badgeButtonWithImage image:UIImage,
                            target:Any,
                            selector:Selector,
                            position:CGPoint = .zero,
                            insets:UIEdgeInsets = NGSBadgeBarButton.kDefaultBadgeInsets)
    {
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.addTarget(target, action: selector, for: .touchUpInside)
        self.init(badgeButtonWithCustomView: button, position:position, insets:insets)
    }
    
/**
     Badge Bar Button with Text
     
     - parameter text: Button text
     - parameter target: The object that receives the action message
     - parameter selector: The action to send to target when this item is selected
     - parameter position: Reposition badge in relation to button's top right corner. Default is CGPoint.zero
     - parameter insets: Badge text (label) insets inside it's bubble (red container). Default is (5, 5, -5, -5)
*/
    
    public convenience init(badgeButtonWithTitle text:String,
                            target:Any,
                            selector:Selector,
                            position:CGPoint = .zero,
                            insets:UIEdgeInsets = NGSBadgeBarButton.kDefaultBadgeInsets)
    {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .highlighted)
        button.setTitle(text, for: .normal)
        button.addTarget(target, action: selector, for: .touchUpInside)
        self.init(badgeButtonWithCustomView: button, position:position, insets:insets)
    }
    
/**
     Badge Bar Button with custom view
     
     - parameter customView: A custom view representing the item
     - parameter position: Reposition badge in relation to button's top right corner. Default is CGPoint.zero
     - parameter insets: Badge text (label) insets inside it's bubble (red container). Default is (5, 5, -5, -5)
*/
    
    public convenience init(badgeButtonWithCustomView customView:UIView,
                            position:CGPoint = .zero,
                            insets:UIEdgeInsets = NGSBadgeBarButton.kDefaultBadgeInsets)
    {
        // Custom view
        let view = UIView()
        let fontSize:CGFloat = 12.0
        let badgeFont = UIFont.systemFont(ofSize: fontSize)
        
        // Button disguised as UIBarButton
        view.addSubview(customView)
        customView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            // stick to container's bottom left
            customView.leftAnchor.constraint(equalTo: view.leftAnchor),
            customView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Badge red container.
        let badgeView = UIView()
        badgeView.backgroundColor = UIColor.red
        badgeView.layer.masksToBounds = true
        
        // Label to store badge text
        let badge = UILabel()
        badge.textAlignment = .center
        badge.textColor = UIColor.white
        badge.font = badgeFont
        badgeView.addSubview(badge)
        badge.translatesAutoresizingMaskIntoConstraints = false
        
        // Badge container stretches with label by x axis. Default insets provided
        let badgeInsetConstraints = [
            badge.topAnchor.constraint(equalTo: badgeView.topAnchor, constant: insets.top),
            badge.bottomAnchor.constraint(equalTo: badgeView.bottomAnchor, constant: insets.bottom),
            badge.leftAnchor.constraint(equalTo: badgeView.leftAnchor, constant: insets.left),
            badge.rightAnchor.constraint(equalTo: badgeView.rightAnchor, constant: insets.right)
        ]
        badgeView.addConstraints(badgeInsetConstraints)
        
        view.addSubview(badgeView)
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            // stick badge on button's right top corner
            badgeView.rightAnchor.constraint(equalTo: customView.rightAnchor, constant: fontSize + position.x),
            badgeView.centerYAnchor.constraint(equalTo: customView.topAnchor, constant: position.y),
            // close container with badge edges
            badgeView.rightAnchor.constraint(equalTo: view.rightAnchor),
            badgeView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
        
        // Round corners
        badge.text = "0"
        let compressedSize = badgeView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        badgeView.layer.cornerRadius = compressedSize.height / 2
        badge.text = nil
        
        // Setup min width to be round by default with short text
        let sizeConstraints = [
            badgeView.widthAnchor.constraint(greaterThanOrEqualToConstant: compressedSize.height),
            badgeView.heightAnchor.constraint(greaterThanOrEqualToConstant: compressedSize.height)
        ]
        badgeView.addConstraints(sizeConstraints)
        
        // iOS 10 and below doesn't adjust with Auto Layout automagically
        let initialViewSize = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        view.frame = CGRect(origin: .zero, size: initialViewSize)
        
        // Initialize as custom bar button
        self.init(customView: view)
        
        // Setup properties
        self.badgeLabel = badge
        self.badgeContainer = badgeView
        self.badgeContainer.isHidden = true
        self.badgeSizeConstraints = sizeConstraints
        
        self.setupObservers()
        
        // Let actions go through
        self.badgeLabel.isUserInteractionEnabled = false
        self.badgeContainer.isUserInteractionEnabled = false
    }
    
    //MARK:- Private methods
    
    func setupSizeConstraints(withFont font:UIFont)
    {
        let defaultValue = self.badgeLabel.text
        let badge = self.badgeLabel!
        let badgeView = self.badgeContainer!
        
        badgeView.removeConstraints(self.badgeSizeConstraints)
        // Round corners
        badge.text = "0"
        let compressedSize = badgeView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        badgeView.layer.cornerRadius = compressedSize.height / 2
        
        // Setup min width to be round by default with short text
        self.badgeSizeConstraints = [
            badgeView.widthAnchor.constraint(greaterThanOrEqualToConstant: compressedSize.height),
            badgeView.heightAnchor.constraint(greaterThanOrEqualToConstant: compressedSize.height)
        ]
        badgeView.addConstraints(self.badgeSizeConstraints)
        
        badge.text = defaultValue
    }
    
    private func setupObservers()
    {
        // Track Badge Label setter
        self.badgeLabel.addObserver(self, forKeyPath: "text", options: .new, context: nil)
        self.badgeLabel.addObserver(self, forKeyPath: "font", options: .new, context: nil)
        
        // Track Badge Insets setter
        self.addObserver(self, forKeyPath: "badgeInsets", options: .new, context: nil)
    }
    
    deinit {
        if let label = self.badgeLabel
        {
            label.removeObserver(self, forKeyPath: "text")
            label.removeObserver(self, forKeyPath: "font")
        }

        self.removeObserver(self, forKeyPath: "badgeInsets")
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "text"
        {
            // Badge Value
            let newValue = self.badgeLabel.text
            if let value = newValue
            {
                self.badgeContainer.isHidden = value.isEmpty
            } else {
                self.badgeContainer.isHidden = true
            }
            self.badgeLabel.layoutIfNeeded()
        } else if keyPath == "font"
        {
            self.setupSizeConstraints(withFont: self.badgeLabel.font)
        }
    }
}
