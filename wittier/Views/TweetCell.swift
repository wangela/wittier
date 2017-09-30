//
//  TweetCell.swift
//  wittier
//
//  Created by Angela Yu on 9/26/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit
import AFNetworking

class TweetCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var rtCountLabel: UILabel!
    @IBOutlet weak var favCountLabel: UILabel!
    @IBOutlet weak var superContentView: UIView!
    @IBOutlet weak var retweetView: UIView!
    @IBOutlet weak var retweeterLabel: UILabel!
    
    var tweet: Tweet! {
        didSet {
            guard let user = tweet.user else {
                print("nil user")
                return
            }
            print("\(user.name)")
            displayNameLabel.text = user.name
            screennameLabel.text = user.screenname
            tweetLabel.text = tweet.text
            print("\(tweetLabel.text)")
            timestampLabel.text = tweet.relativeTimestamp
            rtCountLabel.text = "\(tweet.retweetCount)"
            favCountLabel.text = "\(tweet.favoritesCount)"
            guard let profileURL = user.profileURL else {
                print("nil profile image")
                profileImageView.image = nil
                return
            }
            profileImageView.setImageWith(profileURL)
            if let retweetUser = retweeter {
                retweeterLabel.text = "\(retweetUser.name) Retweeted"
                print("\(retweeterLabel.text)")
            }

        }
    }
    var retweeter: User?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if retweeter != nil {
            print("retweeter exists")
            retweetView.isHidden = false
        } else {
            print("nil retweeter")
            retweetView.isHidden = true
        }
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width * 0.5
        profileImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
