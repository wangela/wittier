//
//  ComposeViewController.swift
//  wittier
//
//  Created by Angela Yu on 9/26/17.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit

@objc protocol ComposeViewControllerDelegate {
    @objc optional func composeViewController(composeViewController: ComposeViewController, tweeted string: String)
}

class ComposeViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var composeTextView: UITextView!
    
    weak var delegate: ComposeViewControllerDelegate?
    var new: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cancelButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(onCancelButton(_:)))
        let twitterBlue = UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1.0)
        cancelButton.tintColor = twitterBlue
        navigationItem.leftBarButtonItem = cancelButton
        new = true
        composeTextView.delegate = self
        composeTextView.text = "Write here"
        composeTextView.textColor = UIColor.lightGray
        composeTextView.clearsOnInsertion = true
        // composeTextView.inputAccessoryView = Bundle.main.loadNibNamed("ComposeAccessoryView", owner: self, options: nil) as! ComposeAccessoryView?
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        composeTextView.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if new {
            composeTextView.text = "Write here"
            composeTextView.textColor = UIColor.lightGray
            DispatchQueue.main.async {
                self.composeTextView.selectedRange = NSMakeRange(0, 0)
            }
        }

        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if new == true {
            composeTextView.text = ""
            composeTextView.textColor = UIColor.black
            new = false
        }
        
        return true
    }
    
    @IBAction func onCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTweetButton(_ sender: Any) {
        guard let tweetText = composeTextView.text else {
            print("nil tweet, canceling")
            dismiss(animated: true, completion: nil)
            return
        }
        
        delegate?.composeViewController?(composeViewController: self, tweeted: tweetText)
        
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
