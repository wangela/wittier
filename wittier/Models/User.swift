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
    
    init(dictionary: NSDictionary) {
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

}
