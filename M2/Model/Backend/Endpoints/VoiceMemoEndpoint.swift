//
//  VoiceMemoEndpoint.swift
//  M2
//
//  Created by Vincent Friedrich on 03.05.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation
import Alamofire

/// An endpoint for all HTTP-requests regarding voice memo actions.
///
/// - getMemo: Gets a voice memo for a given id.
/// - uploadMemo: Uploads a voice memo for a given user.
/// - deleteMemo: Deletes a voice memo for a given user.
/// - downloadMemo: Downloads a voice memo for a given id.
enum VoiceMemoEndpoint: Endpoint {
    case getMemo(id: String)
    case uploadMemo(id: String, owner: String)
    case deleteMemo(id: String, owner: String)
    case downloadMemo(id: String)
    
    var route: String {
        return "/m2/"
    }
    
    var urlString: String {
        var endpoint = ""
        switch self {
        case .downloadMemo:
            endpoint = "download_voice_memo.php?"
        case .getMemo:
            endpoint = "get_voice_memo.php?"
        case .uploadMemo:
            endpoint = "upload_voice_memo.php?"
        case .deleteMemo:
            endpoint = "delete_voice_memo.php?"
        }
        
        var urlEnd = parameters.flatMap({ (key: String, value: Any) -> String in
            guard let value = value as? String else { fatalError() }
            return key + "=" + value + "&"
        })
        urlEnd.removeLast()
        
        return BackendWorker.hostType.rawValue + route + endpoint + urlEnd
    }
    
    var method: HTTPMethod {
        switch self {
        case .getMemo, .downloadMemo:
            return .get
        case .uploadMemo, .deleteMemo:
            return .post
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        case .getMemo(let id):
            return [
                "message_id" : id
            ]
        case .uploadMemo(let id, let owner):
            return [
                "message_id" : id,
                "owner" : owner
            ]
        case .deleteMemo(let id, let owner):
            return [
                "message_id" : id,
                "owner" : owner
            ]
        case .downloadMemo(let id):
            return [
                "message_id" : id
            ]
        }
    }
}

