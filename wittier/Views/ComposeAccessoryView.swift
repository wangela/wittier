//
//  ComposeAccessoryView.swift
//  wittier
//
//  Created by Angela Yu on 9/28/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit

class ComposeAccessoryView: UIView {
    var tweetText: String?

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    @IBAction func onTweetButton(_ sender: Any) {
        print("pressed Tweet button")
    }
}
