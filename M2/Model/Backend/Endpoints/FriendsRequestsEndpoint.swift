//
//  FriendsRequestsEndpoint.swift
//  M2
//
//  Created by Vincent Friedrich on 13.04.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation
import Alamofire

/// An endpoint for all HTTP-requests regarding friends requests actions.
///
/// - getFriendsRequests: Gets all friends requests for a user.
/// - sendFriendsRequests: Sends a friends request to a user.
/// - answerFriendsRequests: Answers a friends request.
/// - deleteFriendsRequest: Deletes a friends request.
enum FriendsRequestsEndpoint: Endpoint {
    case getFriendsRequests(requester: String)
    case sendFriendsRequests(requester: String, receiver: String)
    case answerFriendsRequests(id: Int, requester: String, state: FriendsRequestResponse.FriendsRequestState)
    case deleteFriendsRequest(id: Int)
    
    var urlString: String {
        var endpoint = ""
        switch self {
        case .getFriendsRequests:
            endpoint = "get_friends_requests.php"
        case .sendFriendsRequests:
            endpoint = "send_friends_request.php"
        case .answerFriendsRequests:
            endpoint = "answer_friends_request.php"
        case .deleteFriendsRequest:
            endpoint = "delete_friends_request.php"
        }
        return BackendWorker.hostType.rawValue + route + endpoint
    }
    
    var method: HTTPMethod {
        switch self {
        case .getFriendsRequests:
            return .get
        case .sendFriendsRequests, .answerFriendsRequests, .deleteFriendsRequest:
            return .post
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        case .answerFriendsRequests(let id, let requester, let state):
            return [
                "id" : id,
                "requester" : requester,
                "state" : state.rawValue
            ]
        case .getFriendsRequests(let requester):
            return [
                "requester" : requester
            ]
        case .sendFriendsRequests(let requester, let receiver):
            return [
                "requester" : requester,
                "receiver" : receiver
            ]
        case .deleteFriendsRequest(let id):
            return [
                "id" : id
            ]
        }
    }
}
