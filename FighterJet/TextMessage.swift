//
//  TextMessage.swift
//  FighterJet
//
//  Created by Paul Yang on 12/6/15.
//  Copyright © 2015 Paul Yang. All rights reserved.
//

// --- not used:   functions directly copied into StartScreenViewController

import Foundation
import UIKit
import MessageUI

class TextMessage: UIViewController, MFMessageComposeViewControllerDelegate {
    
    //@IBOutlet weak var phoneNumber: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

//    @IBAction func sendText(sender: UIButton) {
    func sendText() {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Message Body"
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
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
}