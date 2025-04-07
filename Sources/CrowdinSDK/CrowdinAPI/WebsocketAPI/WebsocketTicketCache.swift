//
//  WebsocketTicketCache.swift
//  CrowdinSDK
//
//  Created on 3/23/2025.
//

import Foundation

/// Caching layer for websocket tickets to reduce API requests
class WebsocketTicketCache {
    // Cache for websocket tickets with TTL
    struct CachedTicket {
        let ticket: String
        let expirationDate: Date
        
        var isValid: Bool {
            return Date() < expirationDate
        }
    }
    
    // Cache for websocket tickets
    private var cachedTicket: CachedTicket? = nil
    private let lock = NSLock()
    private let ticketTTL: TimeInterval
    
    init(ticketTTL: TimeInterval = 4 * 60) { // Default 4 minutes in seconds
        self.ticketTTL = ticketTTL
    }
    
    /// Check if a valid ticket exists in the cache
    /// - Returns: The cached ticket if valid, nil otherwise
    func getValidTicket() -> String? {
        lock.lock()
        defer { lock.unlock() }
        
        if let cached = cachedTicket, cached.isValid {
            return cached.ticket
        }
        
        return nil
    }
    
    /// Store a ticket in the cache with an expiration date
    /// - Parameter ticket: The ticket to cache
    func storeTicket(_ ticket: String) {
        lock.lock()
        defer { lock.unlock() }
        
        let expirationDate = Date().addingTimeInterval(self.ticketTTL)
        self.cachedTicket = CachedTicket(ticket: ticket, expirationDate: expirationDate)
    }
    
    /// Clear the cached ticket
    func clearCache() {
        lock.lock()
        defer { lock.unlock() }
        
        self.cachedTicket = nil
    }
}
