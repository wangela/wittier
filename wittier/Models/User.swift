//
//  User.swift
//  wittier
//
//  Created by Angela Yu on 9/26/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit

class User: NSObject {
    // MARK: - Properties
    var name: String?
    var screenname: String = "@"
    var profileURL: URL?
    var profileBackgroundURL: URL?
    var tagline: String?
    var userDictionary: NSDictionary
    var location: String?
    var tweetsCount: String?
    var followerCount: String?
    var followingCount: String?
    
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
    
    // MARK: - Init
    init(dictionary: NSDictionary) {
        self.userDictionary = dictionary
        super.init()
        
        name = dictionary["name"] as? String
        
        guard let sn = dictionary["screen_name"] as? String else {
            print("empty screenname")
            return
        }
        screenname += sn
        
        tagline = dictionary["description"] as? String
        location = dictionary["location"] as? String
        
        setStats(dictionary: dictionary)
        
        guard let profileURLString = dictionary["profile_image_url_https"] as? String else {
            print("error unwrapping profile url string")
            return
        }
        profileURL = URL(string: profileURLString)
        
        if let profileBackgroundURLString = dictionary["profile_banner_url"] as? String {
            profileBackgroundURL = URL(string: profileBackgroundURLString)
        } else {
            print("no bg profile url string")
            profileBackgroundURL = nil
            return
        }
    }
    
    func setStats(dictionary: NSDictionary) {
        var numberFormatter: NumberFormatter {
            let formattedNumber = NumberFormatter()
            formattedNumber.numberStyle = .decimal
            formattedNumber.maximumFractionDigits = 0
            return formattedNumber
        }
        
        if let tweetsCountInt = dictionary["statuses_count"] as? Int64 {
            let tweetsCountNum = tweetsCountInt as NSNumber
            tweetsCount = numberFormatter.string(from: tweetsCountNum)
        }
        if let followerCountInt = dictionary["followers_count"] as? Int64 {
            let followerCountNum = followerCountInt as NSNumber
            followerCount = numberFormatter.string(from: followerCountNum)
        }
        if let followingCountInt = dictionary["friends_count"] as? Int64 {
            let followingCountNum = followingCountInt as NSNumber
            followingCount = numberFormatter.string(from: followingCountNum)
        }
    }
}
