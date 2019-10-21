//
//  FriendsRequestsViewController.swift
//  M2
//
//  Created by Vincent Friedrich on 30.03.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

/// A UITableViewController for displaying a list of open friends requests.
class FriendsRequestsViewController: UITableViewController {
    /// A provider, containing the list of open friends requests.
    let friendsRequestsProvider = FriendsRequestsProvider.shared
    /// The ViewModel for the FriendsRequestsViewController.
    var viewModel: FriendsRequestListViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupTableView()
        setupViewModel()
        refresh()
    }
    
    /// Sets up the UINavigationBar.
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: #selector(dismissViewController))
    }
    
    /// Dismisses the current ViewController.
    @objc private func dismissViewController() {
        dismiss(animated: true)
    }
    
    /// Sets the ViewModel up and binds it to this ViewController for updating the tableview for changes.
    private func setupViewModel() {
        viewModel = FriendsRequestListViewModel(friendsRequestsProvider: friendsRequestsProvider)
        viewModel?.unbind(observer: self)
        viewModel.bind(closure: { [weak self] _, changeset in
            self?.tableView.refreshControl?.endRefreshing()
            
            guard let self = self, let changeset = changeset else { return }
            // Add footer view to hide unnecessary cell seperators.
            self.tableView.tableFooterView = UIView()
            
            // Load data if empty, update data using DifferenceKit if not empty
            DispatchQueue.main.async {
                if self.viewModel.data.isEmpty {
                    self.viewModel.loadData()
                    self.tableView.reloadData()
                } else {
                    self.tableView.reload(using: changeset, with: .fade, setData: { newData in
                        self.viewModel.updateData(newData)
                        
                        if newData.isEmpty {
                            self.tableView.reloadData()
                            // Dismiss automatically after animation has finished if no requests left
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                self.dismiss(animated: true)
                            }
                        }
                    })
                }
            }
        }, observer: self)
    }
    
    /// Sets up the table view styling.
    private func setupTableView() {
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.register(UINib(nibName: "FriendsRequestTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "Cell")
        tableView.rowHeight = 80
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    /// Fetches the friends requests from the provider.
    @objc private func refresh() {
        friendsRequestsProvider.getFriendsRequests()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FriendsRequestTableViewCell
        cell.viewModel = viewModel.data[indexPath.row]
        return cell
    }
}

// MARK: - EmptyDataSetSource
extension FriendsRequestsViewController: EmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No friends yet")
    }
    
    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
        // Initialize and set EmptyDataView with ChatsEmptyDataViewModel.
        let view = EmptyDataView()
        view.viewModel = FriendsRequestsEmptyDataViewModel()
        return view
    }
}

// MARK: - EmptyDataSetDelegate
extension FriendsRequestsViewController: EmptyDataSetDelegate {
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }
}
