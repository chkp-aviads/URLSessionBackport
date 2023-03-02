//
//  TaskDelegateHandler.swift
//  URLSessionBackport
//
//  Created by Dimitri Bouniol on 2021-11-11.
//  Copyright © 2021 Mochi Development, Inc. All rights reserved.
//

import Foundation

#if compiler(>=5.5.2)
/// A handler for individual task delegates.
///
/// This type boxes the task, user-provided delegate, and dataStream (for streamed asyc methods) so it can be easily accessed by the main session delegate proxy.
/// Note that the handler should be discarded when no longer in use to clean up the task, delegate, and dataStream.
struct TaskDelegateHandler {
    weak var task: URLSessionTask? {
        didSet { // Note: Not sure if this works when ARC sets the weak variable to nil…
            if task == nil {
                delegate = nil
                dataStream = nil
                response = nil
            }
        }
    }
    
    var delegate: URLSessionTaskDelegate?
    var dataStream: AsyncThrowingStream<UInt8, Swift.Error>.Continuation?
    var response: ((Result<URLResponse, Error>) -> Void)?
    
    // MARK: - Convenience Casts
    
    var dataDelegate: URLSessionDataDelegate? { delegate as? URLSessionDataDelegate }
    var downloadDelegate: URLSessionDownloadDelegate? { delegate as? URLSessionDownloadDelegate }
    var streamDelegate: URLSessionStreamDelegate? { delegate as? URLSessionStreamDelegate }
    var webSocketDelegate: URLSessionWebSocketDelegate? { delegate as? URLSessionWebSocketDelegate }
}
#endif
