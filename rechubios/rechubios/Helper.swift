//
//  Helper.swift
//  rechubios
//  Helper methods - alert pop
//
//  Created by Sheivin Goyal on 5/7/19.
//  Copyright © 2019 Sheivin Goyal. All rights reserved.
//

import UIKit

class Helper {
    
    static func showAlert(viewController: UIViewController, title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(dismiss)
        viewController.present(alert, animated: true, completion: nil)
    }
}
