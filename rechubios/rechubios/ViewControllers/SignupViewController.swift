//
//  SignupViewController.swift
//  rechubios
//
//  Created by Sheivin Goyal on 5/7/19.
//  Copyright © 2019 Sheivin Goyal. All rights reserved.
//


import UIKit
import Alamofire

class SignupViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Manage actions after pressing return key. If username text field, change to password text field.
    // Attempt signup if password text field.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            signup(username: usernameTextField.text!, password: passwordTextField.text!)
        }
        
        return true
    }
    
    // Attempt signup.
    func signup(username: String, password: String) {
        let user = ["username": username, "password": password] as [String: Any]
        Alamofire.request(API_HOST + "/auth/signup", method: .post, parameters: user).responseData
            { response in switch response.result {
            case .success(let data):
                switch response.response?.statusCode ?? -1 {
                    case 200:
                        do {
                            User.current = try JSONDecoder().decode(User.self, from: data)
                            self.usernameTextField.text = ""
                            self.passwordTextField.text = ""
                            self.performSegue(withIdentifier: "signupToRecTable", sender: nil)
                        } catch {
                            Helper.showAlert(viewController: self, title: "Oh!", message: error.localizedDescription)
                        }
                    case 401:
                        Helper.showAlert(viewController: self, title: "Oh!", message: "Username in use")
                    default:
                        Helper.showAlert(viewController: self, title: "Oh!", message: "This should not happen")
                }
            case .failure(let error):
                Helper.showAlert(viewController: self, title: "Oh!", message: error.localizedDescription)
            }
        }
    }
}
