//
//  GameFinished.swift
//  Los Verbos
//
//  Created by Scott Brady on 07/04/2016.
//  Copyright © 2016 Scott Brady. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation
import Social
//import StoreKit
import GoogleMobileAds

class GameFinished: UIViewController, GADInterstitialDelegate {
    
    @IBOutlet var Congrats: UILabel!
    @IBOutlet var returnToMenu: UIButton!
    @IBOutlet var correctAnswersLabel: UILabel!
    @IBOutlet var wrongAnswersLabel: UILabel!
    @IBOutlet var totalLabel: UILabel!
    @IBOutlet var gradeLabel: UILabel!
    @IBOutlet var gradeTitle: UILabel!
    @IBOutlet var totalTitle: UILabel!
    @IBOutlet var qsIncorrectTitle: UILabel!
    @IBOutlet var qsCorrectTitle: UILabel!
    @IBOutlet var shareScore: UIButton!
    @IBOutlet var replay: UIButton!
    @IBOutlet var quizTypeLabel: UILabel!
    
    @IBOutlet var centerPopupConstraint: NSLayoutConstraint!
    @IBOutlet var shareView: UIView!
    @IBOutlet var shareViewFacebook: UIButton!
    @IBOutlet var shareViewTwitter: UIButton!
    @IBOutlet var shareViewMore: UIButton!
    @IBOutlet var backgroundButton: UIButton!
    
    var youWin : AVAudioPlayer?
    var youFail : AVAudioPlayer?
    var totalNumberOfQuestions = Int()  //number of questions in quiz
    var totalCorrectAnswers = Int() //number of questions answered correctly
    var totalWrongAnswers = Int()   //number of questions answered incorrectly
    var myGrade = String()  //grade
    var percentage = Int()  //percentage
    var soundToPlay = String()  //win or lose sound
    var quizType = String() //type of quiz  completed
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        quizTypeLabel.text = "Your results for: \(quizType)"
        
        if let youWin = self.setupAudioPlayerWithFile("YouWin", type:"wav") {
            self.youWin = youWin
        }
        if let youFail = self.setupAudioPlayerWithFile("YouFail", type:"wav") {
            self.youFail = youFail
        }
        
        animateLabels(correctAnswersLabel, labelDelay: 0)
        animateLabels(qsCorrectTitle, labelDelay: 0)
        animateLabels(wrongAnswersLabel, labelDelay: 0.15)
        animateLabels(qsIncorrectTitle, labelDelay: 0.15)
        animateLabels(totalLabel, labelDelay: 0.3)
        animateLabels(totalTitle, labelDelay: 0.3)
        animateLabels(gradeLabel, labelDelay: 0.45)
        animateLabels(gradeTitle, labelDelay: 0.45)
        
        self.Congrats.layer.masksToBounds = true
        self.Congrats.layer.cornerRadius = 7
        self.correctAnswersLabel.layer.masksToBounds = true
        self.correctAnswersLabel.layer.cornerRadius = 7
        self.wrongAnswersLabel.layer.masksToBounds = true
        self.wrongAnswersLabel.layer.cornerRadius = 7
        self.totalLabel.layer.masksToBounds = true
        self.totalLabel.layer.cornerRadius = 7
        self.gradeLabel.layer.masksToBounds = true
        self.gradeLabel.layer.cornerRadius = 7
        shareView.layer.masksToBounds = true
        shareView.layer.cornerRadius = 10
        
        evaluateScore()
        
        if soundToPlay == "win" {
            youWin?.play()
        } else {
            youFail?.play()
        }
        
    }
    
    func evaluateScore() {
        
        evaluatePercentage()
        
        switch (percentage) {
        case 85...100:
            soundToPlay = "win"
            myGrade = "A"
            Congrats.text = "Congratulations!"
        case 70...84:
            soundToPlay = "win"
            myGrade = "B"
            Congrats.text = "Congratulations!"
        case 55...69:
            soundToPlay = "win"
            myGrade = "C"
            Congrats.text = "Congratulations!"
        case 40...54:
            soundToPlay = "fail"
            myGrade = "D"
            Congrats.text = "Keep trying..."
        case 25...39:
            soundToPlay = "fail"
            myGrade = "E"
            Congrats.text = "Keep trying..."
        case 10...24:
            soundToPlay = "fail"
            myGrade = "F"
            Congrats.text = "Keep trying..."
        case 0...9:
            soundToPlay = "fail"
            myGrade = "NG"
            Congrats.text = "Keep trying..."
        default:
            break
        }
        
        correctAnswersLabel.text = "\(Int(totalCorrectAnswers))"
        wrongAnswersLabel.text = "\(Int(totalWrongAnswers))"
        totalLabel.text = "\(percentage)%"
        gradeLabel.text = "\(myGrade)"
    }
    
    func evaluatePercentage() {
        
        let divideBy100 = 100 / Double(totalNumberOfQuestions)
        let multiplyByRight = divideBy100 * Double(totalCorrectAnswers)
        
        percentage = Int(multiplyByRight)
        
    }
    
    func hidePopUp() {
        centerPopupConstraint.constant = 400
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.allowUserInteraction, .curveEaseIn], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        UIView.animate(withDuration: 0.4) {
            self.backgroundButton.alpha = 0
        }
    }
    
    @IBAction func shareButton(_ sender: AnyObject) {
        evaluateScore()
        
        centerPopupConstraint.constant = 0
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.allowUserInteraction, .curveEaseIn], animations: {
            self.view.layoutIfNeeded()        }, completion: nil)
        
        UIView.animate(withDuration: 0.4) {
            self.backgroundButton.alpha = 0.5
        }
        
        /*// text to share
         let text = "Concurso español results for quiz \(quizType):\nQuestions Right: \(Int(totalCorrectAnswers))\nQuestions Wrong: \(Int(totalWrongAnswers))\nTotal: \(percentage)%\nGrade: \(myGrade)\n\nDownload: https://goo.gl/GgCpg7"
         
         let pb: UIPasteboard = UIPasteboard.general
         pb.string = text
         
         let alertController = UIAlertController(title: "Info", message: "To share to Facebook, just tap and hold and select 'Paste'.\nYour results have already been copied.", preferredStyle: .alert)
         
         alertController.addAction(UIAlertAction(title: "Continue", style: .default, handler: { action in
         
         // set up activity view controller
         let textToShare = [ text ]
         let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
         activityViewController.popoverPresentationController?.sourceView = self.shareScore // so that iPads won't crash
         activityViewController.popoverPresentationController?.sourceRect = self.shareScore.bounds
         
         // exclude some activity types from the list (optional)
         activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.print, UIActivityType.addToReadingList, UIActivityType.assignToContact, UIActivityType.saveToCameraRoll ]
         
         // present the view controller
         self.present(activityViewController, animated: true, completion: nil)
         }))
         self.present(alertController, animated: true, completion: nil)*/
    }
    
    @IBAction func shareToFacebook(_ sender: Any) {
        
        let shareToFacebook : SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        let text = "Concurso español results for quiz \(quizType):\nQuestions Right: \(Int(totalCorrectAnswers))\nQuestions Wrong: \(Int(totalWrongAnswers))\nTotal: \(percentage)%\nGrade: \(myGrade)\n\nDownload: https://goo.gl/GgCpg7"
        
        let pb: UIPasteboard = UIPasteboard.general
        pb.string = text
        
        self.hidePopUp()
        
        let alertController = UIAlertController(title: "Share To Facebook", message: "To share to Facebook, just tap and hold and select 'Paste'.\nYour results have already been copied.", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Continue", style: .default, handler: { action in
            
            self.present(shareToFacebook, animated: true, completion: nil)
            
        }))
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func shareToTwitter(_ sender: Any) {
        let text = "Concurso español results for quiz \(quizType):\nQuestions Right: \(Int(totalCorrectAnswers))\nQuestions Wrong: \(Int(totalWrongAnswers))\nTotal: \(percentage)%\nGrade: \(myGrade)\n\nDownload: https://goo.gl/GgCpg7"
        let shareToTwitter : SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        shareToTwitter.setInitialText("\(text)")
        self.hidePopUp()
        self.present(shareToTwitter, animated: true, completion: nil)
    }
    
    @IBAction func shareToOther(_ sender: Any) {
        // text to share
        let text = "Concurso español results for quiz \(quizType):\nQuestions Right: \(Int(totalCorrectAnswers))\nQuestions Wrong: \(Int(totalWrongAnswers))\nTotal: \(percentage)%\nGrade: \(myGrade)\n\nDownload: https://goo.gl/GgCpg7"
            
            // set up activity view controller
            let textToShare = [ text ]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.shareViewMore // so that iPads won't crash
            activityViewController.popoverPresentationController?.sourceRect = self.shareViewMore.bounds
            
            // exclude some activity types from the list (optional)
            activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.print, UIActivityType.addToReadingList, UIActivityType.assignToContact, UIActivityType.saveToCameraRoll ]
            
            // present the view controller
            self.hidePopUp()
            self.present(activityViewController, animated: true, completion: nil)

    }
    
    @IBAction func closePopupButton(_ sender: Any) {
        hidePopUp()
    }
    
    @IBAction func homeButton(_ sender: AnyObject) {
        performSegue(withIdentifier: "returnToMenu", sender: nil)
    }
    
    @IBAction func replayButton(_ sender: AnyObject) {
    }
    
    func setupAudioPlayerWithFile(_ file:NSString, type:NSString) -> AVAudioPlayer?  {
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
    
    /*func DisplayReviewController() {
     if #available( iOS 10.3,*){
     SKStoreReviewController.requestReview()
     } else {
     let url = URL(string: "itms-apps:itunes.apple.com/us/app/apple-store/YOUR_APP_ID?mt=8")!
     
     UIApplication.shared.openURL(url)
     }
     }*/
    
    func animateLabels(_ labelName: UILabel, labelDelay: Double) {
        
        labelName.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        labelName.isHidden = false
        UIView.animate(withDuration: 0.8, delay: labelDelay, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            labelName.transform = CGAffineTransform.identity
        }, completion: nil)
        
    }
    
    
}
