//
//  MainMenu.swift
//  Los Verbos
//
//  Created by Scott Brady on 07/04/2016.
//  Copyright © 2016 Scott Brady. All rights reserved.
//

import UIKit
import Social
import MessageUI
import AVFoundation

class MainMenu: UIViewController, MFMailComposeViewControllerDelegate, BWWalkthroughViewControllerDelegate {
    
    @IBOutlet var Start: UIButton!
    @IBOutlet var Settings: UIButton!
    @IBOutlet var about: UIButton!
    //@IBOutlet var Tutorial: UIButton!
    @IBOutlet var ShareThisApp: UILabel!
    @IBOutlet var Facebook: UIButton!
    @IBOutlet var Email: UIButton!
    @IBOutlet var Twitter: UIButton!
    @IBOutlet var Name: UILabel!
    
        var backgroundMusic : AVAudioPlayer?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {        
        
        if(UserDefaults.standard.bool(forKey: "HasLaunchedOnce"))
        {
            // app already launched
        }
        else
        {
            // This is the first launch ever
            UserDefaults.standard.set(true, forKey: "HasLaunchedOnce")
            UserDefaults.standard.synchronize()
            tutorial()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /*func setupAudioPlayerWithFile(_ file:NSString, type:NSString) -> AVAudioPlayer?  {
            let path = Bundle.main.path(forResource: file as String, ofType: type as String)
            let url = URL(fileURLWithPath: path!)
            
            var audioPlayer:AVAudioPlayer?
            
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: url)
            } catch {
                print("Player not available")
            }
            return audioPlayer
        }
        
        
        
        if let backgroundMusic = setupAudioPlayerWithFile("spanish-music", type:"mp3") {
            self.backgroundMusic = backgroundMusic
        }
        
        
        backgroundMusic?.volume = 0.6
        backgroundMusic?.prepareToPlay()
        backgroundMusic?.numberOfLoops = -1
        backgroundMusic?.play()*/
        
        
        /*self.Name.layer.masksToBounds = true
        self.Name.layer.cornerRadius = 7*/
        
        animateButtons(Start, buttonDelay: 0)
        animateButtons(about, buttonDelay: 0.075)
        animateButtons(Settings, buttonDelay: 0.15)
        animateButtons(Facebook, buttonDelay: 0.225)
        animateButtons(Email, buttonDelay: 0.3)
        animateButtons(Twitter, buttonDelay: 0.375)
        
    }
    
    @IBAction func FacebookAction(_ sender: AnyObject) {
        
        let shareToFacebook : SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        shareToFacebook.setInitialText("https://goo.gl/GgCpg7")
        self.present(shareToFacebook, animated: true, completion: nil)
    }
    
    
    @IBAction func TwitterAction(_ sender: AnyObject) {
        
        let shareToTwitter : SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        shareToTwitter.setInitialText("Check out this app: https://goo.gl/GgCpg7")
        self.present(shareToTwitter, animated: true, completion: nil)
    }
    
    @IBAction func EmailAction(_ sender: AnyObject) {
        let mailComposeViewController = configuredMailComposerViewController()
        
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
    }
    
    func configuredMailComposerViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setSubject("Check out this app!")
        mailComposerVC.setMessageBody("Check out this app: https://goo.gl/GgCpg7", isHTML: false)
        
        return mailComposerVC
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("Cancelled Mail")
        case MFMailComposeResult.sent.rawValue:
            print("Sent Mail")
        case MFMailComposeResult.failed.rawValue:
            print("Send failed")
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
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
        
        present(walkthrough, animated: true, completion: nil)
    }
    
    func walkthroughCloseButtonPressed() {
        print("walkthroughCloseButtonPressed")
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    func animateButtons(_ buttonName: UIButton, buttonDelay: Double) {
        
        buttonName.center.x = self.view.frame.width + 1200
        
        UIView.animate(
            withDuration: 0.75
            , delay: buttonDelay
            , usingSpringWithDamping: 0.8
            , initialSpringVelocity: 1
            , options: [.allowUserInteraction, .curveEaseOut]
            , animations: ({
                buttonName.center.x =
                    self.view.frame.width / 2
            }), completion: nil)
    }

}
