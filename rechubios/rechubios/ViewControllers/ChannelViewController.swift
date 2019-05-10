//
//  ChannelViewController.swift
//  rechubios
//
//  Created by Sheivin Goyal on 5/9/19.
//  Copyright © 2019 Sheivin Goyal. All rights reserved.
//


import MessageKit
import Alamofire
import SwiftyJSON

class ChannelViewController: MessagesViewController, MessagesDisplayDelegate {
    var recommendations = [Recommendation]()
    var atEnd = false
    var preventLoading = true
    
    var sender: Sender!
    
    struct ChannelData: Decodable {
        var recommendations: [Recommendation]
        var atEnd: Bool
        
        enum CodingKeys: String, CodingKey {
            case recommendations
            case atEnd = "end"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = RecData.currentThread?.title
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.socketStateChanged(notification:)), name: NSNotification.Name("sockState"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.receivedRecommendation(notification:)), name: NSNotification.Name("receivedRecommendation"), object: nil)
        
        self.scrollsToBottomOnKeyboardBeginsEditing = true
        
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        self.loadRecommendations()
    }
    
    // socket connection state changes
    @objc func socketStateChanged(notification: Notification) {
        if let status = notification.object as? Int {
            if status == 0 {
                self.title = "Loading..."
                self.messageInputBar.sendButton.isEnabled = false
            } else if status == 1 {
                self.title = RecData.currentThread?.title
                if self.messageInputBar.inputTextView.text != "" {
                    self.messageInputBar.sendButton.isEnabled = true
                }
            }
        }
    }
    
    // handle receiving new recommendation
    @objc func receivedRecommendation(notification: Notification) {
        if let recommendation = notification.object as? Recommendation {
            if recommendation.threadId == RecData.currentThread?.id {
                self.recommendations.append(recommendation)
                self.messagesCollectionView.insertSections([self.recommendations.count - 1])
                self.messagesCollectionView.scrollToBottom(animated: true)
                
                if recommendation.sender.senderId != currentSender().senderId {
                    if let jsonString = JSON(["read": RecData.currentThread?.id]).rawString() {
                        SocketManager.shared.sock.write(string: jsonString)
                    }
                }
            }
        }
    }
    
    // load recommendations, from within a channel or after view controller loads
    @objc func loadRecommendations() {
        var params: [String: Any] = ["id": RecData.currentThread!.id]
        params["before"] = recommendations.first?.sentDate.timeIntervalSince1970
        
        self.preventLoading = true
        Alamofire.request(API_HOST + "/messaging/load-recommendations", method: .get, parameters: params).responseData {
            response in
            switch response.result {
                case .success(let data):
                    do {
                        let messageData = try JSONDecoder().decode(ChannelData.self, from: data)
                        for item in messageData.recommendations {
                            self.recommendations.insert(item, at: 0)
                        }
                        
                        self.atEnd = messageData.atEnd
                        if self.recommendations.count <= 30 {
                            self.messagesCollectionView.reloadData()
                            self.messagesCollectionView.scrollToBottom()
                        } else {
                            self.messagesCollectionView.reloadDataAndKeepOffset()
                        }
                    } catch {
                        Helper.showAlert(viewController: self, title: "Oh!", message: error.localizedDescription)
                    }
                case .failure(let error):
                    Helper.showAlert(viewController: self, title: "Oh!", message: error.localizedDescription)
            }
            self.preventLoading = false
        }
    }
    
    // detect reaching top
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let navController = self.navigationController, preventLoading == false, atEnd == false {
            let topOffset = navController.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height
            let position = scrollView.contentOffset.y + topOffset
            if position < 0 {
                scrollView.isScrollEnabled = false
                scrollView.isScrollEnabled = true
                scrollView.setContentOffset(.zero, animated: false)
                loadRecommendations()
            }
        }
    }
}

extension ChannelViewController: MessagesDataSource {
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return 1
    }
    
    func currentSender() -> SenderType {
        return sender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return recommendations[indexPath.section]
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return recommendations.count
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if message.sender.senderId == currentSender().senderId {
            return nil
        }
        if indexPath.section - 1 >= 0 {
            let lastRecommendation = self.recommendations[indexPath.section - 1]
            if lastRecommendation.sender.senderId == message.sender.senderId {
                return nil
            }
        }
        
        return NSAttributedString(string: message.sender.displayName, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
}

extension ChannelViewController: MessagesLayoutDelegate {
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    func cellTopLabelAlignment(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LabelAlignment {
        return LabelAlignment.init(textAlignment: .left, textInsets: UIEdgeInsets.init(top: -4, left: 15, bottom: 2.5, right: 0))
    }
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
}

// Input text changing and when send button pressed
extension ChannelViewController: MessageInputBarDelegate {
    func messageInputBar(_ inputBar: MessageInputBar, textViewDidChangeTo text: String) {
        if SocketManager.shared.sock.isConnected == false {
            inputBar.sendButton.isEnabled = false
        }
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        if let threadId = RecData.currentThread?.id {
            inputBar.inputTextView.text = ""
            SocketManager.shared.sendMessage(text, threadId: threadId)
        }
    }
}
