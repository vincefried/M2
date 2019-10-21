//
//  Streamable.swift
//  M2
//
//  Created by Vincent Friedrich on 26.03.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// A stream command.
///
/// - message: A command for sending a message.
/// - login: A command for logging in a user.
/// - typing: A command for typing a letter of a message.
/// - voicememo: A command for sending a voice memo.
/// - changedActive: A command for changing the active state.
/// - changedFriends: A command for changing the friends requests.
enum StreamCommand: String {
    case message, login, typing = "t", voicememo, changedActive, changedFriends
}

/// A streamable that gets received by the input stream.
protocol IncomingStreamable {
    /// The stream command that is contained in the received streamable.
    var type: StreamCommand { get set }
    /// Initializer with the received dictionary that was parsed from a JSON string.
    ///
    /// - Parameter dict: The dictionary that was parsed from a JSON string.
    init?(object dict: [String : Any])
}

/// A streamable that gets sent by the output stream.
protocol OutgoingStreamable {
    /// The stream command that is contained in the sent streamable.
    var type: StreamCommand { get set }
    /// A dictionary representation of the object to send, to be parsed to JSON string.
    var representation: [String : Any] { get set }
}
