//
//  LoginViewController.swift
//  rechubios
//
//  Created by Sheivin Goyal on 5/7/19.
//  Copyright © 2019 Sheivin Goyal. All rights reserved.
//


import UIKit
import Alamofire

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check if logged in
        if let data = UserDefaults.standard.data(forKey: "user") {
            didLogin(userData: data)
        }
    }
    
    // Manage actions after pressing return key. If username text field, change to password text field.
    // Attempt login if password text field.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            login(username: self.usernameTextField.text!, password: self.passwordTextField.text!)
        }
        
        return true
    }
    
    // Attempt login.
    func login(username: String, password: String) {
        let user = ["username": username, "password": password] as [String: Any]
        Alamofire.request(API_HOST + "/auth/login", method: .post, parameters: user).responseData
            { response in switch response.result {
            case.success(let data):
                switch response.response?.statusCode ?? -1 {
                    case 200:
                        self.didLogin(userData: data)
                    case 401:
                        Helper.showAlert(viewController: self, title: "Oh!", message: "Username or Password Incorrect")
                    default:
                        Helper.showAlert(viewController: self, title: "Oh!", message: "This should not happen")
                }
            case .failure(let error):
                Helper.showAlert(viewController: self, title: "Oh!", message: error.localizedDescription)
            }
        }
    }
    
    // Successful login. Segue to rectable and initialize current user.
    func didLogin(userData: Data) {
        do {
            User.current = try JSONDecoder().decode(User.self, from: userData)
            usernameTextField.text = ""
            passwordTextField.text = ""
            self.view.endEditing(false)
            self.performSegue(withIdentifier: "loginToRecTable", sender: nil)
        } catch {
            Helper.showAlert(viewController: self, title: "Oh!", message: error.localizedDescription)
        }
    }
    
    // Segue to signup
    @IBAction func goToSignup(sender: UIButton) {
        self.performSegue(withIdentifier: "loginToSignup", sender: nil)
    }
}
