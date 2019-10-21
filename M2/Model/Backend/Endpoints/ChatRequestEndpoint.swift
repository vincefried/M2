//
//  ChatRequestEndpoint.swift
//  M2
//
//  Created by Vincent Friedrich on 14.07.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation
import Alamofire

/// An endpoint for all HTTP-requests regarding chat request actions.
///
/// - setActiveChat: Sets the active chat between a requester and a receiver.
/// - getActiveChat: Gets the active chat for a given user.
enum ChatRequestEndpoint: Endpoint {
    case setActiveChat(requester: String, receiver: String)
    case getActiveChat(username: String)

    var route: String {
        return "/m2/"
    }
    
    var urlString: String {
        var endpoint = ""
        switch self {
        case .setActiveChat:
            endpoint = "set_active_chat.php"
        case .getActiveChat:
            endpoint = "get_active_chat.php"
        }
        return BackendWorker.hostType.rawValue + route + endpoint
    }
    
    var method: HTTPMethod {
        switch self {
        case .setActiveChat:
            return .post
        case .getActiveChat:
            return .get
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        case .setActiveChat(let requester, let receiver):
            return [
                "requester" : requester,
                "receiver" : receiver
            ]
        case .getActiveChat(let username):
            return [
                "username" : username
            ]
        }
    }
}

