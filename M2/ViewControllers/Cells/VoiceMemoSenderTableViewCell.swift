//
//  VoiceMemoSenderTableViewCell.swift
//  M2
//
//  Created by Vincent Friedrich on 15.07.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import UIKit

/// A UITableViewCell for displaying a sent voice memo message in the MessagesViewController.
class VoiceMemoSenderTableViewCell: UITableViewCell {
    /// A background view.
    @IBOutlet weak var view: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initCI()
    }
    
    /// Initializes the CI and styles all views as necessary.
    private func initCI() {
        view.clipsToBounds = true
        
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = false
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 2
    }
}
