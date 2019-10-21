//
//  VoiceMemoTableViewCell.swift
//  M2
//
//  Created by Vincent Friedrich on 02.05.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import UIKit

/// A delegate for the VoiceMemoReceiverTableViewCell.
protocol VoiceMemoTableViewCellDelegate: class {
    /// Indicates, that a relayouting of the cell is necessary.
    func layoutReloadNeeded()
}

/// A UITableViewCell for displaying a received voice memo message in the MessagesViewController.
class VoiceMemoReceiverTableViewCell: UITableViewCell {
    /// The ViewModel for the VoiceMemoReceiverTableViewCell.
    /// Updates the UI when it gets set.
    var viewModel: VoiceMemoCellViewModel? {
        didSet {
            viewModel?.delegate = self
            updateUI()
        }
    }
    
    /// A delegate for the VoiceMemoReceiverTableViewCell.
    weak var delegate: VoiceMemoTableViewCellDelegate?
    
    /// A button for playing the voice memo.
    @IBOutlet weak var playButton: UIButton!
    /// A slider for displaying the voice memo duration.
    @IBOutlet weak var durationSlider: UISlider!
    /// A background view.
    @IBOutlet weak var view: UIView!
    /// A button for showing the text content of the voice memo.
    @IBOutlet weak var showTextButton: UIButton!
    /// A label for displaying the text content of the voice memo.
    @IBOutlet weak var textContentLabel: UILabel!
    /// A hairline view between the voice memo and the text content.
    @IBOutlet weak var hairlineView: UIView!
    /// An activity indicator for displaying the loading process of the text content.
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    /// A label for displaying the timestamp at which the voice memo message was received.
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initCI()
        updateUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /// Gets invoked if the user tapped on the play button.
    ///
    /// - Parameter sender: The play button.
    @IBAction func playButtonTapped(_ sender: UIButton) {
        viewModel?.handlePlayButtonTapped()
    }
    
    /// Gets invoked if the user changed the duration slider value.
    ///
    /// - Parameter sender: The duration slider.
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        
    }
    
    /// Gets invoked if the user tapped on the show text button.
    ///
    /// - Parameter sender: The show text button.
    @IBAction func tappedShowTextButton(_ sender: UIButton) {
        viewModel?.handleShowTextButtonTapped()
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
        
        durationSlider.setThumbImage(UIImage(named: "circle"), for: .normal)
    }
    
    /// Updates the UI for the content of the ViewModel.
    private func updateUI() {
        guard let viewModel = viewModel else { return }
        
        showTextButton.isHidden = !viewModel.showsTextButton
        hairlineView.isHidden = !viewModel.showsHairline
        textContentLabel.isHidden = !viewModel.showsTextContent
        durationSlider.isHidden = viewModel.isSliderHidden
        
        playButton.isEnabled = viewModel.isPlayButtonEnabled
        playButton.alpha = viewModel.isPlayButtonEnabled ? 1.0 : 0.5
        showTextButton.isEnabled = viewModel.isShowTextButtonEnabled
        showTextButton.alpha = viewModel.isShowTextButtonEnabled ? 1.0 : 0.5
        
        if viewModel.showsActivityIndicator {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        
        textContentLabel.text = viewModel.textContent
        
        showTextButton.setTitle(viewModel.showTextButtonTitle, for: .normal)
        
        durationSlider.minimumValue = viewModel.sliderDurationMinimum
        durationSlider.maximumValue = viewModel.sliderDurationMaximum
        durationSlider.value = viewModel.sliderCurrentValue
        
        playButton.setImage(UIImage(named: viewModel.playButtonImageName), for: .normal)
    }
}

// MARK: - VoiceMemoCellViewModelDelegate
extension VoiceMemoReceiverTableViewCell: VoiceMemoCellViewModelDelegate {
    func updateUINeeded() {
        updateUI()
    }
    
    func layoutReloadNeeded() {
        delegate?.layoutReloadNeeded()
    }
}
