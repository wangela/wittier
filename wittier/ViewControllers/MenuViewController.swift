//
//  MenuViewController.swift
//  wittier
//
//  Created by Angela Yu on 10/3/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var menuTableView: UITableView!
    
    var viewControllers: [UIViewController] = []
    var hamburgerViewController: HamburgerViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuTableView.delegate = self
        menuTableView.dataSource = self
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeNavigationController = storyboard.instantiateViewController(withIdentifier:
            "TweetsNavigationController")
        let profileNavigationController = storyboard.instantiateViewController(withIdentifier: "TweetsNavigationController")
        let mentionsNavigationController = storyboard.instantiateViewController(withIdentifier: "TweetsNavigationController")
        
        let homeVC = homeNavigationController.childViewControllers[0] as! TimelineViewController
        let profileVC = profileNavigationController.childViewControllers[0] as! TimelineViewController
        let mentionsVC = mentionsNavigationController.childViewControllers[0] as! TimelineViewController
        homeVC.timelineType = .home
        profileVC.timelineType = .profile
        mentionsVC.timelineType = .mentions
        
        viewControllers.append(homeNavigationController)
        viewControllers.append(profileNavigationController)
        viewControllers.append(mentionsNavigationController)
        
        hamburgerViewController.contentViewController = homeNavigationController

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewControllers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = menuTableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
        
        let titles = ["Home", "Profile", "Mentions"]
        cell.menuItemLabel.text = titles[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        hamburgerViewController.contentViewController = viewControllers[indexPath.row]
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
