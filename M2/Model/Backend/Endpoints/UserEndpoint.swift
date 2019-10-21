//
//  UserEndpoint.swift
//  M2
//
//  Created by Vincent Friedrich on 13.04.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation
import Alamofire

/// An endpoint for all HTTP-requests regarding user actions.
///
/// - login: Logs a user into the backend.
/// - register: Registers a user to the backend.
/// - updateDeviceToken: Updates a user's device token in the backend.
/// - logout: Logs out a user from the backend.
/// - checkUsername: Checks, if a username is available in the backend.
/// - deleteUser: Deletes a user from the backend.
enum UserEndpoint: Endpoint {
    case login(username: String, password: String, deviceToken: String?)
    case register(id: String, username: String, password: String, deviceToken: String?)
    case updateDeviceToken(username: String, deviceToken: String)
    case logout(username: String, password: String)
    case checkUsername(username: String)
    case deleteUser(id: String, username: String, password: String)

    var route: String {
        return "/m2/"
    }
    
    var urlString: String {
        var endpoint = ""
        switch self {
        case .login:
            endpoint = "login.php"
        case .register:
            endpoint = "register.php"
        case .updateDeviceToken:
            endpoint = "update_device_token.php"
        case .logout:
            endpoint = "logout.php"
        case .checkUsername:
            endpoint = "check_username.php"
        case .deleteUser:
            endpoint = "delete_user.php"
        }
        return BackendWorker.hostType.rawValue + route + endpoint
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .checkUsername, .logout:
            return .get
        case .register, .deleteUser, .updateDeviceToken:
            return .post
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        case .checkUsername(let username):
            return [
                "username" : username
            ]
        case .login(let username, let password, let deviceToken):
            return [
                "username" : username,
                "password" : password,
                "device_token" : deviceToken ?? ""
            ]
        case .register(let id, let username, let password, let deviceToken):
            return [
                "id" : id,
                "username" : username,
                "password" : password,
                "device_token" : deviceToken ?? ""
            ]
        case .updateDeviceToken(let username, let deviceToken):
            return [
                "username" : username,
                "device_token" : deviceToken
            ]
        case .logout(let username, let password):
            return [
                "username" : username,
                "password" : password
            ]
        case .deleteUser(let id, let username, let password):
            return [
                "id" : id,
                "username" : username,
                "password" : password
            ]
        }
    }
}
