//
//  Recommendation.swift
//  rechubios
//  creating iOS model for recommendation
//
//  Created by Sheivin Goyal on 5/8/19.
//  Copyright © 2019 Sheivin Goyal. All rights reserved.
//


import Foundation
import MessageKit

struct Recommendation: MessageType, Decodable {
    var sender: SenderType
    var messageId: String
    var threadId: String
    var sentDate: Date
    var kind: MessageKind
//    var title: String
    var description: String
    var url: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case date
        case description
        case url
        case senderId = "sender_id"
        case senderName = "sender_name"
        case threadId = "thread_id"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let senderId = try values.decode(String.self, forKey: .senderId)
        let senderName = try values.decode(String.self, forKey: .senderName)
        self.sender = Sender.init(id: senderId, displayName: senderName)
        
        let timestamp = try values.decode(Int.self, forKey: .date)
        self.sentDate = Date.init(timeIntervalSince1970: TimeInterval(timestamp))
        
        self.description = try values.decode(String.self, forKey: .description)
        self.kind = MessageKind.text(self.description)
        
        self.messageId = try values.decode(String.self, forKey: .id)
        self.threadId = try values.decode(String.self, forKey: .threadId)
        
        self.url = try values.decode(String.self, forKey: .url)
    }
}
