//
//  Tweet.swift
//  wittier
//
//  Created by Angela Yu on 9/26/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var user: User?
    var text: String?
    var retweetCount: Int = 0
    var favoritesCount: Int = 0
    var timestamp: Date?
    
    init(dictionary: NSDictionary) {
        guard let userDict = dictionary["user"] as? NSDictionary else {
            print("error unwrapping user from tweet")
            return
        }
        user = User(dictionary: userDict)
        
        text = dictionary["text"] as? String
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favoritesCount = (dictionary["favourites_count"] as? Int) ?? 0
        
        guard let timestampString = dictionary["created_at"] as? String else {
            print("error unwrapping timestamp from json response")
            return
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        timestamp = formatter.date(from: timestampString)
    }
    
    class func tweetsWithArray(dictionaries: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in dictionaries {
            let tweet = Tweet(dictionary: dictionary)
            tweets.append(tweet)
        }
        
        return tweets
    }
}
