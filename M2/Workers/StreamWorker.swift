//
//  StreamWorker.swift
//  M2
//
//  Created by Vincent Friedrich on 26.03.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import Foundation

/// A delegate for the StreamWorker.
protocol StreamWorkerDelegate: class {
    /// Gets called if a stream did open.
    ///
    /// - Parameter stream: The stream that got opened.
    func streamDidOpen(stream: Stream)
    /// Gets called if a stream did close.
    ///
    /// - Parameter stream: The stream that got closed.
    func streamDidClose(stream: Stream)
    /// Gets called if a stream did receive a message.
    ///
    /// - Parameter message: The message that was received.
    func streamDidReceive(message: Message)
    /// Gets called if a stream did receive an active status change.
    ///
    /// - Parameter username: The username which the status changed for.
    func streamDidReceiveChangedActiveStatus(username: String)
    /// Gets called if a stream did receive a friends requests change.
    ///
    /// - Parameter username: The username which the friends requests changed for.
    func streamDidReceiveChangedFriendsRequests(username: String)
}

extension StreamWorkerDelegate {
    // Boilerplate implementation for the StreamWorker functions.
    
    func streamDidOpen(stream: Stream) {}
    func streamDidClose(stream: Stream) {}
    func streamDidReceive(message: Message) {}
    func streamDidReceiveChangedActiveStatus(username: String) {}
    func streamDidReceiveChangedFriendsRequests(username: String) {}
}

/// A worker class for sending and receiving command to and from the stream.
class StreamWorker: NSObject {
    /// Shared instance for singleton usage.
    static let shared = StreamWorker()
    
    /// A type for representing a host.
    ///
    /// - local: localhost
    /// - hetzner: production server without domain
    /// - production: future production server with domain, not yet available
    enum Host: String {
        case local = "localhost"
        case hetzner = "116.203.21.120"
        case production = "neoxapps.de/m2"
    }
    
    /// The port to connect to via tcp.
    let port: Int = 64433
    /// The used used.
    let host: Host = .hetzner
    
    /// The input stream.
    var inputStream: InputStream?
    /// The output stream.
    var outputStream: OutputStream?
    /// If the input stream is active.
    var isInputStreamActive: Bool = false
    /// If the output stream is active.
    var isOutputStreamActive: Bool = false
    
    /// If both streams are active.
    var isActive: Bool {
        return isInputStreamActive && isOutputStreamActive
    }
    
    /// A list of tuples for registering multiple observers.
    private var observers: [(observer: Observer, delegate: StreamWorkerDelegate)]
    
    override init() {
        observers = []
    }
    
    /// Binds an observer to a delegate.
    ///
    /// - Parameters:
    ///   - delegate: The delegate to be bound.
    ///   - observer: The observer to be bound.
    public func bind(delegate: StreamWorkerDelegate, observer: Observer) {
        self.observers.append((observer, delegate))
    }
    
    /// Unbinds an observer.
    ///
    /// - Parameter observer: The observer to be unbound.
    public func unbind(observer: Observer) {
        self.observers.removeAll { $0.observer == observer }
    }
    
    /// Opens the input and output streams.
    func open() {
        Stream.getStreamsToHost(withName: host.rawValue,
                                port: port,
                                inputStream: &inputStream,
                                outputStream: &outputStream)
        
        // Make sure the stream are initialized
        guard let inputStream = inputStream, let outputStream = outputStream else {
            XCGLogger.default.debug("FAIL opening stream")
            return
        }
        
        // Set the delegates
        inputStream.delegate = self
        outputStream.delegate = self
        
        // Schedule both streams in the main loop
        inputStream.schedule(in: .main, forMode: .default)
        outputStream.schedule(in: .main, forMode: .default)
        
        // Open both streams
        inputStream.open()
        outputStream.open()
    }
    
    /// Closes the input and output streams.
    func close() {
        if let inputStream = inputStream {
            inputStream.close()
            inputStream.remove(from: .main, forMode: .default)
            inputStream.delegate = nil
        }
        
        if let outputStream = outputStream {
            outputStream.close()
            outputStream.remove(from: .main, forMode: .default)
            outputStream.delegate = nil
        }
        
        isInputStreamActive = false
        isOutputStreamActive = false
    }
    
    /// Sends an OutgoingStreamable to the stream.
    ///
    /// - Parameter streamable: The OutgoingStreamable that gets sent to the stream.
    func send(streamable: OutgoingStreamable) {
        guard let streamData = try? JSONSerialization.data(withJSONObject: streamable.representation,
                                                           options: .prettyPrinted) else { return }
        send(data: streamData)
    }
    
    /// Sends data to the stream.
    ///
    /// - Parameter data: The data that gets sent to the stream.
    func send(data: Data) {
        guard let outputStream = outputStream else { return }
        DispatchQueue.main.async {
            _ = data.withUnsafeBytes {
                guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                    XCGLogger.default.error("Error sending data")
                    return
                }
                outputStream.write(pointer, maxLength: data.count)
            }
        }
    }
    
    /// Processes a dictionary from the stream into an IncomingStreamable.
    ///
    /// - Parameter dict: The dictionary to be processed.
    private func processIncoming(dict: [String : Any]) {
        // Check if the "cmd" key is contained in the dictionary and initialize a StreamCommand from it
        guard let cmdString = dict["cmd"] as? String,
            let command = StreamCommand(rawValue: cmdString) else { return }
        
        // Switch through the command and initialize the correct IncomingStreamable from the dictionary
        // Register the matching delegate for all observers of StreamWorker
        switch command {
        case .message:
            guard let message = IncomingMessageStreamCommand(object: dict)?.toMessage() else { return }
            observers.forEach { $0.delegate.streamDidReceive(message: message) }
        case .typing:
            guard let message = IncomingTypingStreamCommand(object: dict)?.toMessage() else { return }
            observers.forEach { $0.delegate.streamDidReceive(message: message) }
        case .voicememo:
            guard let message = IncomingVoiceMessageStreamCommand(object: dict)?.toMessage() else { return }
            observers.forEach { $0.delegate.streamDidReceive(message: message) }
        case .changedActive:
            guard let username = IncomingChangedActiveStatusStreamCommand(object: dict)?.requester else { return }
            observers.forEach { $0.delegate.streamDidReceiveChangedActiveStatus(username: username) }
        case .changedFriends:
            guard let username = IncomingChangedFriendsRequestsStreamCommand(object: dict)?.requester else { return }
            observers.forEach { $0.delegate.streamDidReceiveChangedFriendsRequests(username: username) }
        default:
            break
        }
    }
    
    /// Processes the available bytes from the input stream.
    ///
    /// - Parameter stream: The input stream.
    private func proccessAvailableBytes(stream: InputStream) {
        // 1. Initialize buffer
        var buffer = [UInt8](repeating: 0, count: 1024)
        // 2. Read from stream
        let numberBytes = stream.read(&buffer, maxLength: 1024)
        // 3. Convert to NSData
        let dataString = NSData(bytes: &buffer, length: numberBytes)
        // 4. Convert to JSON string
        let jsonString = String(data: dataString as Data, encoding: .utf8)
        
         XCGLogger.default.debug(jsonString)
        
        // 5. Convert json string to dictionary and process result
        if let jsonData = jsonString?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\0", with: "")
            .data(using: .utf8),
            let jsonObject = (try? JSONSerialization.jsonObject(with: jsonData,
                                                                options: [])) as? [String : Any] {
            processIncoming(dict: jsonObject)
        }
    }
}

// MARK: - StreamDelegate
extension StreamWorker: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .openCompleted:
            XCGLogger.default.debug("SUCCESS opening stream")
            
            // Set active flags to true when open completed.
            
            if aStream is InputStream {
                isInputStreamActive = true
            }
            
            if aStream is OutputStream {
                isOutputStreamActive = true
            }
            
            observers.forEach { $0.delegate.streamDidOpen(stream: aStream) }
        case .errorOccurred:
            XCGLogger.default.debug("FAILED opening stream \(String(describing: aStream.streamError))")
            
            // Set active flags to false when error occurred.
            
            if aStream is InputStream {
                isInputStreamActive = false
            }
            
            if aStream is OutputStream {
                isOutputStreamActive = false
            }
            
            observers.forEach { $0.delegate.streamDidClose(stream: aStream) }
        case Stream.Event.endEncountered:
            XCGLogger.default.debug("ENDED stream")
            
            // Set active flags to false when stream end occurred (e.g. no internet connection).
            
            if aStream is InputStream {
                isInputStreamActive = false
            }
            
            if aStream is OutputStream {
                isOutputStreamActive = false
            }
            
            observers.forEach { $0.delegate.streamDidClose(stream: aStream) }
        case Stream.Event.hasBytesAvailable:
            // Process available bytes
            guard let inputStream = aStream as? InputStream else { return }
            proccessAvailableBytes(stream: inputStream)
        default:
            break
        }
    }
}
