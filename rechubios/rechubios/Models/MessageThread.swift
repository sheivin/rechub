//
//  MessageThread.swift
//  rechubios
//  creating iOS model for message thread.
//
//  Created by Sheivin Goyal on 5/8/19.
//  Copyright © 2019 Sheivin Goyal. All rights reserved.
//


import Foundation

class MessageThread: Decodable {
    var id: String
    var title: String
    var unreadCount: Int
    var lastRecommendation: Recommendation?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case unreadCount = "unread_count"
        case lastRecommendation = "last_recommendation"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(String.self, forKey: .id)
        self.title = try values.decode(String.self, forKey: .title)
        self.unreadCount = try values.decode(Int.self, forKey: .unreadCount)
        self.lastRecommendation = try values.decodeIfPresent(Recommendation.self, forKey: .lastRecommendation)
    }
}
