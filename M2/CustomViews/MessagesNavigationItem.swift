//
//  MessagesNavigationBar.swift
//  M2
//
//  Created by Vincent Friedrich on 14.07.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import UIKit
import TinyConstraints

/// A custom subclass of UINavigationItem with an online indicator for the use in MessagesViewController.
class MessagesNavigationItem: UINavigationItem {
    
    /// The container view for holding the online indicator and title label.
    private var containerView: UIStackView?
    
    /// The online indicator.
    var onlineIndicator: UIView?
    
    /// If the online indicator should display online or offline state.
    /// For offline state, the indicator is gray, for online state, it is green.
    var isOnline: Bool = false {
        didSet {
            updateOnlineIndicator(isOnline: isOnline)
        }
    }
    
    /// The title label.
    var titleLabel: UILabel?
    
    override var title: String? {
        didSet {
            // Simulate the same behaviour as with the official title label
            titleLabel?.text = title
            titleLabel?.sizeToFit()
        }
    }
    
    override init(title: String) {
        super.init(title: title)
        setupView(title: title)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView(title: nil)
    }
    
    /// Sets the view and all of its styling properties up.
    ///
    /// - Parameter title: The title of the view.
    private func setupView(title: String?) {
        // Add online indicator
        onlineIndicator = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
        onlineIndicator?.backgroundColor = UIColor(named: "extraLightGray")
        onlineIndicator?.layer.cornerRadius = 6
        onlineIndicator?.layer.masksToBounds = true
        
        // Add title label
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 41, height: 22))
        titleLabel?.font = UIFont(name: "Futura", size: 17)
        titleLabel?.textColor = UIColor(named: "primary")
        titleLabel?.text = title
        titleLabel?.sizeToFit()
        
        // Add both views to the container view
        if let onlineIndicator = onlineIndicator, let titleLabel = titleLabel {
            containerView = UIStackView(arrangedSubviews: [onlineIndicator, titleLabel])
            containerView?.spacing = 8
            containerView?.alignment = .center
            onlineIndicator.width(12)
            onlineIndicator.height(12)
        }
        
        // Set the container view as title view
        titleView = containerView
    }
    
    /// Updates the online indicator.
    /// For offline state, the indicator is gray, for online state, it is green.
    ///
    /// - Parameter isOnline: The state for the online indicator.
    private func updateOnlineIndicator(isOnline: Bool) {
        onlineIndicator?.backgroundColor = isOnline ? UIColor(named: "correct") : UIColor(named: "extraLightGray")
    }
}
