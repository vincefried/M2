//
//  ChatEndpoint.swift
//  M2
//
//  Created by Vincent Friedrich on 13.04.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation
import Alamofire

/// An endpoint for all HTTP-requests regarding chat actions.
///
/// - getChats: Gets all available chats for a user.
enum ChatEndpoint: Endpoint {
    case getChats(requester: String)
    
    var route: String {
        return "/m2/"
    }
    
    var urlString: String {
        var endpoint = ""
        switch self {
        case .getChats:
            endpoint = "get_chats.php"
        }
        return BackendWorker.hostType.rawValue + route + endpoint
    }
    
    var method: HTTPMethod {
        switch self {
        case .getChats:
            return .get
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        case .getChats(let requester):
            return [
                "requester" : requester
            ]
        }
    }
}
