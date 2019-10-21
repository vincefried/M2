//
//  FriendsRequestCellViewModel.swift
//  M2
//
//  Created by Vincent Friedrich on 30.03.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation
import SwiftDate

/// A CellViewModel for the friends requests.
class FriendsRequestCellViewModel: CellViewModel<FriendsRequestResponse> {
    /// The text for the name label.
    let nameLabelText: String
    /// The text for the date label.
    let dateLabelText: String
    /// The title for the decline button.
    let declineButtonTitle: String = "  Ablehnen  "
    /// The title for the accept button.
    let acceptButtonTitle: String = "  Akzeptieren  "
    
    override init(data: FriendsRequestResponse) {
        nameLabelText = data.requester
        dateLabelText = Date(timeIntervalSince1970: data.dateCreated).toString(.date(.short))
        super.init(data: data)
    }
    
    /// The action to be invoked, if the user presses the accept button.
    func handleAcceptButtonTapped() {
        answerRequest(state: .accepted)
    }
    
    /// The action to be invoked, if the user presses the decline button.
    func handleDeclineButtonTapped() {
        answerRequest(state: .declined)
    }
    
    /// Answers the friends request for a given state.
    ///
    /// - Parameter state: The given state.
    private func answerRequest(state: FriendsRequestResponse.FriendsRequestState) {
        FriendsRequestsProvider.shared.answerFriendsRequest(friendsRequestResponse: data, state: state)
    }
}
