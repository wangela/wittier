//
//  LoginViewController.swift
//  wittier
//
//  Created by Angela Yu on 9/26/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLoginButton(_ sender: Any) {
        let twitterClient = BDBOAuth1SessionManager(baseURL: URL(string: "https://api.twitter.com"), consumerKey: "beruK1UauXpiV2PxWrc6EkDGb", consumerSecret: "DYokLj6ErkKKcNgmKmyrLUyVHMawfX7zc0InSCGlbjqUDlyn4l")
        
        twitterClient?.fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "wittier://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
            print("got a token \(requestToken.token)")
            guard let tokenString = requestToken.token else {
                print("unwrapping request token failed")
                return
            }
            let url = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(tokenString)")
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            
        }, failure: { (error: Error!) -> Void in
            print("error: \(error.localizedDescription)")
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

}
