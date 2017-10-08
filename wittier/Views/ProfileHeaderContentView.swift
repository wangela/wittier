//
//  ProfileHeaderContentView.swift
//  wittier
//
//  Created by Angela Yu on 10/7/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit

class ProfileHeaderContentView: UIView {
    @IBOutlet weak var profileBackgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!

    var user: User!
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(aDecoder)
        
    }
    
    init?(_ coder: NSCoder? = nil) {
        
        if let coder = coder {
            super.init(coder: coder)
        }
        else {
            super.init(frame: CGRect.zero)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let user = user {
            getProfileLabels()
            getProfileImages()
            profileImageView.layer.cornerRadius = profileImageView.frame.size.width * 0.5
            profileImageView.clipsToBounds = true
        }
    }
    
    func getProfileImages() {
        guard let profileURL = user.profileURL else {
            profileImageView.image = nil
            return
        }
        profileImageView.setImageWith(profileURL)
        
        guard let profileBackgroundURL = user.profileBackgroundURL else {
            profileBackgroundImageView.image = nil
            return
        }
        profileBackgroundImageView.setImageWith(profileBackgroundURL)
    }
    
    func getProfileLabels() {
        guard let userr = user else {
            print("nil user in profile header")
            return
        }
        
        nameLabel.text = userr.name
        screennameLabel.text = userr.screenname
        descriptionLabel.text = userr.tagline
        locationLabel.text = userr.location
        followerCountLabel.text = userr.followerCount
        followingCountLabel.text = userr.followingCount
    }
    
}
