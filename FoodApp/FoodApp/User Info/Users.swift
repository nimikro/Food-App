//
//  Users.swift
//  FoodApp
//
//  Created by Nikolaos Mikrogeorgiou on 11/12/21.
//

import UIKit

class Users: Codable {
    
    static let currentUser = Users()
    
    var username: String = ""
    var email: String = ""
    var password: String = ""
    var isLoggedIn: Bool = false
    var savedRecipes: [FoodTableViewCellViewModel] = []
    var index: Int = 0
    
}
