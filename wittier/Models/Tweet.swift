//
//  Tweet.swift
//  wittier
//
//  Created by Angela Yu on 9/26/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit

extension Date {
    var yearsFromNow:   Int { return Calendar.current.dateComponents([.year],       from: self, to: Date()).year        ?? 0 }
    var monthsFromNow:  Int { return Calendar.current.dateComponents([.month],      from: self, to: Date()).month       ?? 0 }
    var weeksFromNow:   Int { return Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear  ?? 0 }
    var daysFromNow:    Int { return Calendar.current.dateComponents([.day],        from: self, to: Date()).day         ?? 0 }
    var hoursFromNow:   Int { return Calendar.current.dateComponents([.hour],       from: self, to: Date()).hour        ?? 0 }
    var minutesFromNow: Int { return Calendar.current.dateComponents([.minute],     from: self, to: Date()).minute      ?? 0 }
    var secondsFromNow: Int { return Calendar.current.dateComponents([.second],     from: self, to: Date()).second      ?? 0 }
    var relativeTime: String {
        if yearsFromNow   > 0 { return "\(yearsFromNow) year"    + (yearsFromNow    > 1 ? "s" : "") + " ago" }
        if monthsFromNow  > 0 { return "\(monthsFromNow) month"  + (monthsFromNow   > 1 ? "s" : "") + " ago" }
        if weeksFromNow   > 0 { return "\(weeksFromNow) week"    + (weeksFromNow    > 1 ? "s" : "") + " ago" }
        if daysFromNow    > 0 { return daysFromNow == 1 ? "Yesterday" : "\(daysFromNow) days ago" }
        if hoursFromNow   > 0 { return "\(hoursFromNow) hour"     + (hoursFromNow   > 1 ? "s" : "") + " ago" }
        if minutesFromNow > 0 { return "\(minutesFromNow) minute" + (minutesFromNow > 1 ? "s" : "") + " ago" }
        if secondsFromNow > 0 { return secondsFromNow < 15 ? "Just now"
            : "\(secondsFromNow) second" + (secondsFromNow > 1 ? "s" : "") + " ago" }
        return ""
    }
}

struct Entities {
    struct Hashtag {
        let text: String
        let indices: [Int]
        
        init(dictionary: [String: Any]) {
            self.text = dictionary["text"] as? String ?? ""
            self.indices = dictionary["indices"] as? [Int] ?? [0, 0]
        }
    }
    struct Mention {
        let screenname: String
        let name: String
        let id: Int64
        let indices: [Int]
        
        init(dictionary: [String: Any]) {
            self.screenname = dictionary["screen_name"] as? String ?? ""
            self.name = dictionary["name"] as? String ?? ""
            self.id = dictionary["id"] as? Int64 ?? 0
            self.indices = dictionary["indices"] as? [Int] ?? [0, 0]
        }
    }
    struct Link {
        let url: URL
        let expandedURL: URL
        let displayURL: String
        let indices: [Int]?
        
        init(dictionary: [String: Any]) {
            let urlString = dictionary["url"] as? String ?? ""
            let expandedURLString = dictionary["expanded_url"] as? String ?? ""
            self.url = URL(string: urlString)!
            self.expandedURL = URL(string: expandedURLString)!
            self.displayURL = dictionary["display_url"] as? String ?? ""
            self.indices = dictionary["indices"] as? [Int] ?? [0, 0]
        }
    }
    
    let hashtags: [Hashtag]?
    let mentions: [Mention]?
    let links: [Link]?
    
    init(dictionary: [String: Any]) {
        if let hashtagsDicts = dictionary["hashtags"] as? [[String: Any]] {
            var hashtagsArray: [Entities.Hashtag] = []
            for dict in hashtagsDicts {
                let nextHashtag = Entities.Hashtag(dictionary: dict)
                hashtagsArray.append(nextHashtag)
            }
            self.hashtags = hashtagsArray
        } else { self.hashtags = nil}
        if let mentionsDicts = dictionary["user_mentions"] as? [[String: Any]] {
            var mentionsArray: [Entities.Mention] = []
            for dict in mentionsDicts {
                let nextMention = Entities.Mention(dictionary: dict)
                print("\(nextMention)")
                mentionsArray.append(nextMention)
            }
            self.mentions = mentionsArray
        } else {
            self.mentions = nil
        }
        if let linksDicts = dictionary["urls"] as? [[String: Any]] {
            var linksArray: [Entities.Link] = []
            for dict in linksDicts {
                let nextLink = Entities.Link(dictionary: dict)
                linksArray.append(nextLink)
            }
            self.links = linksArray
        } else { self.links = nil }
    }
}

class Tweet: NSObject {
    var id: Int64?
    var user: User?
    var text: String?
    var replyCount: Int = 0
    var retweetCount: Int = 0
    var favoritesCount: Int = 0
    var retweeted: Bool = false
    var favorited: Bool = false
    var timestamp: String?
    var relativeTimestamp: String?
    var detailTimestamp: String?
    var retweeted_status: Tweet?
    var entities: Entities?
    
    init(dictionary: NSDictionary) {
        guard let userDict = dictionary["user"] as? NSDictionary else {
            print("error unwrapping user from tweet")
            return
        }
        user = User(dictionary: userDict)
        
        id = dictionary["id"] as? Int64
        text = dictionary["text"] as? String
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favoritesCount = (dictionary["favorite_count"] as? Int) ?? 0
        retweeted = (dictionary["retweeted"] as? Bool) ?? false
        favorited = (dictionary["favorited"] as? Bool) ?? false
        
        guard let timestampString = dictionary["created_at"] as? String else {
            print("bad timestamp")
            return
        }
        timestamp = timestampString
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        guard let timestampDate = formatter.date(from: timestampString) else {
            print("bad timestamp")
            return
        }
        relativeTimestamp = timestampDate.relativeTime
        formatter.dateFormat = "EEE MMM d, h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        detailTimestamp = formatter.string(from: timestampDate)
        
        if let ogTweetValue = dictionary["retweeted_status"] {
            let ogTweetDict = ogTweetValue as! NSDictionary
            retweeted_status = Tweet(dictionary: ogTweetDict)

        }

        if let entitiesDict = dictionary["entities"] {
            print("entities found")
            let entitiesDictionary = entitiesDict as! [String: Any]
            let entities = Entities(dictionary: entitiesDictionary)
            if let hashtags = entities.hashtags {
                print(hashtags)
                print("\(hashtags.count) hashtags found")
                for hashtag in hashtags {
                    print("#\(hashtag.text)")
                }
            }
            if let mentions = entities.mentions {
                print("\(mentions.count) mentions found")
                for mention in mentions {
                    print("changing mentions text \(mention.screenname)")
                }
            }
            if let links = entities.links {
                print("\(links.count) links found")
                for link in links {
                    print("changing links text \(link.displayURL)")
                }
            }
        }
    }
    
    class func tweetsWithArray(dictionaries: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in dictionaries {
            dump(dictionary)
            let tweet = Tweet(dictionary: dictionary)
            tweets.append(tweet)
        }
        
        return tweets
    }
}
