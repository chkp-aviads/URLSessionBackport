//
//  AsyncBytesResponse.swift
//  URLSessionBackport
//
//  Created by Dimitri Bouniol on 2021-11-11.
//  Copyright © 2021 Mochi Development, Inc. All rights reserved.
//

import Foundation

#if compiler(>=5.5.2)
final class AsyncBytesResponse {
    private let task: URLSessionDataTask
    private let taskDelegate: SessionDelegateProxy
    private let delegate: URLSessionTaskDelegate?
    
    // If we got response sooner than we requested it, we want to store it
    private var response: Result<URLResponse, Swift.Error>? {
        didSet {
            if let response {
                responseContinuation?.resume(with: response)
            }
        }
    }
    
    // If we requested response, but we don't yet have it, save this continuation so we can resume once we have it
    private var responseContinuation: CheckedContinuation<URLResponse, Swift.Error>?
    
    init(
        task: URLSessionDataTask,
        taskDelegate: SessionDelegateProxy,
        delegate: URLSessionTaskDelegate?
    ) {
        self.task = task
        self.taskDelegate = taskDelegate
        self.delegate = delegate
    }
    
    private func asyncBytes() -> URLSession.Backport.AsyncBytes {
        return URLSession.Backport.AsyncBytes(
            task: task,
            dataStream: AsyncThrowingStream { continuation in
                taskDelegate.addTaskDelegate(
                    task: task,
                    delegate: delegate,
                    dataStream: continuation,
                    response: { response in
                        self.response = response
                    }
                )
            }
        )
    }
    
    private func response() async throws -> URLResponse {
        return try await withCheckedThrowingContinuation { continuation in
            if let response {
                continuation.resume(with: response)
            } else {
                responseContinuation = continuation
            }
        }
    }
    
    func bytes(block: @escaping (URLSession.Backport.AsyncBytes, URLResponse) -> ()) {
        Task {
            block(asyncBytes(), try await response())
        }
    }
}
#endif
