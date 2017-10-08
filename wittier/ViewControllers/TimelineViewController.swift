//
//  TimelineViewController.swift
//  wittier
//
//  Created by Angela Yu on 9/26/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit
import MBProgressHUD

class TimelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate,
ComposeViewControllerDelegate, TweetViewControllerDelegate, TweetCellDelegate {
    
    @IBOutlet weak var tweetsTableView: UITableView!
    
    var timelineType: timelineType = .home
    var tweets: [Tweet]!
    var maxID: Int64 = 0
    var sinceID: Int64 = 0
    
    let refreshControl = UIRefreshControl()
    var isMoreDataLoading = false
    var loadingMoreView: InfiniteScrollActivityView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up tweetsTableView
        tweetsTableView.isHidden = true
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        tweetsTableView.dataSource = self
        tweetsTableView.delegate = self
        tweetsTableView.rowHeight = UITableViewAutomaticDimension
        tweetsTableView.estimatedRowHeight = 300
        
        let frame = CGRect(x: 0, y: tweetsTableView.contentSize.height, width: tweetsTableView.bounds.size.width,
                           height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tweetsTableView.addSubview(loadingMoreView!)
        
        var insets = tweetsTableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tweetsTableView.contentInset = insets
        
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: .valueChanged)
        tweetsTableView.insertSubview(refreshControl, at: 0)
        
        // Show Profile information if profile
        if timelineType == .profile {
            let tweetsHeader = UITableViewHeaderFooterView()
            let profileContent = ProfileHeaderContentView()
            profileContent.user = User.currentUser
            tweetsHeader.addSubview(profileContent)
            
            tweetsTableView.tableHeaderView = tweetsHeader
            
            tweetsHeader.centerXAnchor.constraint(equalTo: tweetsTableView.centerXAnchor).isActive = true
            tweetsHeader.widthAnchor.constraint(equalTo: tweetsTableView.widthAnchor).isActive = true
            tweetsHeader.topAnchor.constraint(equalTo: tweetsTableView.topAnchor).isActive = true
            
            tweetsTableView.tableHeaderView?.layoutIfNeeded()
            tweetsTableView.tableHeaderView = tweetsTableView.tableHeaderView
        } else {
            tweetsTableView.tableHeaderView = nil
        }
        
        fetchTweets(fetchTask: .initial)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TableView setup
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tweetsArray = tweets {
            return tweetsArray.count
        } else { return 0 }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tweetsTableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tweetsTableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tweetsTableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(tweetsTableView.contentOffset.y > scrollOffsetThreshold && tweetsTableView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tweetsTableView.contentSize.height,
                                   width: tweetsTableView.bounds.size.width,
                                   height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                fetchTweets(fetchTask: .infinite)
                
            }
        }
    }
    
    // MARK: - Tweets Fetching
    func fetchTweets(fetchTask: timelineTask) {
        var max: Int64 = 0
        var since: Int64 = 0
        switch fetchTask {
        case .initial:
            break
        case .infinite:
            max = maxID
        case .refresh:
            since = sinceID
        }
        TwitterClient.sharedInstance.getTimeline(type: timelineType, task: fetchTask, maxID: max, sinceID: since, success: { (tweets: [Tweet]) -> () in
            switch fetchTask {
            case .initial:
                self.tweets = tweets
            case .infinite:
                self.tweets.append(contentsOf: tweets)
                self.isMoreDataLoading = false
                // Stop the loading indicator
                self.loadingMoreView!.stopAnimating()
            case .refresh:
                self.tweets.insert(contentsOf: tweets, at: 0)
                self.refreshControl.endRefreshing()
            }

            let lastID: Int64 = self.tweets[self.tweets.endIndex - 1].id!
            self.maxID = lastID - 1
            let firstID: Int64 = self.tweets[0].id!
            self.sinceID = firstID
            self.tweetsTableView.reloadData()
            
            if fetchTask == .initial {
                self.tweetsTableView.isHidden = false
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        }, failure: {(error: Error) -> () in
            print(error.localizedDescription)
            // Hide HUD once the network request comes back
            MBProgressHUD.hide(for: self.view, animated: true)
        })
        
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        fetchTweets(fetchTask: .refresh )
    }
    
    @IBAction func onTopButton(_ sender: Any) {
        let indexPath = NSIndexPath(row: 0, section: 0) as IndexPath
        self.tweetsTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        // self.tweetsTableView.setContentOffset(topPoint, animated: true)
    }
    
    @IBAction func onLogoutButton(_ sender: Any) {
        TwitterClient.sharedInstance.logout()
    }
   
    
    // MARK: - Navigation

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
            destinationVC.replying = false
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
