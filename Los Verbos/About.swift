//
//  About.swift
//  Los Verbos
//
//  Created by Scott Brady on 07/04/2016.
//  Copyright © 2016 Scott Brady. All rights reserved.
//

import UIKit
import SafariServices

class About: UIViewController, BWWalkthroughViewControllerDelegate {
    
    @IBOutlet var RateOnAppStore: UIButton!
    @IBOutlet var sendFeedback: UIButton!
    @IBOutlet var Like: UIButton!
    
    @IBOutlet var likeOnFacebookTitle: UILabel!
    @IBOutlet var sendFeedbackTitle: UILabel!
    @IBOutlet var rateOnAppStoreTitle: UILabel!
    
    
    let feedbackURL = URL(string: "https://goo.gl/PBoUuz")!
    let facebookURL = URL(string: "https://goo.gl/xuE1ZA")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Like.isHidden = true
        sendFeedback.isHidden = true
        RateOnAppStore.isHidden = true
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        animateButtons(Like, buttonDelay: 0.1)
        animateLabels(likeOnFacebookTitle, labelDelay: 0.1)
        animateButtons(sendFeedback, buttonDelay: 0.25)
        animateLabels(sendFeedbackTitle, labelDelay: 0.25)
        animateButtons(RateOnAppStore, buttonDelay: 0.4)
        animateLabels(rateOnAppStoreTitle, labelDelay: 0.4)
        
    }
    
    @IBAction func sendFeedback(_ sender: AnyObject) {
        let safari = SFSafariViewController(url: feedbackURL)
        present(safari, animated: true, completion: nil)
    }
    
    @IBAction func RateOnAppStore(_ sender: AnyObject) {
        UIApplication.shared.openURL(URL(string: "https://goo.gl/GgCpg7")!)
    }
    
    @IBAction func likeOnFb(_ sender: AnyObject) {
        let safari = SFSafariViewController(url: facebookURL)
        present(safari, animated: true, completion: nil)
    }
    
    func animateLabels(_ labelName: UILabel, labelDelay: Double) {
        labelName.isHidden = true
        labelName.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        labelName.isHidden = false
        UIView.animate(withDuration: 0.8, delay: labelDelay, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            labelName.transform = CGAffineTransform.identity
        }, completion: nil)
        
        /*labelName.center.x = self.view.frame.width + 1200
         
         UIView.animate(
         withDuration: 0.75
         , delay: labelDelay
         , usingSpringWithDamping: 0.8
         , initialSpringVelocity: 1
         , options: [.curveEaseOut]
         , animations: ({
         labelName.center.x =
         self.view.frame.width / 2
         }), completion: nil)*/
    }
    
    
    func animateButtons(_ buttonName: UIButton, buttonDelay: Double) {
        buttonName.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        buttonName.isHidden = false
        UIView.animate(withDuration: 0.8, delay: buttonDelay, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            buttonName.transform = CGAffineTransform.identity
        }, completion: nil)
        /*@IBAction func walkthrough(_ sender: Any) {
         tutorial()
         }
         
         func tutorial() {
         let stb = UIStoryboard(name: "Main", bundle: nil)
         let walkthrough = stb.instantiateViewController(withIdentifier: "walk0") as! BWWalkthroughViewController
         let page_one = stb.instantiateViewController(withIdentifier: "walk1") as UIViewController
         let page_two = stb.instantiateViewController(withIdentifier: "walk2") as UIViewController
         let page_three = stb.instantiateViewController(withIdentifier: "walk3") as UIViewController
         let page_four = stb.instantiateViewController(withIdentifier: "walk4") as UIViewController
         let page_five = stb.instantiateViewController(withIdentifier: "walk5") as UIViewController
         let page_six = stb.instantiateViewController(withIdentifier: "walk6") as UIViewController
         let page_seven = stb.instantiateViewController(withIdentifier: "walk7") as UIViewController
         
         walkthrough.delegate = self
         walkthrough.addViewController(page_one)
         walkthrough.addViewController(page_two)
         walkthrough.addViewController(page_three)
         walkthrough.addViewController(page_four)
         walkthrough.addViewController(page_five)
         walkthrough.addViewController(page_six)
         walkthrough.addViewController(page_seven)
         
         self.present(walkthrough, animated: true, completion: nil)
         }
         
         func walkthroughCloseButtonPressed() {
         print("walkthroughCloseButtonPressed")
         self.dismiss(animated: true, completion: nil)
         }*/
    }
}
