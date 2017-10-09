//
//  TweetViewController.swift
//  wittier
//
//  Created by Angela Yu on 9/26/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit

@objc protocol TweetViewControllerDelegate {
    @objc optional func tweetViewController(tweetViewController: TweetViewController, replyToID: Int64, tweeted string: String)
}

class TweetViewController: UIViewController, UITextViewDelegate {
    // maintweetView outlets
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
    
    // rewteetView outlets
    @IBOutlet weak var retweetView: UIView!
    @IBOutlet weak var retweeterLabel: UILabel!
    @IBOutlet weak var replytweetView: UIView!
    @IBOutlet weak var retweetTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var retweeterDisplayConstraint: NSLayoutConstraint!
    
    // replytweetView outlets
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var composeTextView: UITextView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet var counterTopContstraint: NSLayoutConstraint!
    @IBOutlet var composeCounterConstraint: NSLayoutConstraint!
    @IBOutlet var bottomComposeConstraint: NSLayoutConstraint!
    
    weak var delegate: TweetViewControllerDelegate?
    
    var tweet: Tweet!
    var retweeter: User?
    var replying: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If this is a retweet, show the retweet view
        showOrHideRetweet()
        
        // Populate basic tweet display
        guard let user = tweet.user else { return }
        displayNameLabel.text = user.name
        screennameLabel.text = user.screenname
        tweetLabel.text = tweet.text
        tweetLabel.sizeToFit()
        
        if let profileURL = user.profileURL {
            profileImageView.setImageWith(profileURL)
        } else {
            profileImageView.image = nil
        }
        profileImageView.layer.cornerRadius = 5
        profileImageView.clipsToBounds = true
        
        // Build formatted date
        if let timestamp = tweet.timestamp {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            if let timestampDate = formatter.date(from: timestamp) {
                formatter.dateFormat = "EEE MMM d, h:mm a"
                formatter.amSymbol = "AM"
                formatter.pmSymbol = "PM"
                let detailTimestamp = formatter.string(from: timestampDate)
                timestampLabel.text = detailTimestamp
            }
        }
        
        // Build stats string
        updateStats()
        
        // View setup
        boxView.layer.cornerRadius = 5
        scrollframeView.contentSize = CGSize(width: scrollframeView.frame.size.width, height: boxView.frame.origin.y + boxView.frame.size.height + 20)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // If the user wants to reply
        composeTextView.delegate = self
        if replying {
            print("showing reply")
            onReplyButton(replyButton)
        } else {
            print("hiding reply")
            replytweetView.isHidden = true
            // NSLayoutConstraint.deactivate([counterTopContstraint, composeCounterConstraint, bottomComposeConstraint])
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showOrHideRetweet() {
        if let retweetUser = retweeter {
            if let retweeterName = retweetUser.name {
                retweeterLabel.text = "\(retweeterName) Retweeted"
            } else {
                retweeterLabel.text = "Somebody Retweeted" // shouldn't happen
            }
            retweetView.isHidden = false
            retweetTopConstraint.isActive = true
            retweeterDisplayConstraint.isActive = true
        } else {
            retweetView.isHidden = true
            retweetTopConstraint.isActive = false
            retweeterDisplayConstraint.isActive = false
        }
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
    
    // MARK: - Buttons
    @IBAction func onReplyButton(_ sender: Any) {
        guard let origUser = tweet.user else { return }
        var username = "\(origUser.screenname) "
        if let rtUser = retweeter {
            username.append("\(rtUser.screenname) ")
        }
        let tweetButton = UIBarButtonItem(title: "Tweet", style: .plain, target: self, action: #selector(tweetReply(_:)))
        navigationItem.rightBarButtonItem = tweetButton
        replyButton.setImage(#imageLiteral(resourceName: "reply"), for: .normal)

        composeTextView.text = "\(username)"
        let length = username.count
        DispatchQueue.main.async {
            self.composeTextView.selectedRange = NSRange(location: length, length: 0)
        }
        replytweetView.isHidden = false
        NSLayoutConstraint.activate([counterTopContstraint, composeCounterConstraint, bottomComposeConstraint])
        scrollframeView.contentSize = CGSize(width: scrollframeView.frame.size.width, height: boxView.frame.origin.y + boxView.frame.size.height + 20)
        composeTextView.becomeFirstResponder()

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
                self.updateStats()
            }, failure: { (error: Error) -> Void in
                print("\(error.localizedDescription)")
            })
        } else {
            TwitterClient.sharedInstance.retweet(retweetMe: true, id: tweetID, success: { (newTweet: Tweet) -> Void in
                self.tweet.retweeted = !rtState
                self.tweet.retweetCount = rtCount + 1
                self.updateStats()
            }, failure: { (error: Error) -> Void in
                print("\(error.localizedDescription)")
            })
        }
    }
    
    @IBAction func onFaveButton(_ sender: Any) {
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
                self.updateStats()
            }, failure: { (error: Error) -> Void in
                print("\(error.localizedDescription)")
            })
        } else {
            TwitterClient.sharedInstance.fave(faveMe: true, id: tweetID, success: { (newTweet: Tweet) -> Void in
                self.tweet.favorited = !faveState
                self.tweet.favoritesCount = faveCount + 1
                self.updateStats()
            }, failure: { (error: Error) -> Void in
                print("\(error.localizedDescription)")
            })
        }
    }
    
    // MARK: - Composing a reply
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            var contentInset: UIEdgeInsets = self.scrollframeView.contentInset
            contentInset.bottom = keyboardSize.height
            self.scrollframeView.contentInset = contentInset
            if self.contentView.frame.origin.y == 0 {
                self.contentView.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInset: UIEdgeInsets = UIEdgeInsets.zero
            self.scrollframeView.contentInset = contentInset
            if self.contentView.frame.origin.y != 0 {
                self.contentView.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    // Show countdown from 140 characters
    func textViewDidChange(_ textView: UITextView) {
        let length = composeTextView.text.count
        let charsLeft = 140 - length
        counterLabel.text = String(charsLeft)
        if charsLeft < 20 {
            counterLabel.textColor = UIColor.red
        } else {
            counterLabel.textColor = UIColor.darkGray
        }
    }
    
    func tweetReply(_ sender: Any) {
        guard let tweetText = composeTextView.text else {
            print("nil tweet, canceling")
            return
        }
        
        delegate?.tweetViewController?(tweetViewController: self, replyToID: tweet.idNum!, tweeted: tweetText)
        
    }

}
