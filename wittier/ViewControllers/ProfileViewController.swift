//
//  ProfileViewController.swift
//  wittier
//
//  Created by Angela Yu on 10/5/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit
import MBProgressHUD

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate,
TweetCellDelegate, ComposeViewControllerDelegate, TweetViewControllerDelegate {
    
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    @IBOutlet weak var userTimelineTableView: UITableView!
    
    var user: User = User.currentUser!
    var tweets: [Tweet]!
    var maxID: Int64 = 0
    var sinceID: Int64 = 0
    
    let refreshControl = UIRefreshControl()
    var isMoreDataLoading = false
    var loadingMoreView: InfiniteScrollActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getProfileImages()
        getProfileLabels()
        
        userTimelineTableView.isHidden = true
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        userTimelineTableView.dataSource = self
        userTimelineTableView.delegate = self
        userTimelineTableView.rowHeight = UITableViewAutomaticDimension
        userTimelineTableView.estimatedRowHeight = 300
        
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: .valueChanged)
        userTimelineTableView.insertSubview(refreshControl, at: 0)
        
        let frame = CGRect(x: 0, y: userTimelineTableView.contentSize.height,
                           width: userTimelineTableView.bounds.size.width,
                           height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        userTimelineTableView.addSubview(loadingMoreView!)
        
        var insets = tweetsTableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tweetsTableView.contentInset = insets
        
        TwitterClient.sharedInstance.userTimeline(screenname: user.screenname, task: .initial, success: {
            (tweets: [Tweet]) -> () in
            self.tweets = tweets
            let lastID: Int64 = self.tweets[self.tweets.endIndex - 1].id!
            self.maxID = lastID - 1
            let firstID: Int64 = self.tweets[0].id!
            self.sinceID = firstID
            self.userTimelineTableView.reloadData()
            self.userTimelineTableView.isHidden = false
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
    
    // MARK: - Profile Header Setup
    func getProfileImages() {
        
    }
    
    func getProfileLabels() {
        nameLabel.text = user.name
        screennameLabel.text = user.screenname
        descriptionLabel.text = user.tagline
        locationLabel.text = user.location
        followerCountLabel.text = user.followerCount
        followingCountLabel.text = user.followingCount
    }
    
    // MARK: - User Timeline Tableview Setup
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tweetsArray = tweets {
            return tweetsArray.count
        } else { return 0 }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userTimelineTableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        cell.delegate = self
        var cellTweet: Tweet
        
        guard let tweetsArray = tweets else {
            print("problem unwrapping tweets")
            return cell
        }
        
        let returnedTweet = tweetsArray[indexPath.row]
        if let originalTweet = returnedTweet.retweetedStatus {
            guard let retweeter = returnedTweet.user else {
                return cell
            }
            cell.retweeter = retweeter
            cellTweet = originalTweet
        } else {
            cell.retweeter = nil
            cellTweet = returnedTweet
        }
        cell.tweet = cellTweet
        
        return cell
    }

    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        TwitterClient.sharedInstance.userTimeline(screenname: user.screenname, task: .refresh, sinceID: sinceID,
                                                  success: { (tweets: [Tweet]) -> () in
            self.tweets.insert(contentsOf: tweets, at: 0)
            let firstID: Int64 = self.tweets[0].id!
            self.sinceID = firstID
            self.userTimelineTableView.reloadData()
            refreshControl.endRefreshing()
        }, failure: {(error: Error) -> () in
            print(error.localizedDescription)
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = view.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - userTimelineTableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(userTimelineTableView.contentOffset.y > scrollOffsetThreshold && userTimelineTableView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: userTimelineTableView.contentSize.height,
                                   width: userTimelineTableView.bounds.size.width,
                                   height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                loadMoreTweets()
                
            }
        }
    }
    
    func loadMoreTweets() {
        TwitterClient.sharedInstance.userTimeline(screenname: user.screenname, task: .infinite, maxID: maxID, success:{ (tweets: [Tweet]) -> () in
            self.tweets.append(contentsOf: tweets)
            let lastID: Int64 = self.tweets[self.tweets.endIndex - 1].id!
            self.maxID = lastID - 1
            self.isMoreDataLoading = false
            // Stop the loading indicator
            self.loadingMoreView!.stopAnimating()
            self.userTimelineTableView.reloadData()
        }, failure: {(error: Error) -> () in
            print(error.localizedDescription)
        })
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
        guard let segueID = segue.identifier else {
            print("segue triggered with nil identifier")
            return
        }
        switch segueID {
        case "compose":
            let navigationController = segue.destination as! UINavigationController
            let composeVC = navigationController.topViewController as! ComposeViewController
            
            composeVC.delegate = self
        case "reply":
            let cell = sender as! TweetCell
            let destinationVC = segue.destination as! TweetViewController
            
            destinationVC.tweet = cell.tweet
            if cell.retweeter != nil {
                destinationVC.retweeter = cell.retweeter
            }
            destinationVC.replying = true
            destinationVC.delegate = self
        case "detail":
            let cell = sender as! TweetCell
            let destinationVC = segue.destination as! TweetViewController
            
            destinationVC.tweet = cell.tweet
            if cell.retweeter != nil {
                destinationVC.retweeter = cell.retweeter
            }
            destinationVC.delegate = self
        default:
            print("segue triggered with no identifier")
        }
    }

    // MARK: - Delegate functions
    internal func tweetViewController(tweetViewController: TweetViewController, replyToID: Int64,
                                      tweeted string: String) {
        TwitterClient.sharedInstance.tweet(text: string, replyToID: replyToID, success: {
            (postedTweet: Tweet) -> Void in
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
    
    internal func replyButtonTapped(tweetCell: TweetCell) {
        performSegue(withIdentifier: "reply", sender: tweetCell)
    }
}
