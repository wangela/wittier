//
//  User.swift
//  wittier
//
//  Created by Angela Yu on 9/26/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var name: String?
    var screenname: String = "@"
    var profileURL: URL?
    var tagline: String?
    var userDictionary: NSDictionary
    
    init(dictionary: NSDictionary) {
        self.userDictionary = dictionary
        
        name = dictionary["name"] as? String
        
        guard let sn = dictionary["screen_name"] as? String else {
            print("empty screenname")
            return
        }
        screenname += sn
        
        guard let profileURLString = dictionary["profile_image_url_https"] as? String else {
            print("error unwrapping profile url string")
            return
        }
        profileURL = URL(string: profileURLString)
        
        tagline = dictionary["description"] as? String
    }
    
    static let userDidLogoutNotification: Notification.Name = Notification.Name(rawValue: "UserDidLogout")
    static var _currentUser: User?
    
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                let defaults = UserDefaults.standard
                let userData = defaults.object(forKey: "currentUserData") as? Data
                if let userData = userData {
                    let dictionary = try! JSONSerialization.jsonObject(with: userData, options: []) as! NSDictionary
                    _currentUser = User(dictionary: dictionary)
                    print("got existing user")
                }
            }
            return _currentUser
        }
        set(user) {
            _currentUser = user
            
            let defaults = UserDefaults.standard
            if let user = user {
                let data = try! JSONSerialization.data(withJSONObject: user.userDictionary, options: [])
                defaults.set(data, forKey: "currentUserData")
                print("set new user")

            } else {
                defaults.removeObject(forKey: "currentUserData")
                print("remove user")
            }
            defaults.synchronize()
        }
    }
}
