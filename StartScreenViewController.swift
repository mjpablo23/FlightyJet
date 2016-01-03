//
//  StartScreenViewController.swift
//  FighterJet
//
//  Created by Paul Yang on 6/20/15.
//  Copyright (c) 2015 Paul Yang. All rights reserved.
//

import UIKit
import MessageUI

// put review button into Get More Continues button

protocol StartScreenDelegate: class {
    func startGame()
    func continueGameFromDelegate()
}

class StartScreenViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    
    weak var delegate: StartScreenDelegate?

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var creditsButton: UIButton!
    @IBOutlet weak var inAppPurchaseButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var jetImageView: UIImageView!
    @IBOutlet weak var ufoImageView: UIImageView!
    var defaults:NSUserDefaults!
    
//    override init() {
//        // super.init()
//        //println("initializing start screen")
//    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
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
        var width = self.view.frame.width * 0.33
        var height = width * 15/8
        var originX:CGFloat = 5
        var originY = self.view.frame.height/5
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
//        var ratedBefore = defaults.objectForKey("ratedBefore") as? Int
//        var numContinues = defaults.objectForKey("numContinues") as? Int
//        if (ratedBefore == nil || ratedBefore == 0) {
//            defaults.setObject(1, forKey: "ratedBefore")
//        }
//        defaults.setObject(numContinues!+5, forKey: "numContinues")
        UIApplication.sharedApplication().openURL(NSURL(string: "itms://itunes.apple.com/us/app/flighty-jet/id1067196690?ls=1&mt=8")!)
//        updateContinueButton()
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
        var ratedBefore = defaults.objectForKey("ratedBefore") as? Int
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
        var msg:String = "Comment on Facebook (2 continues)\nText Me Feedback (1 continue)"
        
        var alert = UIAlertController(title: "Give Feedback for Continues", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        

        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel)
            { (action: UIAlertAction!) -> Void in
                //print("cancel pressed")
            })
        

//        alert.addAction(UIAlertAction(title: "Like", style: .Default)
//            { (action: UIAlertAction!) -> Void in
//                self.openFBpage()
//                var numContinues = self.defaults.objectForKey("numContinues") as? Int
//                numContinues = numContinues! + 2
//                self.defaults.setObject(numContinues, forKey: "numContinues")
//                self.updateContinueButton()
//            })
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
        
        
        /*
        var infiniteContinuesPurchased = self.defaults.objectForKey("infiniteContinuesPurchased") as? Int
        if (infiniteContinuesPurchased == 1) {
        msg = "infinite continues already purchased"
        }
        else {
        msg = "Comment for 3 continues, Like for 2 continues"
        }
        */
        
        /*
        if (infiniteContinuesPurchased == nil || infiniteContinuesPurchased == 0) {
            alert.addAction(UIAlertAction(title: "5 Continues - $0.99", style: .Default)
                { (action: UIAlertAction!) -> Void in
                    var numContinues = self.defaults.objectForKey("numContinues") as? Int
                    numContinues = numContinues! + 5
                    self.defaults.setObject(numContinues, forKey: "numContinues")
                    self.updateContinueButton()
                })
            alert.addAction(UIAlertAction(title: "Infinite Continues - $1.99", style: .Default)
                { (action: UIAlertAction!) -> Void in
                    // open link to app store
                    //print("purchase button 2 pressed")
                    self.defaults.setObject(1, forKey:"infiniteContinuesPurchased")
                    self.updateContinueButton()
                })
        }
        */
        presentViewController(alert, animated: true, completion: nil)
        //print("setting alertViewPresent to false")
    }
    
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

    
//    func sendEmailButtonTapped(sender: AnyObject) {
//        let mailComposeViewController = configuredMailComposeViewController()
//        if MFMailComposeViewController.canSendMail() {
//            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
//        } else {
//            self.showSendMailErrorAlert()
//        }
//    }
//    
//    func configuredMailComposeViewController() -> MFMailComposeViewController {
//        let mailComposerVC = MFMailComposeViewController()
//        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
//        
//        mailComposerVC.setToRecipients(["nurdin@gmail.com"])
//        mailComposerVC.setSubject("Sending you an in-app e-mail...")
//        mailComposerVC.setMessageBody("Sending e-mail in-app is not so bad!", isHTML: false)
//        
//        return mailComposerVC
//    }
//    
//    func showSendMailErrorAlert() {
//        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
//        sendMailErrorAlert.show()
//    }
//
//    // MARK: MFMailComposeViewControllerDelegate
//    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
//        controller.dismissViewControllerAnimated(true, completion: nil)
//        
//    }
}
