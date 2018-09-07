//
//  StartScreenViewController.swift
//  FighterJet
//
//  Created by Paul Yang on 6/20/15.
//  Copyright (c) 2015 Paul Yang. All rights reserved.
//

// this file is for the screen that pops up in between games.  buttons to restart, continue, give feedback by text, rate the app, credits alert

import UIKit
import MessageUI

protocol StartScreenDelegate: class {
    func startGame()
    func continueGameFromDelegate()
}

class StartScreenViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    
    weak var delegate: StartScreenDelegate?

    // MARK: various buttons on the screen
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var creditsButton: UIButton!
    @IBOutlet weak var inAppPurchaseButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var jetImageView: UIImageView!
    @IBOutlet weak var ufoImageView: UIImageView!
    var defaults:NSUserDefaults!
    
    // MARK: initialize
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    // MARK: view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        defaults = NSUserDefaults.standardUserDefaults()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateContinueButton()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateContinueButton()
    }
    
    // MARK: continue button
    func updateContinueButton() {
        defaults = NSUserDefaults.standardUserDefaults()
        let infiniteContinues = defaults.objectForKey("infiniteContinuesPurchased") as? Int
        if (infiniteContinues == 1) {
            let str = "Continue (Infinite)"
            continueButton.setTitle(str, forState: UIControlState.Normal)
            return
        }
        let numContinues = defaults.objectForKey("numContinues") as? Int
        if (numContinues != nil || numContinues > 0) {
            let str = "Continue (\(numContinues!))"
            continueButton.setTitle(str, forState: UIControlState.Normal)
        }
        else {
            continueButton.setTitle("No continues", forState: UIControlState.Normal)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = self.view.frame.width * 0.33
        let height = width * 15/8
        let originX:CGFloat = 5
        let originY = self.view.frame.height/5
        jetImageView.contentMode = UIViewContentMode.ScaleAspectFit
        ufoImageView.contentMode = UIViewContentMode.ScaleAspectFit
        jetImageView.frame.size = CGSizeMake(width, height)
        jetImageView.frame.origin = CGPointMake(originX, originY)
        ufoImageView.frame.size = CGSizeMake(width, height)
        ufoImageView.frame.origin = CGPointMake(self.view.frame.width-width, jetImageView.frame.origin.y)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playButtonPress(sender: UIButton) {
        //print("start game pressed")
        delegate?.startGame()
    }
    
    @IBAction func rateButtonPress(sender: UIButton) {
        // second button
        defaults = NSUserDefaults.standardUserDefaults()
        UIApplication.sharedApplication().openURL(NSURL(string: "itms://itunes.apple.com/us/app/flighty-jet/id1067196690?ls=1&mt=8")!)
    }

    @IBAction func continueButtonPress(sender: UIButton) {
        // third button
        defaults = NSUserDefaults.standardUserDefaults()
        var numContinues = defaults.objectForKey("numContinues") as? Int
        if (numContinues > 0) {
            numContinues = numContinues! - 1
            defaults.setObject(numContinues, forKey: "numContinues")
            updateContinueButton()
            delegate?.continueGameFromDelegate()
        }
        else {
            needContinuesAlert()
        }
    }
    
    func needContinuesAlert() {
        defaults = NSUserDefaults.standardUserDefaults()
        let ratedBefore = defaults.objectForKey("ratedBefore") as? Int
        var msg:String = "Give feedback for additional continues"
        if (ratedBefore == 1) {
            msg = "You have used up your continues"
        }
        let alert = UIAlertController(title: "No More Continues", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "ok", style: .Default)
            { (action: UIAlertAction!) -> Void in
                // self.restartGame()
            })
        presentViewController(alert, animated: true, completion: nil)
    }

    @IBAction func creditsButtonPress(sender: UIButton) {
        let msg:String = "Background Music:\n Night Vision by Attic Base\nFrom sampleswap.org\nImages from reddit.com\n\n For game feedback, email: \n mjpablo3@gmail.com"
        let alert = UIAlertController(title: "Credits", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "ok", style: .Default)
            { (action: UIAlertAction!) -> Void in
                // self.restartGame()
            })
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func openFBpage() {
        let url:NSURL! = NSURL(string: "fb://page/FlightyJet")
        if(UIApplication.sharedApplication().canOpenURL(url)) {
            UIApplication.sharedApplication().openURL(url);
        }
        else {
            UIApplication.sharedApplication().openURL(NSURL(string : "https://www.facebook.com/FlightyJet/")!);
        }
    }
    
    @IBAction func iapPress(sender: UIButton) {
        let msg:String = "Comment on Facebook (2 continues)\nText Me Feedback (1 continue)"
        
        let alert = UIAlertController(title: "Give Feedback for Continues", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        

        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel)
            { (action: UIAlertAction!) -> Void in
                //print("cancel pressed")
            })
        
        alert.addAction(UIAlertAction(title: "Feedback on FB", style: .Default)
            { (action: UIAlertAction!) -> Void in
                self.openFBpage()
                var numContinues = self.defaults.objectForKey("numContinues") as? Int
                numContinues = numContinues! + 2
                self.defaults.setObject(numContinues, forKey: "numContinues")
                self.updateContinueButton()
            })

        alert.addAction(UIAlertAction(title: "Text (US only)", style: .Default)
            { (action: UIAlertAction!) -> Void in
                var numContinues = self.defaults.objectForKey("numContinues") as? Int
                numContinues = numContinues! + 1
                self.defaults.setObject(numContinues, forKey: "numContinues")
                self.sendText()
                self.updateContinueButton()
            })
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: send text feedback
    @IBAction func sendText() {
        //print("calling sendText")
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Feedback: "
            //controller.recipients = [phoneNumber.text]
            controller.recipients = ["4089405137"]
            controller.messageComposeDelegate = self
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
