//
//  TweetViewController.swift
//  wittier
//
//  Created by Angela Yu on 9/26/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit

class TweetViewController: UIViewController {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var statsLabel: UILabel!
    
    var tweet: Tweet! {
        didSet {
            guard let user = tweet.user as User! else {
                print("nil user")
                return
            }
            if let name = user.name as String! {
                print("\(name)")
                displayNameLabel.text = name
            } else {
                print("nil name")
            }
            screennameLabel.text = user.screenname
            tweetLabel.text = tweet.text
            timestampLabel.text = tweet.timestamp
            let statsString = "\(tweet.retweetCount) Retweets  \(tweet.favoritesCount) Likes"
            statsLabel.text = statsString
            guard let profileURL = user.profileURL else {
                print("nil profile image")
                profileImageView.image = nil
                return
            }
            profileImageView.setImageWith(profileURL)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
