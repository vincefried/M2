//
//  FriendsRequestListViewModel.swift
//  M2
//
//  Created by Vincent Friedrich on 30.03.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// ListViewModel for the friends requests.
class FriendsRequestListViewModel: DifferentiableObservableListViewModel<FriendsRequestResponse, FriendsRequestCellViewModel> {
    /// The friends requests provider.
    private let friendsRequestsProvider: FriendsRequestsProvider
    
    init(friendsRequestsProvider: FriendsRequestsProvider) {
        self.friendsRequestsProvider = friendsRequestsProvider
        super.init(provider: friendsRequestsProvider)
    }
    
    /// Loads data from the friends requests provider and maps the data to instances of FriendsRequestCellViewModel.
    func loadData() {
        data = friendsRequestsProvider.friendsRequests.map(FriendsRequestCellViewModel.init)
    }
    
    /// Maps given data to instances of FriendsRequestCellViewModel.
    ///
    /// - Parameter newData: The given data.
    func updateData(_ newData: [FriendsRequestResponse]) {
        data = newData.map(FriendsRequestCellViewModel.init)
    }
}
