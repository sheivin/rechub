//
//  RecTableViewController.swift
//  rechubios
//
//  Created by Sheivin Goyal on 5/7/19.
//  Copyright © 2019 Sheivin Goyal. All rights reserved.
//


import UIKit
import Alamofire

class RecTableViewController: UITableViewController {
    var recData: RecData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib.init(nibName: "ThreadCell", bundle: Bundle.main), forCellReuseIdentifier: "thread")
        self.tableView.rowHeight = 58
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.socketStateChanged(notification:)), name: NSNotification.Name("sockState"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.receivedRecommendation(notification:)), name: NSNotification.Name("receivedRecommendation"), object: nil)
        
        let addRecChannelButton = UIButton(type: UIButton.ButtonType.contactAdd)
        addRecChannelButton.addTarget(self, action: #selector(self.promptAddRecChannel), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addRecChannelButton)
        
        let logoutButton = UIButton(type: UIButton.ButtonType.system)
        logoutButton.setTitle("logout", for: .normal)
        logoutButton.addTarget(self, action: #selector(self.logout), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: logoutButton)
        
        SocketManager.shared.connect()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        RecData.currentThread = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let channelViewController = segue.destination as? ChannelViewController {
            let thread = sender as! MessageThread
            thread.unreadCount = 0
            RecData.currentThread = thread
            self.tableView.reloadData()
        }
    }
    
    // socket connection state changes
    @objc func socketStateChanged(notification: Notification) {
        if let status = notification.object as? Int {
            if status == 1 {
                self.reloadRecTable()
            }
            self.title = status == 1 ? "Rechub": "Loading..."
        }
    }
    
    // reload rec table
    @objc func reloadRecTable() {
        Alamofire.request(API_HOST + "/messaging/load-rectable").responseData {
            response in
            switch response.result {
                case .success(let data):
                    do {
                        self.recData = try JSONDecoder().decode(RecData.self, from: data)
                        self.tableView.reloadData()
                    } catch {
                        Helper.showAlert(viewController: self, title: "Oh!", message: error.localizedDescription)
                }
                case .failure(let error):
                    Helper.showAlert(viewController: self, title: "Oh!", message: error.localizedDescription)
            }
        }
    }
    
    // handle receiving new recommendation
    @objc func receivedRecommendation(notification: Notification) {
        if let recommendation = notification.object as? Recommendation {
            recData?.newRecommendationReceived(recommendation)
            self.tableView.reloadData()
        }
    }
    
    // add prompt for adding rec channel
    @objc func promptAddRecChannel() {
        let alert = UIAlertController(title: "New Channel", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        let dismissAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(dismissAction)
        let addAction = UIAlertAction(title: "Add", style: .default, handler: { _ in
            self.addRecChannel(title: alert.textFields![0].text!)
        })
        
        alert.addAction(addAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // add rec channel
    func addRecChannel(title: String) {
        let params = ["title": title] as [String: Any]
        Alamofire.request(API_HOST + "/messaging/add-group", method: .post, parameters: params).response {
            response in
            if let err = response.error {
                print(err.localizedDescription)
            } else {
                self.reloadRecTable()
            }
        }
    }
    
    // handle logout
    @objc func logout() {
        User.current = nil
        SocketManager.shared.sock.disconnect()
        UserDefaults.standard.setValue(nil, forKey: "user")
        Alamofire.request(API_HOST + "/auth/logout")
        self.navigationController?.popToRootViewController(animated: true)
    }
}
    
extension RecTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "recTableToChannel", sender: recData?[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recData?.values.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "thread") as! ThreadCell
        if let thread = recData?[indexPath.row] {
            if thread.unreadCount > 0 {
                cell.titleLabel.text = thread.title + " (" + String(thread.unreadCount) + ")"
                cell.backgroundColor = UIColor.init(red: 0xB7 / 255, green: 0xFA / 255, blue: 0xDE / 255, alpha: 0.3)
            } else {
                cell.titleLabel.text = thread.title
                cell.backgroundColor = UIColor.clear
            }
            
            cell.previewLabel.text = thread.lastRecommendation?.description
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
}
