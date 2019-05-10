//
//  RecData.swift
//  rechubios
//  ordered dictionary to hold thread information from server.
//
//  Created by Sheivin Goyal on 5/8/19.
//  Copyright © 2019 Sheivin Goyal. All rights reserved.
//


import Foundation

struct RecData: Decodable {
    var keys: [String]
    var values: [String: MessageThread]
    static var currentThread: MessageThread?
    
    enum CodingKeys: String, CodingKey {
        case threads
    }
    
    subscript(key: Int) -> MessageThread {
        get {
            return values[keys[key]]!
        }
    }
    
    subscript(key: String) -> MessageThread? {
        get {
            return values[key]
        }
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let threads = try values.decode([MessageThread].self, forKey: .threads)
        self.values = [:]
        
        for thread in threads {
            self.values[thread.id] = thread
        }
        let threadsOrdered = self.values.sorted(by: ({
            $0.value.lastRecommendation?.sentDate ?? .distantPast > $1.value.lastRecommendation?.sentDate ?? .distantPast
        }))
        self.keys = threadsOrdered.map {$0.value.id}
    }
    
    // handle incoming new recommendation
    public mutating func newRecommendationReceived(_ recommendation: Recommendation) {
        if let thread = self[recommendation.threadId] {
            thread.lastRecommendation = recommendation
            if RecData.currentThread?.id != thread.id {
                thread.unreadCount += 1
            }
            self.keys = keys.filter { $0 != thread.id }
            self.keys.insert(thread.id, at: 0)
        }
    }
}
