//
//  TweetViewController.swift
//  wittier
//
//  Created by Angela Yu on 9/26/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit

class TweetViewController: UIViewController {
    @IBOutlet weak var scrollframeView: UIScrollView!
    @IBOutlet weak var boxView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var statsLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var faveButton: UIButton!
    @IBOutlet weak var retweetView: UIView!
    @IBOutlet weak var retweeterLabel: UILabel!
    
    var tweet: Tweet!
    var retweeter: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        boxView.layer.cornerRadius = 5
        
        if let retweetUser = retweeter {
            if let retweeterName = retweetUser.name {
                retweeterLabel.text = "\(retweeterName) Retweeted"
            } else {
                retweeterLabel.text = "Somebody Retweeted"
            }
            retweetView.isHidden = false
            print("\(retweeterLabel.text)")
        } else {
            print("nil retweeter")
            retweetView.isHidden = true
        }

        guard let user = tweet.user else {
            print("nil user")
            return
        }
        displayNameLabel.text = user.name
        screennameLabel.text = user.screenname
        tweetLabel.text = tweet.text
        timestampLabel.text = tweet.detailTimestamp
        let statsString = "\(tweet.retweetCount) Retweets  \(tweet.favoritesCount) Likes"
        statsLabel.text = statsString
        if tweet.favorited {
            faveButton.setImage(#imageLiteral(resourceName: "favorite-blk"), for: .normal)
        } else {
            faveButton.setImage(#imageLiteral(resourceName: "favorite-aaa"), for: .normal)
        }
        if tweet.retweeted {
            retweetButton.setImage(#imageLiteral(resourceName: "retweet"), for: .normal)
        } else {
            retweetButton.setImage(#imageLiteral(resourceName: "retweet-aaa"), for: .normal)
        }
        
        guard let profileURL = user.profileURL else {
            print("nil profile image")
            profileImageView.image = nil
            return
        }
        profileImageView.setImageWith(profileURL)
        profileImageView.layer.cornerRadius = 5
        profileImageView.clipsToBounds = true
        
        scrollframeView.contentSize = CGSize(width: scrollframeView.frame.size.width, height: boxView.frame.origin.y + boxView.frame.size.height + 20)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateStats() {
        let statsString = "\(tweet.retweetCount) Retweets  \(tweet.favoritesCount) Likes"
        statsLabel.text = statsString
        if tweet.favorited {
            faveButton.setImage(#imageLiteral(resourceName: "favorite-blk"), for: .normal)
        } else {
            faveButton.setImage(#imageLiteral(resourceName: "favorite-aaa"), for: .normal)
        }
        if tweet.retweeted {
            retweetButton.setImage(#imageLiteral(resourceName: "retweet"), for: .normal)
        } else {
            retweetButton.setImage(#imageLiteral(resourceName: "retweet-aaa"), for: .normal)
        }
    }
    
    @IBAction func onRetweetButton(_ sender: Any) {
        guard let tweetID = tweet.id else {
            print("bad tweet ID")
            return
        }
        let rtState = tweet.retweeted
        print(rtState)
        let rtCount = tweet.retweetCount
        if rtState {
            TwitterClient.sharedInstance.unretweet(id: tweetID, success: { (newTweet: Tweet) -> Void in
                self.tweet = newTweet
                self.tweet.retweeted = !rtState
                self.tweet.retweetCount = rtCount - 1
                self.updateStats()
            }, failure: { (error: Error) -> Void in
                print("\(error.localizedDescription)")
            })
        } else {
            TwitterClient.sharedInstance.retweet(id: tweetID, success: { (newTweet: Tweet) -> Void in
                self.tweet = newTweet
                self.tweet.retweeted = !rtState
                self.tweet.retweetCount = rtCount + 1
                self.updateStats()
            }, failure: { (error: Error) -> Void in
                print("\(error.localizedDescription)")
            })
        }
    }
    
    @IBAction func onFaveButton(_ sender: Any) {
        guard let tweetID = tweet.id else {
            print("bad tweet ID")
            return
        }
        let faveState = tweet.favorited
        print(faveState)
        let faveCount = tweet.favoritesCount
        if faveState {
            TwitterClient.sharedInstance.unfave(id: tweetID, success: { (newTweet: Tweet) -> Void in
                self.tweet = newTweet
                self.tweet.favorited = !faveState
                self.tweet.favoritesCount = faveCount - 1
                self.updateStats()
            }, failure: { (error: Error) -> Void in
                print("\(error.localizedDescription)")
            })
        } else {
            TwitterClient.sharedInstance.fave(id: tweetID, success: { (newTweet: Tweet) -> Void in
                self.tweet = newTweet
                self.tweet.favorited = !faveState
                self.tweet.favoritesCount = faveCount + 1
                self.updateStats()
            }, failure: { (error: Error) -> Void in
                print("\(error.localizedDescription)")
            })
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
