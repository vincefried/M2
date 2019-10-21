//
//  MessagesViewController.swift
//  M2
//
//  Created by Vincent Friedrich on 23.02.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import UIKit
import TinyConstraints
import EmptyDataSet_Swift

/// A UIViewController for displaying a chat between two users and displaying and sending their text and voice messages.
class MessagesViewController: UIViewController {
    /// The ViewModel for the messages list.
    var viewModel: MessagesListViewModel?
    
    /// A UITableView for displaying the sent messages.
    @IBOutlet weak var tableView: UITableView!
    /// A constraints of the UIToolbar to animate it when the keyboard moved up or down.
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    /// A toolbar, containing a textview and a button for sending messages.
    @IBOutlet weak var toolbar: UIToolbar!
    
    /// A textview for typing in messages to be sent.
    let messageTextView: UITextView = UITextView()
    /// A constraint to change the height of the messages textview using TinyConstraints.
    var messageTextViewHeight: Constraint!
    /// A constraint to change the height of the toolbar using TinyConstraints.
    var toolbarHeight: Constraint!
    
    /// A button for sending a text message.
    let sendButton = RoundedButton()
    /// A button for recording a voice message.
    let recordButton = RoundedButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupToolbar()
        setupTableView()
        setupTextView()
        
        self.title = viewModel?.title

        addHideGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add observers for keyboard show and hide notifications to animate toolbar.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardMovedUp(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardMovedDown(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        
        viewModel?.delegate = self
        
        // Update bottominset of tableview
        updateTableViewBottomInset(for: toolbar.frame.height)
        
        // Start chat
        startChat()
        
        // Request AudioRecordingWorker authorization if not yet granted for voice memo recording
        AudioRecordingWorker.requestAuthorization()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel?.delegate = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Dismisses the current UIViewController and leaves the chat.
    /// Asks the user before leaving to be sure.
    ///
    /// - Parameter sender: The close button.
    @IBAction func didTapCloseButton(_ sender: Any) {
        // Present an alert before leaving the chat
        let alertController = UIAlertController(title: "Chat verlassen", message: "Wenn du den Chat verlässt, geht der Chatverlauf verloren. Bist du sicher?", preferredStyle: .alert)
        let leaveAction = UIAlertAction(title: "Verlassen", style: .destructive) { [weak self] _ in
            // Leave chat and dismiss UIViewController
            self?.viewModel?.handleLeftChat(completion: { _ in
                self?.dismiss(animated: true)
            })
        }
        let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel)
        alertController.addAction(leaveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    /// Gets called when the app becomes active from background again.
    @objc private func didBecomeActive() {
        // Restart chat when becoming active again.
        startChat()
    }
    
    /// Starts the chat.
    private func startChat() {
        viewModel?.handleStartedChat(completion: { [weak self] success in
            if !success {
                let alertController = UIAlertController(title: "Fehler",
                                                        message: "Ein Fehler beim Starten des Chats ist aufgetreten",
                                                        preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel) { _ in
                    self?.dismiss(animated: true)
                }
                alertController.addAction(okAction)
                self?.present(alertController, animated: true)
            } else {
                self?.viewModel?.checkIfChatComplete()
            }
        })
    }
    
    /// Hides the keyboard when tapping anywhere on the view while editing.
    private func addHideGestureRecognizer() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        recognizer.delegate = self
        tableView.addGestureRecognizer(recognizer)
    }
    
    /// Sets up the messages textview styling.
    private func setupTextView() {
        messageTextView.layer.cornerRadius = 10
        messageTextView.layer.masksToBounds = true
        messageTextView.layer.borderColor = UIColor(named: "textFieldBorder")?.cgColor
        messageTextView.layer.borderWidth = 0.5
        messageTextView.font = .systemFont(ofSize: 14, weight: .medium)
        
        messageTextView.delegate = self
        
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// Handles when the keyboard moved up.
    ///
    /// - Parameter notification: The internal notification sent by iOS.
    @objc private func keyboardMovedUp(_ notification: Notification) {
        // Get the keyboard size
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
            as? NSValue)?.cgRectValue
            else { return }
        // Update insets for keyboard size
        let keyboardHeight = keyboardSize.height - view.safeAreaInsets.bottom
        updateToolbarPosition(for: keyboardHeight)
        updateTableViewBottomInset(for: keyboardHeight + toolbar.frame.height)
    }
    
    /// Handles when the keyboard moved down.
    ///
    /// - Parameter notification: The internal notification sent by iOS.
    @objc private func keyboardMovedDown(_ notification: Notification) {
        // Update insets for initial size
        updateToolbarPosition(for: 0)
        updateTableViewBottomInset(for: toolbar.frame.height)
    }
    
    /// Updates the toolbar position and its constraint for a given keyboard height.
    ///
    /// - Parameter keyboardHeight: The given keyboard height.
    private func updateToolbarPosition(for keyboardHeight: CGFloat) {
        toolbarBottomConstraint.constant = keyboardHeight
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    /// Updates the table view bottom inset for a given keyboard height.
    ///
    /// - Parameter keyboardHeight: The given keyboard height.
    private func updateTableViewBottomInset(for keyboardHeight: CGFloat) {
        tableView.contentInset.top = keyboardHeight + 10 // inset
        tableView.scrollIndicatorInsets.top = keyboardHeight + 10 // inset
    }
    
    /// Hides the keyboard.
    @objc private func hideKeyboard() {
        messageTextView.resignFirstResponder()
    }
    
    /// Sets up the toolbar styling, adds all buttons and the messages textview to it.
    private func setupToolbar() {
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbarHeight = toolbar.height(52)

        sendButton.backgroundColor = UIColor(named: "complementary")
        sendButton.cornerRadius = 16
        sendButton.setImage(UIImage(named: "send"), for: .normal)
        sendButton.isHidden = true
        sendButton.addTarget(self, action: #selector(sendButtonTapped(_:)), for: .touchUpInside)
        
        recordButton.backgroundColor = UIColor(named: "complementary")
        recordButton.cornerRadius = 16
        recordButton.setImage(UIImage(named: "micro"), for: .normal)
        recordButton.addTarget(self, action: #selector(recordButtonTouchDown(_:)), for: .touchDown)
        recordButton.addTarget(self, action: #selector(recordButtonTouchUp(_:)), for: .touchUpInside)

        let contentView = UIView()
        contentView.addSubview(messageTextView)

        let contentItem = UIBarButtonItem(customView: contentView)
        
        toolbar.items = [contentItem]
        
        let buttonsStackView = UIStackView()
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 8
        buttonsStackView.alignment = .center
        
        contentView.addSubview(buttonsStackView)
        
        messageTextView.leading(to: contentView, contentView.leadingAnchor)
        messageTextView.trailing(to: buttonsStackView, buttonsStackView.leadingAnchor, offset: -16)
        messageTextView.top(to: contentView, contentView.topAnchor)
        messageTextView.bottom(to: contentView, contentView.bottomAnchor)
        
        messageTextViewHeight = messageTextView.height(34)
        
        buttonsStackView.trailing(to: contentView, contentView.trailingAnchor)
        buttonsStackView.centerY(to: messageTextView)
        
        buttonsStackView.addArrangedSubview(sendButton)
        
        sendButton.width(40)
        sendButton.height(40)
        
        buttonsStackView.addArrangedSubview(recordButton)
        
        recordButton.width(40)
        recordButton.height(40)
    }
    
    /// Sets up the table view styling.
    private func setupTableView() {
        tableView.register(UINib(nibName: "SenderTableViewCell", bundle: nil), forCellReuseIdentifier: "SenderCell")
        tableView.register(UINib(nibName: "ReceiverTableViewCell", bundle: nil), forCellReuseIdentifier: "ReceiverCell")
        tableView.register(UINib(nibName: "VoiceMemoSenderTableViewCell", bundle: nil), forCellReuseIdentifier: "VoiceMemoSenderCell")
        tableView.register(UINib(nibName: "VoiceMemoReceiverTableViewCell", bundle: nil), forCellReuseIdentifier: "VoiceMemoReceiverCell")
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        
        tableView.emptyDataSetSource = self
    }
    
    /// Gets called when the user tapped the send button.
    ///
    /// - Parameter sender: The send button.
    @objc func sendButtonTapped(_ sender: UIButton) {
        // Get the messages textview text
        guard let text = messageTextView.text,
            !messageTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty
            else { return }
        // Handle button action
        viewModel?.handleSendButtonTapped(with: text)
        // Reset text
        messageTextView.text = nil
        // We have to call explicitly because setting text manually doesn't trigger delegate
        textViewDidChange(messageTextView)
    }
    
    /// Gets called when the user started holding the record button.
    ///
    /// - Parameter sender: The record button.
    @objc func recordButtonTouchDown(_ sender: UIButton) {
        viewModel?.handleRecordButtonTouchDown()
    }
    
    /// Gets called when the user released the record button.
    ///
    /// - Parameter sender: The record button.
    @objc func recordButtonTouchUp(_ sender: UIButton) {
        viewModel?.handleRecordButtonTouchUp()
    }

}

// MARK: - UITableViewDataSource
extension MessagesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.data.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel?.data[indexPath.row] {
        case let viewModel as TextMessageCellViewModel:
            switch viewModel.cellType {
            case .sender:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SenderCell", for: indexPath) as! SenderTableViewCell
                cell.transform = CGAffineTransform(scaleX: 1, y: -1)
                cell.viewModel = viewModel
                return cell
            case .receiver:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverCell", for: indexPath) as! ReceiverTableViewCell
                cell.transform = CGAffineTransform(scaleX: 1, y: -1)
                cell.viewModel = viewModel
                return cell
            case .editing:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverCell", for: indexPath) as! ReceiverTableViewCell
                cell.transform = CGAffineTransform(scaleX: 1, y: -1)
                cell.viewModel = viewModel
                return cell
            }
        case let viewModel as VoiceMemoCellViewModel:
            if viewModel.cellType == .sender {
                let cell = tableView.dequeueReusableCell(withIdentifier: "VoiceMemoSenderCell", for: indexPath) as! VoiceMemoSenderTableViewCell
                cell.transform = CGAffineTransform(scaleX: 1, y: -1)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "VoiceMemoReceiverCell", for: indexPath) as! VoiceMemoReceiverTableViewCell
                cell.delegate = self
                cell.viewModel = viewModel
                cell.transform = CGAffineTransform(scaleX: 1, y: -1)
                return cell
            }
        default:
            fatalError()
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension MessagesViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Activate tap recognizer to hide keyboard only for active editing
        return messageTextView.isFirstResponder
    }
}

// MARK: - UITextViewDelegate
extension MessagesViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let viewModel = viewModel else { return }
        
        // Handle typing in ViewModel
        viewModel.handleTyping(with: textView.text)
        
        // Update textview size according to current text content up to a maximum height
        if textView.numberOfLines < viewModel.messagesTextFieldMaxLines
            && viewModel.oldNumberOfLines != textView.numberOfLines
            && viewModel.oldNumberOfLines != 0 {
            
            let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: .greatestFiniteMagnitude))
            messageTextViewHeight.constant = ceil(size.height)
            toolbarHeight.constant = ceil(size.height) + 16
            textView.contentOffset.y = textView.contentOffset.y + textView.textContainerInset.top
            
            textView.scrollRangeToVisible(NSMakeRange(textView.text.count - 1, 1))
            
            UIView.animate(withDuration: 0.3, animations: {
                self.toolbar.layoutIfNeeded()
            })
        }
        
        // Toggle send or record button if textview is starting editing
        sendButton.isHidden = textView.text.isEmpty
        recordButton.isHidden = !textView.text.isEmpty
        
        if viewModel.oldNumberOfLines != textView.numberOfLines {
            viewModel.oldNumberOfLines = textView.numberOfLines
        }
    }
}

// MARK: - MessagesListViewModelDelegate
extension MessagesViewController: MessagesListViewModelDelegate {
    func updateUINeeded() {
        guard let viewModel = viewModel else { return }
        
        if let navigationItem = navigationItem as? MessagesNavigationItem {
            navigationItem.isOnline = viewModel.isOnline
        }
        
        toolbar.isHidden = viewModel.isToolbarHidden
        
        tableView.transform = viewModel.reverseTableView ? CGAffineTransform(scaleX: 1, y: -1) : CGAffineTransform.identity
        tableView.reloadData()
        
        if viewModel.isToolbarHidden {
            view.endEditing(true)
        }
    }
}

// MARK: - VoiceMemoTableViewCellDelegate
extension MessagesViewController: VoiceMemoTableViewCellDelegate {
    func layoutReloadNeeded() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

// MARK: - EmptyDataSetSource
extension MessagesViewController: EmptyDataSetSource {
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return viewModel?.emptyDataSetImage
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return viewModel?.emptyDataSetDescription
    }
}
