//
//  ProfileCell.swift
//  wittier
//
//  Created by Angela Yu on 10/5/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit

class ProfileCell: UITableViewCell {
    @IBOutlet weak var profileBackgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    
    var user: User! {
        didSet {
            getProfileLabels()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        getProfileImages()
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width * 0.5
        profileImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
            print("nil user")
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
