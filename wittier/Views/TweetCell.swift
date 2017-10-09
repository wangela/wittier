//
//  TweetCell.swift
//  wittier
//
//  Created by Angela Yu on 9/26/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit
import AFNetworking

@objc protocol TweetCellDelegate {
    @objc optional func replyButtonTapped(tweetCell: TweetCell)
    
    @objc optional func profileButtonTapped(tweetCell: TweetCell)
}

extension Date {
    var yearsFromNow:   Int { return Calendar.current.dateComponents([.year],
                                                                     from: self, to: Date()).year        ?? 0 }
    var monthsFromNow:  Int { return Calendar.current.dateComponents([.month],
                                                                     from: self, to: Date()).month       ?? 0 }
    var weeksFromNow:   Int { return Calendar.current.dateComponents([.weekOfYear],
                                                                     from: self, to: Date()).weekOfYear  ?? 0 }
    var daysFromNow:    Int { return Calendar.current.dateComponents([.day],
                                                                     from: self, to: Date()).day         ?? 0 }
    var hoursFromNow:   Int { return Calendar.current.dateComponents([.hour],
                                                                     from: self, to: Date()).hour        ?? 0 }
    var minutesFromNow: Int { return Calendar.current.dateComponents([.minute],
                                                                     from: self, to: Date()).minute      ?? 0 }
    var secondsFromNow: Int { return Calendar.current.dateComponents([.second],
                                                                     from: self, to: Date()).second      ?? 0 }
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

class TweetCell: UITableViewCell {
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var rtCountLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var favCountLabel: UILabel!
    @IBOutlet weak var superContentView: UIView!
    @IBOutlet weak var retweetView: UIView!
    @IBOutlet weak var retweeterLabel: UILabel!
    
    var delegate: TweetCellDelegate?
    var retweeter: User?
    var tweet: Tweet! {
        didSet {
            guard let user = tweet.user else {
                print("nil user")
                return
            }
            displayNameLabel.text = user.name
            screennameLabel.text = user.screenname
            tweetLabel.text = tweet.text
            tweetLabel.sizeToFit()
            
            if let profileURL = user.profileURL {
                profileButton.setBackgroundImageFor(.normal, with: profileURL)
            } else {
                profileButton.setImage(nil, for: .normal)
            }
            
            // Build relative timestamp
            if let timestamp = tweet.timestamp {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
                if let timestampDate = formatter.date(from: timestamp) {
                    let relativeTimestamp = timestampDate.relativeTime
                    timestampLabel.text = relativeTimestamp
                }
            }
            
            showStats()
            showRetweet()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileButton.layer.cornerRadius = profileButton.frame.size.width * 0.5
        profileButton.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func showStats() {
        // Show retweet stats
        if tweet.retweeted {
            retweetButton.setImage(#imageLiteral(resourceName: "retweet"), for: .normal)
        } else {
            retweetButton.setImage(#imageLiteral(resourceName: "retweet-aaa"), for: .normal)
        }
        rtCountLabel.text = "\(tweet.retweetCount)"
        
        // Show favorite stats
        if tweet.favorited {
            favoriteButton.setImage(#imageLiteral(resourceName: "favorite-blk"), for: .normal)
        } else {
            favoriteButton.setImage(#imageLiteral(resourceName: "favorite-aaa"), for: .normal)
        }
        favCountLabel.text = "\(tweet.favoritesCount)"
    }
    
    func showRetweet() {
        // Show retweet info if this is a retweet
        if let retweetUser = retweeter {
            if let retweeterName = retweetUser.name {
                retweeterLabel.text = "\(retweeterName) Retweeted"
            } else {
                retweeterLabel.text = "Somebody Retweeted"
            }
            retweetView.isHidden = false
        } else {
            retweetView.isHidden = true
        }
    }

    @IBAction func onProfileButton(_ sender: Any) {
        if let _ = delegate {
            delegate?.profileButtonTapped?(tweetCell: self)
        }
    }
    
    @IBAction func onReplyButton(_ sender: Any) {
        if let _ = delegate {
            delegate?.replyButtonTapped?(tweetCell: self)
        }
    }
    
    @IBAction func onRetweetButton(_ sender: Any) {
        guard let tweetID = tweet.idNum else {
            print("bad tweet ID")
            return
        }
        let rtState = tweet.retweeted
        let rtCount = tweet.retweetCount
        if rtState {
            TwitterClient.sharedInstance.retweet(retweetMe: false, id: tweetID, success: { (newTweet: Tweet) -> Void in
                self.tweet.retweeted = !rtState
                self.tweet.retweetCount = rtCount - 1
                self.retweetButton.setImage(#imageLiteral(resourceName: "retweet-aaa"), for: .normal)
                self.rtCountLabel.text = "\(self.tweet.retweetCount)"
            }, failure: { (error: Error) -> Void in
                print("\(error.localizedDescription)")
            })
        } else {
            TwitterClient.sharedInstance.retweet(retweetMe: true, id: tweetID, success: { (newTweet: Tweet) -> Void in
                self.tweet.retweeted = !rtState
                self.tweet.retweetCount = rtCount + 1
                self.retweetButton.setImage(#imageLiteral(resourceName: "retweet"), for: .normal)
                self.rtCountLabel.text = "\(self.tweet.retweetCount)"
                
            }, failure: { (error: Error) -> Void in
                print("\(error.localizedDescription)")
            })
        }
    }
    
    @IBAction func onFavoriteButton(_ sender: Any) {
        guard let tweetID = tweet.idNum else {
            print("bad tweet ID")
            return
        }
        let faveState = tweet.favorited
        let faveCount = tweet.favoritesCount
        if faveState {
            TwitterClient.sharedInstance.fave(faveMe: false, id: tweetID, success: { (newTweet: Tweet) -> Void in
                self.tweet.favorited = !faveState
                self.tweet.favoritesCount = faveCount - 1
                self.favoriteButton.setImage(#imageLiteral(resourceName: "favorite-aaa"), for: .normal)
                self.favCountLabel.text = "\(self.tweet.favoritesCount)"
            }, failure: { (error: Error) -> Void in
                print("\(error.localizedDescription)")
            })
        } else {
            TwitterClient.sharedInstance.fave(faveMe: true, id: tweetID, success: { (newTweet: Tweet) -> Void in
                self.tweet.favorited = !faveState
                self.tweet.favoritesCount = faveCount + 1
                self.favoriteButton.setImage(#imageLiteral(resourceName: "favorite-blk"), for: .normal)
                self.favCountLabel.text = "\(self.tweet.favoritesCount)"
            }, failure: { (error: Error) -> Void in
                print("\(error.localizedDescription)")
            })
        }
    }
    
}
