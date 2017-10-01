//
//  TimelineViewController.swift
//  wittier
//
//  Created by Angela Yu on 9/26/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit
import MBProgressHUD

class TimelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ComposeViewControllerDelegate, TweetViewControllerDelegate {
    @IBOutlet weak var tweetsTableView: UITableView!
    
    var tweets: [Tweet]!
    let refreshControl = UIRefreshControl()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tweetsTableView.isHidden = true
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        tweetsTableView.dataSource = self
        tweetsTableView.delegate = self
        tweetsTableView.rowHeight = UITableViewAutomaticDimension
        tweetsTableView.estimatedRowHeight = 300
        
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: .valueChanged)
        tweetsTableView.insertSubview(refreshControl, at: 0)
        
        TwitterClient.sharedInstance.homeTimeline(success: { (tweets: [Tweet]) -> () in
            self.tweets = tweets
            self.tweetsTableView.reloadData()
            self.tweetsTableView.isHidden = false
            MBProgressHUD.hide(for: self.view, animated: true)
        }, failure: {(error: Error) -> () in
            print(error.localizedDescription)
            // Hide HUD once the network request comes back
            MBProgressHUD.hide(for: self.view, animated: true)
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tweetsTableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        var cellTweet: Tweet
        
        guard let tweetsArray = tweets else {
            print("problem unwrapping tweets")
            return cell
        }

        let returnedTweet = tweetsArray[indexPath.row]
        if let originalTweet = returnedTweet.retweeted_status {
            guard let retweeter = returnedTweet.user else {
                return cell
            }
            cell.retweeter = retweeter
            cellTweet = originalTweet
            print("is a retweet")
        } else {
            cell.retweeter = nil
            cellTweet = returnedTweet
            print("not a retweet")
        }
        cell.tweet = cellTweet
        
        return cell
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        TwitterClient.sharedInstance.homeTimeline(success: { (tweets: [Tweet]) -> () in
            self.tweets = tweets
            self.tweetsTableView.reloadData()
            refreshControl.endRefreshing()
        }, failure: {(error: Error) -> () in
            print(error.localizedDescription)
        })
    }
    
    @IBAction func onTopButton(_ sender: Any) {
        let indexPath = NSIndexPath(row: 0, section: 0) as IndexPath
        self.tweetsTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        // self.tweetsTableView.setContentOffset(topPoint, animated: true)
    }
    
    @IBAction func onLogoutButton(_ sender: Any) {
        TwitterClient.sharedInstance.logout()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail" {
            let cell = sender as! TweetCell
            let destinationVC = segue.destination as! TweetViewController
            
            destinationVC.tweet = cell.tweet
            if cell.retweeter != nil {
                destinationVC.retweeter = cell.retweeter
            }
            destinationVC.delegate = self
        }
        if segue.identifier == "compose" {
            let navigationController = segue.destination as! UINavigationController
            let composeVC = navigationController.topViewController as! ComposeViewController
            
            composeVC.delegate = self

        }
    }
    
    internal func tweetViewController(tweetViewController: TweetViewController, replyto id: Int64, tweeted string: String) {
        TwitterClient.sharedInstance.reply(text: string, id: id, success: { (postedTweet: Tweet) -> Void in
            _ = self.navigationController?.popViewController(animated: true)
            self.refreshControlAction(self.refreshControl)
        }, failure: { (error: Error) -> Void in
            print(error.localizedDescription)
        })
    }
    
    internal func composeViewController(composeViewController: ComposeViewController, tweeted string: String) {
        composeViewController.dismiss(animated: true, completion: nil)
        TwitterClient.sharedInstance.tweet(text: string, success: { (postedTweet: Tweet) -> Void in
            self.refreshControlAction(self.refreshControl)
        }, failure: { (error: Error) -> Void in
            print(error.localizedDescription)
        })
    }

}
