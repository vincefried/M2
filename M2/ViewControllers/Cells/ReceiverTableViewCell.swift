//
//  ReceiverTableViewCell.swift
//  M2
//
//  Created by Vincent Friedrich on 27.04.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import UIKit

/// A UITableViewCell for displaying a received message in the MessagesViewController.
class ReceiverTableViewCell: UITableViewCell {
    /// The ViewModel for the ReceiverTableViewCell.
    /// Updates the UI when it gets set.
    var viewModel: TextMessageCellViewModel? {
        didSet {
            updateUI()
        }
    }
    
    /// A label for displaying the received message.
    @IBOutlet weak var messageLabel: UILabel!
    /// A background view.
    @IBOutlet weak var bubbleView: UIView!
    /// A label for displaying a title that indicates that the message is currently editing.
    @IBOutlet weak var editingLabel: UILabel!
    /// A label that displayes the timestamp at which the message was received.
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initCI()
        updateUI()
    }
    
    /// Initializes the CI and styles all views as necessary.
    private func initCI() {
        bubbleView.clipsToBounds = true
        
        bubbleView.layer.cornerRadius = 20
        bubbleView.layer.masksToBounds = false
        
        bubbleView.layer.shadowColor = UIColor.black.cgColor
        bubbleView.layer.shadowOpacity = 0.1
        bubbleView.layer.shadowOffset = CGSize(width: 0, height: 1)
        bubbleView.layer.shadowRadius = 2
    }
    
    /// Updates the UI for the content of the ViewModel.
    private func updateUI() {
        guard let viewModel = viewModel,
        viewModel.cellType == .receiver || viewModel.cellType == .editing  else { return }
        
        editingLabel.text = viewModel.editingText
        messageLabel.text = viewModel.text
        dateLabel.text = viewModel.dateText
        
        editingLabel.isHidden = viewModel.isEditingLabelHidden
        dateLabel.isHidden = viewModel.isDateLabelHidden
    }
    
}
