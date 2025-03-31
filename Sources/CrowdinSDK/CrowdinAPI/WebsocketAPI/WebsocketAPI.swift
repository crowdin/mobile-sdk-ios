//
//  WebsocketAPI.swift
//  CrowdinSDK
//
//  Created on 3/22/2025.
//  Updated on 3/23/2025.
//

import Foundation
import BaseAPI

class WebsocketAPI: CrowdinAPI {
    override var apiPath: String {
        "user/websocket-ticket"
    }
    
    // Ticket cache for reducing API requests
    private let ticketCache: WebsocketTicketCache
    
    // Queue for managing ticket requests
    private struct PendingRequest {
        let event: String
        let mode: String
        let completion: (WebsocketTicketResponse?, Error?) -> Void
    }
    
    private var isTicketRequestInProgress = false
    private var pendingRequests: [PendingRequest] = []
    private let lock = NSLock()
    
    init(organizationName: String? = nil, auth: CrowdinAuth?) {
        self.ticketCache = WebsocketTicketCache()
        super.init(organizationName: organizationName, auth: auth)
    }
    
    // MARK: - Data Models
    
    struct WebsocketTicketRequest: Codable {
        let event: String
        let context: WebsocketTicketContext
    }
    
    struct WebsocketTicketContext: Codable {
        let mode: String
    }
    
    struct WebsocketTicketResponse: Codable {
        let data: WebsocketTicketData
    }
    
    struct WebsocketTicketData: Codable {
        let ticket: String
    }
    
    // MARK: - Public Methods
    
    /// Get a websocket ticket for the specified event
    /// - Parameters:
    ///   - event: The event name
    ///   - mode: The mode (default: "translate")
    ///   - useCache: Whether to use cached ticket if available (default: true)
    ///   - completion: Completion handler with response or error
    func getWebsocketTicket(event: String, mode: String = "translate", useCache: Bool = true, completion: @escaping (WebsocketTicketResponse?, Error?) -> Void) {
        // Check if we should use cache and have a valid cached ticket
        if useCache, let cachedTicket = ticketCache.getValidTicket() {
            // Use cached ticket
            let response = WebsocketTicketResponse(data: WebsocketTicketData(ticket: cachedTicket))
            DispatchQueue.global().async {
                completion(response, nil)
            }
            return
        }
        
        // Add this request to the queue and process
        addRequestAndProcess(event: event, mode: mode, completion: completion)
    }
    
    // MARK: - Private Methods
    
    /// Add a request to the queue and process it if no request is in progress
    /// - Parameters:
    ///   - event: The event name
    ///   - mode: The mode
    ///   - completion: Completion handler with response or error
    private func addRequestAndProcess(event: String, mode: String, completion: @escaping (WebsocketTicketResponse?, Error?) -> Void) {
        let pendingRequest = PendingRequest(event: event, mode: mode, completion: completion)
        
        // Use a lock to check and update the state atomically
        lock.lock()
        
        // Add the request to the queue
        pendingRequests.append(pendingRequest)
        
        // Check if a request is already in progress
        var shouldStartRequest = false
        if !isTicketRequestInProgress {
            isTicketRequestInProgress = true
            shouldStartRequest = true
        }
        
        lock.unlock()
        
        // Now we can safely check shouldStartRequest
        if shouldStartRequest {
            self.processNextRequest()
        }
    }
    
    /// Process the next request in the queue
    private func processNextRequest() {
        var nextRequest: PendingRequest?
        
        lock.lock()
        if !pendingRequests.isEmpty {
            nextRequest = pendingRequests.first
        }
        lock.unlock()
        
        guard let request = nextRequest else {
            // No more requests to process
            lock.lock()
            isTicketRequestInProgress = false
            lock.unlock()
            return
        }
        
        self.requestNewTicket(event: request.event, mode: request.mode)
    }
    
    /// Request a new ticket from the API
    /// - Parameters:
    ///   - event: The event name
    ///   - mode: The mode
    private func requestNewTicket(event: String, mode: String) {
        let request = WebsocketTicketRequest(event: event, context: WebsocketTicketContext(mode: mode))
        guard let body = try? JSONEncoder().encode(request) else {
            // Failed to encode request
            self.handleRequestFailure(error: NSError(domain: "Failed to encode request", code: 400, userInfo: nil))
            return
        }
        
        let headers = [RequestHeaderFields.contentType.rawValue: "application/json"]
        
        // Use a type annotation to help the compiler infer the generic type
        self.cw_post(url: fullPath, headers: headers, body: body, callbackQueue: DispatchQueue.global()) { [weak self] (response: WebsocketTicketResponse?, error) in
            guard let self = self else { return }
            
            if let response = response {
                // Success - cache the ticket and notify all pending requests
                self.ticketCache.storeTicket(response.data.ticket)
                self.handleRequestSuccess(response: response)
            } else {
                // Failure - try the next request in the queue
                self.handleRequestFailure(error: error)
            }
        }
    }
    
    /// Handle a successful ticket request
    /// - Parameter response: The successful response
    private func handleRequestSuccess(response: WebsocketTicketResponse) {
        var allRequests: [PendingRequest] = []
        
        // Use a lock to get all pending requests and clear the queue atomically
        lock.lock()
        allRequests = pendingRequests
        pendingRequests = []
        isTicketRequestInProgress = false
        lock.unlock()
        
        // Notify all pending requests with the successful response
        for request in allRequests {
            DispatchQueue.global().async {
                request.completion(response, nil)
            }
        }
    }
    
    /// Handle a failed ticket request
    /// - Parameter error: The error that occurred
    private func handleRequestFailure(error: Error?) {
        var failedRequest: PendingRequest?
        var shouldProcessNext = false
        
        // Use a lock to check and update the state atomically
        lock.lock()
        // Remove the failed request from the queue
        if !pendingRequests.isEmpty {
            failedRequest = pendingRequests.removeFirst()
            shouldProcessNext = !pendingRequests.isEmpty
        } else {
            isTicketRequestInProgress = false
        }
        lock.unlock()
        
        // Notify the failed request
        if let request = failedRequest {
            DispatchQueue.global().async {
                request.completion(nil, error)
            }
        }
        
        // Process the next request if there is one
        if shouldProcessNext {
            self.processNextRequest()
        }
    }
}
