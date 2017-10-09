//
//  TwitterClient.swift
//  wittier
//
//  Created by Angela Yu on 9/26/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit
import AFNetworking
import BDBOAuth1Manager

enum timelineType {
    case home
    case profile
    case mentions
}

enum timelineTask {
    case initial
    case refresh
    case infinite
}

class TwitterClient: BDBOAuth1SessionManager {
    static let sharedInstance: TwitterClient = TwitterClient(baseURL: URL(string: "https://api.twitter.com")!, consumerKey: "beruK1UauXpiV2PxWrc6EkDGb", consumerSecret: "DYokLj6ErkKKcNgmKmyrLUyVHMawfX7zc0InSCGlbjqUDlyn4l")
    
    var loginSuccess: (() -> ())?
    var loginFailure: ((Error) -> ())?
    
    // MARK: - Login/logout
    func login(success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        loginSuccess = success
        loginFailure = failure
        
        TwitterClient.sharedInstance.fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "wittier://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
            print("got a token")
            guard let tokenString = requestToken.token else {
                print("unwrapping request token failed")
                return
            }
            let url = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(tokenString)")
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            
        }, failure: { (error: Error!) -> Void in
            print("error: \(error.localizedDescription)")
            self.loginFailure?(error)
        })
    }
    
    func logout() {
        User.currentUser = nil
        deauthorize()
        
        NotificationCenter.default.post(name: User.userDidLogoutNotification, object: nil)
    }
    
    func handleOpenURL(url: URL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        fetchAccessToken(withPath: "https://api.twitter.com/oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential!) -> Void in
            
            self.currentAccount(success: { (user: User) -> () in
                User.currentUser = user
                self.loginSuccess?()
            }, failure: { (error: Error) -> () in
                self.loginFailure?(error)
            })

        }, failure: { (error: Error?) -> Void in
            print("\(String(describing: error?.localizedDescription))")
            self.loginFailure?(error!)
            })
    }
    
    func currentAccount(success: @escaping (User) -> (), failure: (Error) -> ()) {
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) -> Void in
            let userDictionary = response as! NSDictionary
            let user = User(dictionary: userDictionary)
            
            success(user)
            
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
            print("error: \(error.localizedDescription)")
        })
    }
    
    // MARK: - Timelines: Home, User, Mentions
    func getTimeline(type: timelineType, task: timelineTask, screenname: String? = nil, maxID: Int64? = nil,
                     sinceID: Int64? = nil, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        var params: [String: AnyObject] = ["count": 20 as AnyObject]
        var apiString = ""
        switch type {
        case .home:
            apiString = "1.1/statuses/home_timeline.json"
        case .profile:
            apiString = "1.1/statuses/user_timeline.json"
            params["screen_name"] = screenname as AnyObject
        case .mentions:
            apiString = "1.1/statuses/mentions_timeline.json"
        }
        
        switch task {
        case .refresh:
            params["since_id"] = sinceID as AnyObject
        case .infinite:
            params["max_id"] = maxID as AnyObject
        case .initial:
            fallthrough
        default:
            break
        }
        
        get(apiString, parameters: params, progress: nil, success: { (task: URLSessionDataTask, response: Any?) -> Void in
            let dictionaries = response as! [NSDictionary]
            let tweets = Tweet.tweetsWithArray(dictionaries: dictionaries)

            success(tweets)
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
            failure(error)
        })
    }
    
    // MARK: - Tweet interactions
    func tweet(text: String, replyToID: Int64? = nil, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        var params: [String: AnyObject] = [:]
        if replyToID != nil {
            params = ["status": text as AnyObject, "in_reply_to_status_id": replyToID as AnyObject]
        } else {
            params = ["status": text as AnyObject]
        }
        print(params)
        self.post("1.1/statuses/update.json", parameters: params, progress: nil, success: { (task: URLSessionDataTask, response: Any?) -> Void in
            let tweetDict = response as! NSDictionary
            let tweet = Tweet(dictionary: tweetDict)
            success(tweet)
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
            print("tweet task failed")
            print("error: \(error.localizedDescription)")
            failure(error)
        })
    }
    
    func fave(faveMe: Bool, id: Int64, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        var url = ""
        if faveMe {
            url = "1.1/favorites/create.json"
        } else {
            url = "1.1/favorites/destroy.json"
        }
        let params: [String: AnyObject] = ["id": id as AnyObject]
        self.post(url, parameters: params, progress: nil, success: { (task: URLSessionDataTask, response: Any?) -> Void in
            let tweetDict = response as! NSDictionary
            let tweet = Tweet(dictionary: tweetDict)
            print("\(tweet.favoritesCount)")
            success(tweet)
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
            print("favorite task failed")
            print("error: \(error.localizedDescription)")
            failure(error)
        })
    }
    
    func retweet(retweetMe: Bool, id: Int64, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        var postString = ""
        if retweetMe {
            postString = "1.1/statuses/retweet/"
        } else {
            postString = "1.1/statuses/unretweet/"
        }
        postString.append("\(id).json")
        self.post(postString, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) -> Void in
            let tweetDict = response as! NSDictionary
            let tweet = Tweet(dictionary: tweetDict)
            print("\(tweet.retweetCount)")
            success(tweet)
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
            print("retweet task failed")
            print("error: \(error.localizedDescription)")
            failure(error)
        })
    }
    
}
