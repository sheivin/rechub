//
//  User.swift
//  rechubios
//
//  Created by Sheivin Goyal on 5/7/19.
//  Copyright © 2019 Sheivin Goyal. All rights reserved.
//

import Foundation

struct User:Codable {
    static var current:User!
    var id:String
    var username:String
}
