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
        
        let storyboard = UIStoryboard(name: "main", bundle: nil)
        let composeNavigationController = storyboard.instantiateViewController(withIdentifier: "ComposeNavigationController")
        let homeNavigationController = storyboard.instantiateViewController(withIdentifier: "TweetsNavigationController")
        
        viewControllers.append(composeNavigationController)
        viewControllers.append(homeNavigationController)
        
        hamburgerViewController.contentViewController = homeNavigationController

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = menuTableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
        
        let titles = ["Compose", "Home"]
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
