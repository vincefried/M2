//
//  ChatsViewController.swift
//  M2
//
//  Created by Vincent Friedrich on 17.02.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift
import TinyConstraints
import NGSBadgeBarButton

/// A UIViewController for displaying a list of possible chats that the current user is able to start according to his friends list.
class ChatsViewController: UIViewController {
    /// The chats provider with the list of chats.
    let chatsProvider = ChatsProvider()
    /// The ViewModel for the chats list.
    var viewModel: ChatsListViewModel?
    
    /// A refresh control for allowing the user to update the chats list by pulling down the UITableView.
    let refreshControl = UIRefreshControl()
    
    /// The main list view, containing the chats list.
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        XCGLogger.default.debug("Logged in as \(PersistanceWorker.thisUserName ?? "(not registered yet)")")
        
        setupTableView()
        setupViewModel()
        setupBarButtons()
        
        // Toggle refresh on view load
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.toggleRefreshControl(refreshing: true)
            self.refresh()
        }
    }
    
    deinit {
        viewModel?.unbind(observer: self)
    }
    
    /// Gets called if the user taps on the open friends requests button in the UINavigationBar.
    /// Presents a UINavigationController with the FriendsRequestsViewController in it.
    @objc private func showFriendsRequests() {
        let storyboard = UIStoryboard(name: "Add", bundle: nil)
        guard let friendsNavigationController = storyboard.instantiateViewController(withIdentifier: "FriendsRequestsNavigationController") as? UINavigationController else { return }
        present(friendsNavigationController, animated: true)
    }
    
    /// Gets called if the user taps on the add user button in the UINavigationBar.
    /// Presents a UINavigationController with the AddUserViewController in it.
    @objc private func addUser() {
        let storyboard = UIStoryboard(name: "Add", bundle: nil)
        guard let addUserNavigationController = storyboard.instantiateInitialViewController() as? UINavigationController else { return }
        present(addUserNavigationController, animated: true)
    }
    
    /// Gets called if the user taps on the logout button in the UINavigationBar.
    /// Asks user before logging out to be sure.
    @objc private func logout() {
        // Present an alert to ask the user if he is sure that he wants to log out.
        let alertController = UIAlertController(title: "Logout", message: "Willst du dich wirklich abmelden?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel)
        let logoutAction = UIAlertAction(title: "Abmelden", style: .destructive) { [weak self] _ in
            // Handle logout, display alert if unsuccessful
            self?.viewModel?.handleLogout { success in
                guard !success else { return }
                let alertController = UIAlertController(title: "Fehler", message: "Fehler beim Logout", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel)
                alertController.addAction(okAction)
                self?.present(alertController, animated: true)
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(logoutAction)
        present(alertController, animated: true)
    }
    
    /// Toggles the refresh control.
    ///
    /// - Parameter refreshing: If the refresh control should be refreshing.
    private func toggleRefreshControl(refreshing: Bool) {
        if refreshing {
            tableView.setContentOffset(CGPoint(x: 0, y: -refreshControl.frame.size.height), animated: true)
            refreshControl.beginRefreshing()
        } else {
            refreshControl.endRefreshing()
        }
    }
    
    /// Sets the ViewModel up and binds it to this ViewController for updating the tableview for changes.
    private func setupViewModel() {
        viewModel = ChatsListViewModel(chatsProvider: chatsProvider)
        viewModel?.delegate = self
        viewModel?.unbind(observer: self)
        viewModel?.bind(closure: { [weak self] _, changeset in
            guard let self = self,
                let changeset = changeset,
                let viewModel = self.viewModel else { return }
            // Add footer view to hide unnecessary cell seperators.
            self.tableView.tableFooterView = UIView()

            // Load data if empty, update data using DifferenceKit if not empty
            DispatchQueue.main.async {
                if viewModel.data.isEmpty {
                    viewModel.loadData()
                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()
                } else {
                    self.tableView.reload(using: changeset, with: .fade, setData: { newData in
                        viewModel.updateData(newData)
                        
                        if newData.isEmpty {
                            self.tableView.reloadData()
                        }
                    })
                    
                    self.tableView.refreshControl?.endRefreshing()
                }
            }
        }, observer: self)
    }
    
    /// Sets up the table view.
    private func setupTableView() {
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.alwaysBounceVertical = true
        tableView.register(UINib(nibName: "ChatTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        tableView.rowHeight = 80
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    /// Sets up the bar buttons of the UINavigationBar.
    private func setupBarButtons() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(named: "add-contact"),
                            style: .plain,
                            target: self,
                            action: #selector(addUser)),
            UIBarButtonItem(image: UIImage(named: "logout"),
                            style: .plain,
                            target: self,
                            action: #selector(logout))
        ]
        guard let image = UIImage(named: "bell") else { return }
        let barButton = NGSBadgeBarButton(badgeButtonWithImage: image,
                                          target: self,
                                          selector: #selector(showFriendsRequests),
                                          insets: UIEdgeInsets(top: 2.5, left: 2.5, bottom: -2.5, right: -2.5))
        barButton.badgeLabel.font = UIFont(name: "Futura", size: 16)
        navigationItem.leftBarButtonItem = barButton
    }
    
    /// Fetches the chats list and refreshes the UITableView.
    @objc private func refresh() {
        chatsProvider.getChats { [weak self] result in
            switch result {
            case .success:
                break
            case .failure:
                let alertControler = UIAlertController(title: "Fehler", message: "Ein Fehler mit der Serververbindung ist aufgetreten.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel)
                alertControler.addAction(okAction)
                self?.present(alertControler, animated: true)
                
                self?.toggleRefreshControl(refreshing: false)
            }
        }
        FriendsRequestsProvider.shared.getFriendsRequests()
    }
}

// MARK: - UITableViewDataSource
extension ChatsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.data.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChatTableViewCell
        cell.viewModel = viewModel?.data[indexPath.row]
        cell.accessoryType = .none
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ChatsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Get selected index
        guard indexPath.row < (viewModel?.data.count ?? 0), let chats = chatsProvider.chats else { return }
        
        // Get new instance of MessagesViewController
        guard let navigationController = storyboard?.instantiateViewController(withIdentifier: "MessagesNavigationController") as? UINavigationController,
            let viewController = navigationController.viewControllers.first as? MessagesViewController
            else { return }
        
        // Initialize MessagesProvider for chat at selected index
        let messagesProvider = MessagesProvider(chat: chats[indexPath.row])
        // Initialize MessagesListViewModel with new provider and set it to MessagesViewController
        viewController.viewModel = MessagesListViewModel(messagesProvider: messagesProvider)
        // Present new MessagesViewController
        present(navigationController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Delete selected chat on cell swipe
        if editingStyle == .delete {
            guard indexPath.row < (viewModel?.data.count ?? 0) else { return }
            viewModel?.handleDeleteChat(at: indexPath.row)
        }
    }
}

// MARK: - EmptyDataSetSource
extension ChatsViewController: EmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        guard let _ = chatsProvider.chats else { return nil }
        return NSAttributedString(string: "Noch keine Freunde")
    }
    
    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
        guard let _ = chatsProvider.chats else { return nil }
        
        // Initialize and set EmptyDataView with ChatsEmptyDataViewModel.
        let view = EmptyDataView()
        view.viewModel = ChatsEmptyDataViewModel()
        view.delegate = self
        return view
    }
}

// MARK: - EmptyDataViewDelegate
extension ChatsViewController: EmptyDataViewDelegate {
    func didPressButton() {
        // Open AddUserViewController on EmptyDataView button press
        addUser()
    }
}

// MARK: - EmptyDataSetDelegate
extension ChatsViewController: EmptyDataSetDelegate {
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }
}

// MARK: - ChatsListViewModelDelegate
extension ChatsViewController: ChatsListViewModelDelegate {
    func updateUINeeded() {
        // Update badge value on friends request change
        guard let barButtonItem = navigationItem.leftBarButtonItem as? NGSBadgeBarButton else { return }
        barButtonItem.badgeLabel.text = viewModel?.badgeValue
    }
}
