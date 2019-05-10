//
//  SocketManager.swift
//  rechubios
//
//  Created by Sheivin Goyal on 5/8/19.
//  Copyright © 2019 Sheivin Goyal. All rights reserved.
//


import Foundation
import Starscream
import SwiftyJSON

class SocketManager: WebSocketDelegate {
    static let shared = SocketManager()
    
    var sock: WebSocket!
    
    func connect() {
        let request = NSMutableURLRequest(url: URL(string:"ws://localhost:8000/connect")!)
        request.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: HTTPCookieStorage.shared.cookies!)
        sock = WebSocket.init(request: request as URLRequest)
        sock.delegate = self
        sock.connect()
    }
    
    func sendMessage(_ text: String, threadId: String) {
        let payload = ["message": ["text": text, "id": threadId]]
        if let jsonString = JSON(payload).rawString() {
            self.sock.write(string: jsonString)
        }
    }
    
    // handles connect
    func websocketDidConnect(socket: WebSocketClient) {
        NotificationCenter.default.post(name: Notification.Name("sockSate"), object: 1)
    }
    
    // handles disconnect
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        if User.current != nil {
            print("attempting reconnection...")
            NotificationCenter.default.post(name: NSNotification.Name.init("sockState"), object: 0)
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                self.sock.connect()
            })
        } else {
            print("disconnected")
        }
    }
    
    // received message
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        if let data = text.data(using: .utf8) {
            do {
                let recommendation = try JSONDecoder().decode(Recommendation.self, from: data)
                NotificationCenter.default.post(name: NSNotification.Name("receivedMessage"), object: recommendation)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    // unused
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("data received")
    }
}
