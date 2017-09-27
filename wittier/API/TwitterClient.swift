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

class TwitterClient: BDBOAuth1SessionManager {

    static let sharedInstance: TwitterClient = TwitterClient(baseURL: URL(string: "https://api.twitter.com")!, consumerKey: "beruK1UauXpiV2PxWrc6EkDGb", consumerSecret: "DYokLj6ErkKKcNgmKmyrLUyVHMawfX7zc0InSCGlbjqUDlyn4l")
    
    var loginSuccess: (() -> ())?
    var loginFailure: ((Error) -> ())?
    
    func login(success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        loginSuccess = success
        loginFailure = failure
        
        TwitterClient.sharedInstance.deauthorize()
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
    
    func handleOpenURL(url: URL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        fetchAccessToken(withPath: "https://api.twitter.com/oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential!) -> Void in
            print("\(accessToken.token)")
            print("\(accessToken.secret)")
            self.loginSuccess?()
        }, failure: { (error: Error?) -> Void in
            print("\(error?.localizedDescription)")
            self.loginFailure?(error!)
        })
    }
    
    func currentUser() {
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) -> Void in
            let userDictionary = response as! NSDictionary
            let user = User(dictionary: userDictionary)
            print("\(user.name)")
            print("\(user.tagline)")
            
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
            print("error: \(error.localizedDescription)")
        })
    }
    
    func homeTimeline(success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        get("1.1/statuses/home_timeline.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) -> Void in
            let dictionaries = response as! [NSDictionary]
            let tweets = Tweet.tweetsWithArray(dictionaries: dictionaries)
            
            success(tweets)
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
            failure(error)
        })
    }
    
    func fave(id: Int64, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        let params: [String: AnyObject] = ["id": id as AnyObject]
        print(params)
        self.post("1.1/favorites/create.json", parameters: params, progress: nil, success: { (task: URLSessionDataTask, response: Any?) -> Void in
            let taskResponse = task.response
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
    
    func unfave(id: Int64, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        let params: [String: AnyObject] = ["id": id as AnyObject]
        print(params)
        self.post("1.1/favorites/destroy.json", parameters: params, progress: nil, success: { (task: URLSessionDataTask, response: Any?) -> Void in
            let taskResponse = task.response
            let tweetDict = response as! NSDictionary
            let tweet = Tweet(dictionary: tweetDict)
            print("\(tweet.favoritesCount)")
            success(tweet)
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
            print("unfavorite task failed")
            print("error: \(error.localizedDescription)")
            failure(error)
        })
    }
}
