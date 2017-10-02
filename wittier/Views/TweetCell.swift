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
}

class TweetCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
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
            timestampLabel.text = tweet.relativeTimestamp
            if tweet.retweeted {
                retweetButton.setImage(#imageLiteral(resourceName: "retweet"), for: .normal)
            }
            rtCountLabel.text = "\(tweet.retweetCount)"
            if tweet.favorited {
                favoriteButton.setImage(#imageLiteral(resourceName: "favorite-blk"), for: .normal)
            }
            favCountLabel.text = "\(tweet.favoritesCount)"
            guard let profileURL = user.profileURL else {
                print("nil profile image")
                profileImageView.image = nil
                return
            }
            profileImageView.setImageWith(profileURL)
            
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
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width * 0.5
        profileImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onReplyButton(_ sender: Any) {
        if let _ = delegate {
            delegate?.replyButtonTapped?(tweetCell: self)
        }
    }
    
    @IBAction func onRetweetButton(_ sender: Any) {
        guard let tweetID = tweet.id else {
            print("bad tweet ID")
            return
        }
        let rtState = tweet.retweeted
        let rtCount = tweet.retweetCount
        if rtState {
            TwitterClient.sharedInstance.unretweet(id: tweetID, success: { (newTweet: Tweet) -> Void in
                self.tweet.retweeted = !rtState
                self.tweet.retweetCount = rtCount - 1
                self.rtCountLabel.text = "\(self.tweet.retweetCount)"
            }, failure: { (error: Error) -> Void in
                print("\(error.localizedDescription)")
            })
        } else {
            TwitterClient.sharedInstance.retweet(id: tweetID, success: { (newTweet: Tweet) -> Void in
                self.tweet.retweeted = !rtState
                self.tweet.retweetCount = rtCount + 1
                self.rtCountLabel.text = "\(self.tweet.retweetCount)"
                
            }, failure: { (error: Error) -> Void in
                print("\(error.localizedDescription)")
            })
        }
    }
    
    @IBAction func onFavoriteButton(_ sender: Any) {
        guard let tweetID = tweet.id else {
            print("bad tweet ID")
            return
        }
        let faveState = tweet.favorited
        let faveCount = tweet.favoritesCount
        if faveState {
            TwitterClient.sharedInstance.unfave(id: tweetID, success: { (newTweet: Tweet) -> Void in
                self.tweet.favorited = !faveState
                self.tweet.favoritesCount = faveCount - 1
                self.favoriteButton.setImage(#imageLiteral(resourceName: "favorite-aaa"), for: .normal)
                self.favCountLabel.text = "\(self.tweet.favoritesCount)"
            }, failure: { (error: Error) -> Void in
                print("\(error.localizedDescription)")
            })
        } else {
            TwitterClient.sharedInstance.fave(id: tweetID, success: { (newTweet: Tweet) -> Void in
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
