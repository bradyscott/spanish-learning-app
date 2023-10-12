//
//  FoodViewController.swift
//  Concurso español
//
//  Created by Scott Brady on 11/06/2016.
//  Copyright © 2016 Scott Brady. All rights reserved.
//

import UIKit
import AVFoundation
import MessageUI
import GoogleMobileAds

class FoodViewController: UIViewController, MFMailComposeViewControllerDelegate, GADBannerViewDelegate, GADInterstitialDelegate {
    
    @IBOutlet var Question: UILabel!
    @IBOutlet var Score: UILabel!
    @IBOutlet var Wrong: UILabel!
    
    @IBOutlet var Answer1: UIButton!
    @IBOutlet var Answer2: UIButton!
    @IBOutlet var Answer3: UIButton!
    @IBOutlet var Answer4: UIButton!
    @IBOutlet var Next: UIButton!
    @IBOutlet var Quit: UIButton!
    @IBOutlet var bannerView: GADBannerView!
    @IBOutlet var nativeExpressAdView: GADNativeExpressAdView!
    
    @IBOutlet var backgroundView: UIView!
    
    
    @IBOutlet var centerPopupConstraint: NSLayoutConstraint?
    @IBOutlet var shareView: UIView!
    
    
    var CorrectAnswer = String()
    var correctSound : AVAudioPlayer?
    var wrongSound : AVAudioPlayer?
    var collectionOfButtons: [UIButton] = [UIButton]()
    var numberOfQuestionsAnswered = Int()
    var quizTypeToBegin = String()
    var numberOfQuestionsToBegin = Int()
    var numberOfQuestionsInSelectedQuiz = UInt32()
    var CurrentScore = Int()        // Current number of correctly answered questions
    var qsWrong = Int()             // Current number of incorrectly answered questions
    
    let wrongSoundFileName = "wrong"
    let correctSoundFileName = "right"
    let correctSoundExt = "mp3"
    
    override func viewWillAppear(_ animated: Bool) {
        
        nativeExpressAdView.isHidden = true
        nativeExpressAdView.alpha = 0
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        print("The quiz is: \(quizTypeToBegin)")
        print("Number of questions: \(numberOfQuestionsToBegin)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "GameOver" {
            
            if let destinationVC = segue.destination as? GameFinished {
                
                destinationVC.totalNumberOfQuestions = numberOfQuestionsToBegin
                destinationVC.totalCorrectAnswers = CurrentScore
                destinationVC.totalWrongAnswers = qsWrong
                destinationVC.quizType = quizTypeToBegin
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        bannerView.isHidden = true
        bannerView.delegate = self
        bannerView.adUnitID = "ca-app-pub-9433492527891139/3998392670"
        bannerView.adSize = kGADAdSizeSmartBannerPortrait
        bannerView.rootViewController = self
        bannerView.load(request)
        
        self.nativeExpressAdView.adUnitID = "ca-app-pub-9433492527891139/8804565987"
        self.nativeExpressAdView.rootViewController = self
        self.nativeExpressAdView.load(request)
        
        CurrentScore = 0
        qsWrong = 0
        
        Score.text = "\(Int(CurrentScore))/\(Int(numberOfQuestionsToBegin))"
        
        
        
        /*if let correctSound = self.setupAudioPlayerWithFile("right", type:"mp3") {
            self.correctSound = correctSound
        }
        if let wrongSound = self.setupAudioPlayerWithFile("wrong", type:"mp3") {
            self.wrongSound = wrongSound
        }*/

        correctSound?.volume = 1
        wrongSound?.volume = 1
        
        collectionOfButtons = [Answer1,Answer2,Answer3,Answer4]
        
        /*self.Question.layer.masksToBounds = true
        self.Question.layer.cornerRadius = 7*/
        self.Wrong.layer.masksToBounds = true
        self.Wrong.layer.cornerRadius = 7
        self.Score.layer.masksToBounds = true
        self.Score.layer.cornerRadius = 7
        
        hideNext()
        enableButtons()
        Random()
        Wrong.text = "Wrong: 0"
        
        animateButtons(Answer1, buttonDelay: 0)
        animateButtons(Answer2, buttonDelay: 0.075)
        animateButtons(Answer3, buttonDelay: 0.15)
        animateButtons(Answer4, buttonDelay: 0.225)
    }
    
    func getNumberOfQuestionsInQuiz() {
        
        if quizTypeToBegin == "Animals" {
            numberOfQuestionsInSelectedQuiz = UInt32(50)
        } else if quizTypeToBegin == "Clothes & Colours" {
            numberOfQuestionsInSelectedQuiz = UInt32(86)
        } else if quizTypeToBegin == "Food" {
            numberOfQuestionsInSelectedQuiz = UInt32(109)
        } else if quizTypeToBegin == "In the city" {
            numberOfQuestionsInSelectedQuiz = UInt32(84)
        } else if quizTypeToBegin == "Hobbies" {
            numberOfQuestionsInSelectedQuiz = UInt32(94)
        } else if quizTypeToBegin == "School" {
            numberOfQuestionsInSelectedQuiz = UInt32(55)
        } else if quizTypeToBegin == "Verbs" {
            numberOfQuestionsInSelectedQuiz = UInt32(202)
        }
        
    }

    func playWrongSound() {
        if let soundUrl = Bundle.main.url(forResource: wrongSoundFileName, withExtension: correctSoundExt) {
            var soundId: SystemSoundID = 0
            
            AudioServicesCreateSystemSoundID(soundUrl as CFURL, &soundId)
            
            AudioServicesAddSystemSoundCompletion(soundId, nil, nil, { (soundId, clientData) -> Void in
                AudioServicesDisposeSystemSoundID(soundId)
            }, nil)
            
            AudioServicesPlaySystemSound(soundId)
        }
    }
    
    func playCorrectSound() {
        if let soundUrl = Bundle.main.url(forResource: correctSoundFileName, withExtension: correctSoundExt) {
            var soundId: SystemSoundID = 0
            
            AudioServicesCreateSystemSoundID(soundUrl as CFURL, &soundId)
            
            AudioServicesAddSystemSoundCompletion(soundId, nil, nil, { (soundId, clientData) -> Void in
                AudioServicesDisposeSystemSoundID(soundId)
            }, nil)
            
            AudioServicesPlaySystemSound(soundId)
        }
    }
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
    }*/
    
    func enableButtons() {
        Answer1.isEnabled = true
        Answer2.isEnabled = true
        Answer3.isEnabled = true
        Answer4.isEnabled = true
    }
    
    func hideNext() {
        Next.isHidden = true
    }
    
    func showNext() {
        Next.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        Next.isHidden = false
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            self.Next.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    func showAnswerButtons() {
        Answer1.isHidden = false
        Answer2.isHidden = false
        Answer3.isHidden = false
        Answer4.isHidden = false
        
        animateButtons(Answer1, buttonDelay: 0)
        animateButtons(Answer2, buttonDelay: 0.075)
        animateButtons(Answer3, buttonDelay: 0.15)
        animateButtons(Answer4, buttonDelay: 0.225)
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
    
    func hideButtonsWithException(_ excludedbtn: UIButton){
        for btn: UIButton in collectionOfButtons {
            if btn == excludedbtn {
                btn.isEnabled = false
                btn.isHidden = false
                continue
            }
            btn.isHidden = true
        }
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.isHidden = false
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        bannerView.isHidden = true
    }
    
    @available(iOS 10.0, *)
    func hapticFeedback(type: UINotificationFeedbackType) {

        let notification = UINotificationFeedbackGenerator()
        
        notification.notificationOccurred(type)
        
    }
    
    
    @IBAction func Answer1Action(_ sender: AnyObject) {
        if (CorrectAnswer == "1") {
            Question.text = "Correct!\n\n✅"
            playCorrectSound()
            hapticFeedback(type: .success)
            CurrentScore += 1
            numberOfQuestionsAnswered += 1
            Score.text = "\(Int(CurrentScore))/\(Int(numberOfQuestionsToBegin))"
            hideButtonsWithException(Answer1)
            showNext()
        } else {
            if (CorrectAnswer == "2") {
                Question.text = "The correct\n answer is:"
                playWrongSound()
                hapticFeedback(type: .error)
                qsWrong += 1
                numberOfQuestionsAnswered += 1
                Wrong.text = "Wrong: \((Int(qsWrong)))"
                hideButtonsWithException(Answer2)
                showNext()
            } else if (CorrectAnswer == "3") {
                Question.text = "The correct\n answer is:"
                playWrongSound()
                hapticFeedback(type: .error)
                qsWrong += 1
                numberOfQuestionsAnswered += 1
                Wrong.text = "Wrong: \((Int(qsWrong)))"
                hideButtonsWithException(Answer3)
                showNext()
            } else if (CorrectAnswer == "4") {
                Question.text = "The correct\n answer is:"
                playWrongSound()
                hapticFeedback(type: .error)
                qsWrong += 1
                numberOfQuestionsAnswered += 1
                Wrong.text = "Wrong: \((Int(qsWrong)))"
                hideButtonsWithException(Answer4)
                showNext()
            }
        }
    }
    
    @IBAction func Answer2Action(_ sender: AnyObject) {
        if (CorrectAnswer == "2") {
            Question.text = "Correct!\n\n✅"
            playCorrectSound()
            hapticFeedback(type: .success)
            CurrentScore += 1
            numberOfQuestionsAnswered += 1
            Score.text = "\(Int(CurrentScore))/\(Int(numberOfQuestionsToBegin))"
            hideButtonsWithException(Answer2)
            showNext()
        } else {
            if (CorrectAnswer == "1") {
                Question.text = "The correct\n answer is:"
                playWrongSound()
                hapticFeedback(type: .error)
                qsWrong += 1
                numberOfQuestionsAnswered += 1
                Wrong.text = "Wrong: \((Int(qsWrong)))"
                hideButtonsWithException(Answer1)
                showNext()
            } else if (CorrectAnswer == "3") {
                Question.text = "The correct\n answer is:"
                playWrongSound()
                hapticFeedback(type: .error)
                qsWrong += 1
                numberOfQuestionsAnswered += 1
                Wrong.text = "Wrong: \((Int(qsWrong)))"
                hideButtonsWithException(Answer3)
                showNext()
            } else if (CorrectAnswer == "4") {
                Question.text = "The correct\n answer is:"
                playWrongSound()
                hapticFeedback(type: .error)
                qsWrong += 1
                numberOfQuestionsAnswered += 1
                Wrong.text = "Wrong: \((Int(qsWrong)))"
                hideButtonsWithException(Answer4)
                showNext()
            }
        }
    }
    
    @IBAction func Answer3Action(_ sender: AnyObject) {
        if (CorrectAnswer == "3") {
            Question.text = "Correct!\n\n✅"
            playCorrectSound()
            hapticFeedback(type: .success)
            CurrentScore += 1
            numberOfQuestionsAnswered += 1
            Score.text = "\(Int(CurrentScore))/\(Int(numberOfQuestionsToBegin))"
            hideButtonsWithException(Answer3)
            showNext()
        } else {
            if (CorrectAnswer == "1") {
                Question.text = "The correct\n answer is:"
                playWrongSound()
                hapticFeedback(type: .error)
                qsWrong += 1
                numberOfQuestionsAnswered += 1
                Wrong.text = "Wrong: \((Int(qsWrong)))"
                hideButtonsWithException(Answer1)
                showNext()
            } else if (CorrectAnswer == "2") {
                Question.text = "The correct\n answer is:"
                playWrongSound()
                hapticFeedback(type: .error)
                qsWrong += 1
                numberOfQuestionsAnswered += 1
                Wrong.text = "Wrong: \((Int(qsWrong)))"
                hideButtonsWithException(Answer2)
                showNext()
            } else if (CorrectAnswer == "4") {
                Question.text = "The correct\n answer is:"
                playWrongSound()
                hapticFeedback(type: .error)
                qsWrong += 1
                numberOfQuestionsAnswered += 1
                Wrong.text = "Wrong: \((Int(qsWrong)))"
                hideButtonsWithException(Answer4)
                showNext()
            }
        }
    }
    
    @IBAction func Answer4Action(_ sender: AnyObject) {
        if (CorrectAnswer == "4") {
            Question.text = "Correct!\n\n✅"
            playCorrectSound()
            hapticFeedback(type: .success)
            CurrentScore += 1
            numberOfQuestionsAnswered += 1
            Score.text = "\(Int(CurrentScore))/\(Int(numberOfQuestionsToBegin))"
            hideButtonsWithException(Answer4)
            showNext()
        } else {
            if (CorrectAnswer == "1") {
                Question.text = "The correct\n answer is:"
                playWrongSound()
                hapticFeedback(type: .error)
                qsWrong += 1
                numberOfQuestionsAnswered += 1
                Wrong.text = "Wrong: \((Int(qsWrong)))"
                hideButtonsWithException(Answer1)
                showNext()
            } else if (CorrectAnswer == "2") {
                Question.text = "The correct\n answer is:"
                playWrongSound()
                hapticFeedback(type: .error)
                qsWrong += 1
                numberOfQuestionsAnswered += 1
                Wrong.text = "Wrong: \((Int(qsWrong)))"
                hideButtonsWithException(Answer2)
                showNext()
            } else if (CorrectAnswer == "3") {
                Question.text = "The correct\n answer is:"
                playWrongSound()
                hapticFeedback(type: .error)
                qsWrong += 1
                numberOfQuestionsAnswered += 1
                Wrong.text = "Wrong: \((Int(qsWrong)))"
                hideButtonsWithException(Answer3)
                showNext()
            }
        }
    }
    
    @IBAction func QuitButton(_ sender: AnyObject) {
        
        let alertController = UIAlertController(title: "Are you sure you want to quit?", message: "You'll have to start again!", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Yes, I'm sure!", style: .destructive, handler: { action in self.QuitGame() }))
        
        alertController.addAction(UIAlertAction(title: "No, I want to learn more!", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func QuitGame() {
        performSegue(withIdentifier: "QuitGame", sender: nil)
    }
    
    @IBAction func Next(_ sender: AnyObject) {
        if (numberOfQuestionsAnswered == Int(numberOfQuestionsToBegin)) && nativeExpressAdView.isHidden == true {
            
            Next.isHidden = true
            Next.alpha = 0
            
            Next.isHidden = true
            nativeExpressAdView.isHidden = false
            UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
                self.backgroundView.alpha = 0.5
                self.nativeExpressAdView.alpha = 1
            }, completion: nil)

            UIView.animate(withDuration: 0.5, delay: 2, options: [], animations: {
                self.Next.isHidden = false
                self.Next.setTitle("Continue", for: UIControlState.normal)
                self.Next.alpha = 1
            }, completion: nil)
            
        } else if (nativeExpressAdView.isHidden == false) {
            
            performSegue(withIdentifier: "GameOver", sender: nil)
            
        } else {
            enableButtons()
            Random()
            hideNext()
            showAnswerButtons()
        }
    }
    
    func Random() {
        var RandomNumber = UInt32()
        if quizTypeToBegin == "Food" {
            RandomNumber = arc4random() % 109
            RandomNumber += 1
            print("\(RandomNumber)")
            
            switch (RandomNumber) {
            case 1:
                Question.text = "How do you say 'meat'?"
                Answer1.setTitle("la carne", for: UIControlState.normal)
                Answer2.setTitle("el bistec", for: UIControlState.normal)
                Answer3.setTitle("la carne de vaca", for: UIControlState.normal)
                Answer4.setTitle("un filete", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 2:
                Question.text = "How do you say 'beef'?"
                Answer1.setTitle("la carne", for: UIControlState.normal)
                Answer2.setTitle("la carne de vaca", for: UIControlState.normal)
                Answer3.setTitle("el bistec", for: UIControlState.normal)
                Answer4.setTitle("un filete", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 3:
                Question.text = "How do you say 'pork'?"
                Answer1.setTitle("el cordero", for: UIControlState.normal)
                Answer2.setTitle("la ternera", for: UIControlState.normal)
                Answer3.setTitle("el cerdo", for: UIControlState.normal)
                Answer4.setTitle("el pato", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 4:
                Question.text = "How do you say 'lamb'?"
                Answer1.setTitle("la ternera", for: UIControlState.normal)
                Answer2.setTitle("el cerdo", for: UIControlState.normal)
                Answer3.setTitle("el pavo", for: UIControlState.normal)
                Answer4.setTitle("el cordero", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 5:
                Question.text = "How do you say 'steak'?"
                Answer1.setTitle("el bistec", for: UIControlState.normal)
                Answer2.setTitle("la carne", for: UIControlState.normal)
                Answer3.setTitle("la carne de vaca", for: UIControlState.normal)
                Answer4.setTitle("un filete", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 6:
                Question.text = "How do you say 'turkey'?"
                Answer1.setTitle("el pato", for: UIControlState.normal)
                Answer2.setTitle("el pavo", for: UIControlState.normal)
                Answer3.setTitle("el pollo", for: UIControlState.normal)
                Answer4.setTitle("la ternera", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 7:
                Question.text = "How do you say 'ham'?"
                Answer1.setTitle("el pato", for: UIControlState.normal)
                Answer2.setTitle("el cordero", for: UIControlState.normal)
                Answer3.setTitle("el jamón", for: UIControlState.normal)
                Answer4.setTitle("el pavo", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 8:
                Question.text = "How do you say 'groceries'?"
                Answer1.setTitle("las legumbres", for: UIControlState.normal)
                Answer2.setTitle("las verduras", for: UIControlState.normal)
                Answer3.setTitle("las grocerias", for: UIControlState.normal)
                Answer4.setTitle("los comestibles", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 9:
                Question.text = "How do you say 'bread'?"
                Answer1.setTitle("el pan", for: UIControlState.normal)
                Answer2.setTitle("una barra", for: UIControlState.normal)
                Answer3.setTitle("el arroz", for: UIControlState.normal)
                Answer4.setTitle("un pastel", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 10:
                Question.text = "How do you say 'cake'?"
                Answer1.setTitle("el pan", for: UIControlState.normal)
                Answer2.setTitle("un pastel", for: UIControlState.normal)
                Answer3.setTitle("un pastelería", for: UIControlState.normal)
                Answer4.setTitle("el azúcar", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 11:
                Question.text = "How do you say 'doughnut'?"
                Answer1.setTitle("el arroz", for: UIControlState.normal)
                Answer2.setTitle("el aceite", for: UIControlState.normal)
                Answer3.setTitle("un rosquillo", for: UIControlState.normal)
                Answer4.setTitle("la mantequilla", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 12:
                Question.text = "How do you say 'rice'?"
                Answer1.setTitle("un rosquillo", for: UIControlState.normal)
                Answer2.setTitle("la cereza", for: UIControlState.normal)
                Answer3.setTitle("el huevo", for: UIControlState.normal)
                Answer4.setTitle("el arroz", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 13:
                Question.text = "How do you say 'jam'?"
                Answer1.setTitle("la mermelada", for: UIControlState.normal)
                Answer2.setTitle("el jamón", for: UIControlState.normal)
                Answer3.setTitle("el jamón de York", for: UIControlState.normal)
                Answer4.setTitle("la mantequilla", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 14:
                Question.text = "How do you say 'an egg'?"
                Answer1.setTitle("el arroz", for: UIControlState.normal)
                Answer2.setTitle("un huevo", for: UIControlState.normal)
                Answer3.setTitle("el azúcar", for: UIControlState.normal)
                Answer4.setTitle("un pastel", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 15:
                Question.text = "How do you say 'sugar'?"
                Answer1.setTitle("el arroz", for: UIControlState.normal)
                Answer2.setTitle("la mantequilla", for: UIControlState.normal)
                Answer3.setTitle("el azúcar", for: UIControlState.normal)
                Answer4.setTitle("un pastel", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 16:
                Question.text = "How do you say 'butter'?"
                Answer1.setTitle("la mermelada", for: UIControlState.normal)
                Answer2.setTitle("el pastel", for: UIControlState.normal)
                Answer3.setTitle("el aceite", for: UIControlState.normal)
                Answer4.setTitle("la mantequilla", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 17:
                Question.text = "How do you say 'fizzy water'?"
                Answer1.setTitle("el agua con gas", for: UIControlState.normal)
                Answer2.setTitle("la agua con gas", for: UIControlState.normal)
                Answer3.setTitle("la agua sin gas", for: UIControlState.normal)
                Answer4.setTitle("el agua", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 18:
                Question.text = "How do you say 'still water'?"
                Answer1.setTitle("el agua con gas", for: UIControlState.normal)
                Answer2.setTitle("el agua sin gas", for: UIControlState.normal)
                Answer3.setTitle("la agua sin gas", for: UIControlState.normal)
                Answer4.setTitle("la agua con gas", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 19:
                Question.text = "How do you say 'milk'?"
                Answer1.setTitle("la gaseosa", for: UIControlState.normal)
                Answer2.setTitle("el agua", for: UIControlState.normal)
                Answer3.setTitle("la leche", for: UIControlState.normal)
                Answer4.setTitle("la milka", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 20:
                Question.text = "How do you say 'orange juice'?"
                Answer1.setTitle("un zumo de la piña", for: UIControlState.normal)
                Answer2.setTitle("un zumo de la manzana", for: UIControlState.normal)
                Answer3.setTitle("un zumo del pomelo", for: UIControlState.normal)
                Answer4.setTitle("un zumo de naranja", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 21:
                Question.text = "How do you say 'lemonade'?"
                Answer1.setTitle("la limonada", for: UIControlState.normal)
                Answer2.setTitle("la cereza", for: UIControlState.normal)
                Answer3.setTitle("la cerveza", for: UIControlState.normal)
                Answer4.setTitle("la horchata", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 22:
                Question.text = "How do you say 'white wine'?"
                Answer1.setTitle("el vino tinto", for: UIControlState.normal)
                Answer2.setTitle("el vino blanco", for: UIControlState.normal)
                Answer3.setTitle("la vina tinto", for: UIControlState.normal)
                Answer4.setTitle("la vina blanco", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 23:
                Question.text = "How do you say 'beer'?"
                Answer1.setTitle("la horchata", for: UIControlState.normal)
                Answer2.setTitle("el cerveza", for: UIControlState.normal)
                Answer3.setTitle("la cerveza", for: UIControlState.normal)
                Answer4.setTitle("la gaseosa", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 24:
                Question.text = "How do you say 'fish'?"
                Answer1.setTitle("la pescadería", for: UIControlState.normal)
                Answer2.setTitle("los mariscos", for: UIControlState.normal)
                Answer3.setTitle("el bacalao", for: UIControlState.normal)
                Answer4.setTitle("el pescado", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 25:
                Question.text = "How do you say 'shellfish'?"
                Answer1.setTitle("los mariscos", for: UIControlState.normal)
                Answer2.setTitle("el pescado", for: UIControlState.normal)
                Answer3.setTitle("los mejillones", for: UIControlState.normal)
                Answer4.setTitle("el lenguado", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 26:
                Question.text = "How do you say 'trout'?"
                Answer1.setTitle("el bacalao", for: UIControlState.normal)
                Answer2.setTitle("la trucha", for: UIControlState.normal)
                Answer3.setTitle("la merluza", for: UIControlState.normal)
                Answer4.setTitle("el atún", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 27:
                Question.text = "How do you say 'sole'?"
                Answer1.setTitle("el bacalao", for: UIControlState.normal)
                Answer2.setTitle("la trucha", for: UIControlState.normal)
                Answer3.setTitle("el lenguado", for: UIControlState.normal)
                Answer4.setTitle("la merluza", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 28:
                Question.text = "How do you say 'watermelon'?"
                Answer1.setTitle("el pomelo", for: UIControlState.normal)
                Answer2.setTitle("el melocotón", for: UIControlState.normal)
                Answer3.setTitle("la frambuesa", for: UIControlState.normal)
                Answer4.setTitle("la sandía", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 29:
                Question.text = "How do you say 'waffle'?"
                Answer1.setTitle("el gofre", for: UIControlState.normal)
                Answer2.setTitle("el pescado", for: UIControlState.normal)
                Answer3.setTitle("el aceite", for: UIControlState.normal)
                Answer4.setTitle("la legumbre", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 30:
                Question.text = "How do you say 'apricot'?"
                Answer1.setTitle("el melocotón", for: UIControlState.normal)
                Answer2.setTitle("el albaricoque", for: UIControlState.normal)
                Answer3.setTitle("la cereza", for: UIControlState.normal)
                Answer4.setTitle("la cerveza", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 31:
                Question.text = "How do you say 'pear'?"
                Answer1.setTitle("el plátano", for: UIControlState.normal)
                Answer2.setTitle("la fresa", for: UIControlState.normal)
                Answer3.setTitle("la pera", for: UIControlState.normal)
                Answer4.setTitle("el pomelo", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 32:
                Question.text = "How do you say 'grapefruit'?"
                Answer1.setTitle("la uva", for: UIControlState.normal)
                Answer2.setTitle("la piña", for: UIControlState.normal)
                Answer3.setTitle("la sandía", for: UIControlState.normal)
                Answer4.setTitle("el pomelo", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 33:
                Question.text = "How do you say 'cherry'?"
                Answer1.setTitle("la cereza", for: UIControlState.normal)
                Answer2.setTitle("la cerveza", for: UIControlState.normal)
                Answer3.setTitle("la fresa", for: UIControlState.normal)
                Answer4.setTitle("la naranja", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 34:
                Question.text = "How do you say 'orange'?"
                Answer1.setTitle("la manzana", for: UIControlState.normal)
                Answer2.setTitle("la naranja", for: UIControlState.normal)
                Answer3.setTitle("el plátano", for: UIControlState.normal)
                Answer4.setTitle("el pomelo", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 35:
                Question.text = "How do you say 'apple'?"
                Answer1.setTitle("el pomelo", for: UIControlState.normal)
                Answer2.setTitle("la naranja", for: UIControlState.normal)
                Answer3.setTitle("la manzana", for: UIControlState.normal)
                Answer4.setTitle("la sandía", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 36:
                Question.text = "How do you say 'potatoes'?"
                Answer1.setTitle("las guisantes", for: UIControlState.normal)
                Answer2.setTitle("los pepinos", for: UIControlState.normal)
                Answer3.setTitle("las cebollas", for: UIControlState.normal)
                Answer4.setTitle("las patatas", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 37:
                Question.text = "How do you say 'peas'?"
                Answer1.setTitle("las guisantes", for: UIControlState.normal)
                Answer2.setTitle("los champiñones", for: UIControlState.normal)
                Answer3.setTitle("las setas", for: UIControlState.normal)
                Answer4.setTitle("los pimientos", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 38:
                Question.text = "How do you say 'peppers'?"
                Answer1.setTitle("los pepinos", for: UIControlState.normal)
                Answer2.setTitle("los pimientos", for: UIControlState.normal)
                Answer3.setTitle("las cebollas", for: UIControlState.normal)
                Answer4.setTitle("las zanahorias", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 39:
                Question.text = "How do you say 'carrots'?"
                Answer1.setTitle("las setas", for: UIControlState.normal)
                Answer2.setTitle("los pepinos", for: UIControlState.normal)
                Answer3.setTitle("las zanahorias", for: UIControlState.normal)
                Answer4.setTitle("las cebollas", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 40:
                Question.text = "How do you say 'onions'?"
                Answer1.setTitle("las zanahorias", for: UIControlState.normal)
                Answer2.setTitle("las judías", for: UIControlState.normal)
                Answer3.setTitle("los pimientos", for: UIControlState.normal)
                Answer4.setTitle("los cebollas", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 41:
                Question.text = "How do you say 'beans'?"
                Answer1.setTitle("las judías", for: UIControlState.normal)
                Answer2.setTitle("las setas", for: UIControlState.normal)
                Answer3.setTitle("los champiñones", for: UIControlState.normal)
                Answer4.setTitle("las lentejas", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 42:
                Question.text = "How do you say 'mushrooms'?"
                Answer1.setTitle("los pepinos", for: UIControlState.normal)
                Answer2.setTitle("los champiñones", for: UIControlState.normal)
                Answer3.setTitle("las judías", for: UIControlState.normal)
                Answer4.setTitle("las cebollas", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 43:
                Question.text = "How do you say 'sausage'?"
                Answer1.setTitle("el jamón", for: UIControlState.normal)
                Answer2.setTitle("la carne picada", for: UIControlState.normal)
                Answer3.setTitle("la salchicha", for: UIControlState.normal)
                Answer4.setTitle("la chuleta", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 44:
                Question.text = "How do you say 'parsnips'?"
                Answer1.setTitle("las judías", for: UIControlState.normal)
                Answer2.setTitle("la col", for: UIControlState.normal)
                Answer3.setTitle("las zanahorias", for: UIControlState.normal)
                Answer4.setTitle("las chirivias", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 45:
                Question.text = "How do you say 'raspberry'?"
                Answer1.setTitle("la frambuesa", for: UIControlState.normal)
                Answer2.setTitle("la fresa", for: UIControlState.normal)
                Answer3.setTitle("el albaricoque", for: UIControlState.normal)
                Answer4.setTitle("la uva", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 46:
                Question.text = "How do you say 'grapes'?"
                Answer1.setTitle("los pomelos", for: UIControlState.normal)
                Answer2.setTitle("las uvas", for: UIControlState.normal)
                Answer3.setTitle("los guisantes", for: UIControlState.normal)
                Answer4.setTitle("el limón", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 47:
                Question.text = "How do you say 'cheese'?"
                Answer1.setTitle("cereza", for: UIControlState.normal)
                Answer2.setTitle("aceite", for: UIControlState.normal)
                Answer3.setTitle("queso", for: UIControlState.normal)
                Answer4.setTitle("huevo", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 48:
                Question.text = "How do you say 'custard'?"
                Answer1.setTitle("tostado", for: UIControlState.normal)
                Answer2.setTitle("sandía", for: UIControlState.normal)
                Answer3.setTitle("huevo", for: UIControlState.normal)
                Answer4.setTitle("flan", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 49:
                Question.text = "How do you say 'cookies'?"
                Answer1.setTitle("las galletas", for: UIControlState.normal)
                Answer2.setTitle("las tarteletas", for: UIControlState.normal)
                Answer3.setTitle("el helado", for: UIControlState.normal)
                Answer4.setTitle("el postre", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 50:
                Question.text = "How do you say 'ice cream'?"
                Answer1.setTitle("el postre", for: UIControlState.normal)
                Answer2.setTitle("el helado", for: UIControlState.normal)
                Answer3.setTitle("las galleta", for: UIControlState.normal)
                Answer4.setTitle("la piña", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 51:
                Question.text = "How do you say 'avocado'?"
                Answer1.setTitle("el albaricoque", for: UIControlState.normal)
                Answer2.setTitle("el arroz", for: UIControlState.normal)
                Answer3.setTitle("el aguacate", for: UIControlState.normal)
                Answer4.setTitle("el espárrago", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 52:
                Question.text = "How do you say 'strawberry'?"
                Answer1.setTitle("la frambuesa", for: UIControlState.normal)
                Answer2.setTitle("la cereza", for: UIControlState.normal)
                Answer3.setTitle("el ajo", for: UIControlState.normal)
                Answer4.setTitle("la fresa", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 53:
                Question.text = "How do you say 'lime'?"
                Answer1.setTitle("la lima", for: UIControlState.normal)
                Answer2.setTitle("el limón", for: UIControlState.normal)
                Answer3.setTitle("el melocotón", for: UIControlState.normal)
                Answer4.setTitle("la lechuga", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 54:
                Question.text = "How do you say 'lemon'?"
                Answer1.setTitle("la lima", for: UIControlState.normal)
                Answer2.setTitle("el limón", for: UIControlState.normal)
                Answer3.setTitle("el melocotón", for: UIControlState.normal)
                Answer4.setTitle("la piña", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 55:
                Question.text = "How do you say 'peach'?"
                Answer1.setTitle("el albaricoque", for: UIControlState.normal)
                Answer2.setTitle("el plátano", for: UIControlState.normal)
                Answer3.setTitle("el melocotón", for: UIControlState.normal)
                Answer4.setTitle("el melón", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 56:
                Question.text = "How do you say 'nectarine'?"
                Answer1.setTitle("la manzana", for: UIControlState.normal)
                Answer2.setTitle("la naranja", for: UIControlState.normal)
                Answer3.setTitle("la margarina", for: UIControlState.normal)
                Answer4.setTitle("la nectarina", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 57:
                Question.text = "How do you say 'banana'?"
                Answer1.setTitle("el plátano", for: UIControlState.normal)
                Answer2.setTitle("la cereza", for: UIControlState.normal)
                Answer3.setTitle("el bollo", for: UIControlState.normal)
                Answer4.setTitle("el pomelo", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 58:
                Question.text = "How do you say 'pineapple'?"
                Answer1.setTitle("el pomelo", for: UIControlState.normal)
                Answer2.setTitle("la piña", for: UIControlState.normal)
                Answer3.setTitle("el melocotón", for: UIControlState.normal)
                Answer4.setTitle("la manzana", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 59:
                Question.text = "How do you say 'asparagus'?"
                Answer1.setTitle("el calabacín", for: UIControlState.normal)
                Answer2.setTitle("el aquacete", for: UIControlState.normal)
                Answer3.setTitle("el espárrago", for: UIControlState.normal)
                Answer4.setTitle("el guiso", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 60:
                Question.text = "How do you say 'garlic'?"
                Answer1.setTitle("el gárlico", for: UIControlState.normal)
                Answer2.setTitle("los moriscos", for: UIControlState.normal)
                Answer3.setTitle("la cebolla", for: UIControlState.normal)
                Answer4.setTitle("el ajo", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 61:
                Question.text = "How do you say 'olive oil'?"
                Answer1.setTitle("el aceite de oliva", for: UIControlState.normal)
                Answer2.setTitle("la aceituna", for: UIControlState.normal)
                Answer3.setTitle("el aceite de aceituna", for: UIControlState.normal)
                Answer4.setTitle("la oliva", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 62:
                Question.text = "How do you say 'vinegar'?"
                Answer1.setTitle("el sal", for: UIControlState.normal)
                Answer2.setTitle("el vinagre", for: UIControlState.normal)
                Answer3.setTitle("el caldo", for: UIControlState.normal)
                Answer4.setTitle("el apio", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 63:
                Question.text = "How do you say 'mayonnaise'?"
                Answer1.setTitle("el jamón", for: UIControlState.normal)
                Answer2.setTitle("la mermelada", for: UIControlState.normal)
                Answer3.setTitle("la mayonesa", for: UIControlState.normal)
                Answer4.setTitle("el melocoton", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 64:
                Question.text = "How do you say 'sauce'?"
                Answer1.setTitle("la sopa", for: UIControlState.normal)
                Answer2.setTitle("el guiso", for: UIControlState.normal)
                Answer3.setTitle("la salchicha", for: UIControlState.normal)
                Answer4.setTitle("la salsa", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 65:
                Question.text = "How do you say 'salt'?"
                Answer1.setTitle("la sal", for: UIControlState.normal)
                Answer2.setTitle("el sol", for: UIControlState.normal)
                Answer3.setTitle("el sombrero", for: UIControlState.normal)
                Answer4.setTitle("el salt", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 66:
                Question.text = "How do you say 'a pepper'?"
                Answer1.setTitle("la pimienta", for: UIControlState.normal)
                Answer2.setTitle("el pimiento", for: UIControlState.normal)
                Answer3.setTitle("el pomelo", for: UIControlState.normal)
                Answer4.setTitle("el pepino", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 67:
                Question.text = "How do you say 'honey'?"
                Answer1.setTitle("el bollo", for: UIControlState.normal)
                Answer2.setTitle("el huevo", for: UIControlState.normal)
                Answer3.setTitle("la miel", for: UIControlState.normal)
                Answer4.setTitle("la harina", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 68:
                Question.text = "How do you say 'whole milk'?"
                Answer1.setTitle("la leche", for: UIControlState.normal)
                Answer2.setTitle("el helado", for: UIControlState.normal)
                Answer3.setTitle("la leche integral", for: UIControlState.normal)
                Answer4.setTitle("la leche entera", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 69:
                Question.text = "How do you say 'margarine'?"
                Answer1.setTitle("la margarina", for: UIControlState.normal)
                Answer2.setTitle("la mantequilla", for: UIControlState.normal)
                Answer3.setTitle("la nata", for: UIControlState.normal)
                Answer4.setTitle("el aceite", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 70:
                Question.text = "How do you say 'cream'?"
                Answer1.setTitle("el helado", for: UIControlState.normal)
                Answer2.setTitle("la nata", for: UIControlState.normal)
                Answer3.setTitle("el aceite", for: UIControlState.normal)
                Answer4.setTitle("el yogur", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 71:
                Question.text = "How do you say 'yogurt'?"
                Answer1.setTitle("el ajo", for: UIControlState.normal)
                Answer2.setTitle("el yogurt", for: UIControlState.normal)
                Answer3.setTitle("el yogur", for: UIControlState.normal)
                Answer4.setTitle("la nata", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 72:
                Question.text = "How do you say 'celery'?"
                Answer1.setTitle("la cerveza", for: UIControlState.normal)
                Answer2.setTitle("la cereza", for: UIControlState.normal)
                Answer3.setTitle("el caldo", for: UIControlState.normal)
                Answer4.setTitle("el apio", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 73:
                Question.text = "How do you say 'broccoli'?"
                Answer1.setTitle("el bróculi", for: UIControlState.normal)
                Answer2.setTitle("el albaricoque", for: UIControlState.normal)
                Answer3.setTitle("la broccoli", for: UIControlState.normal)
                Answer4.setTitle("el bollo", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 74:
                Question.text = "How do you say 'courgette'?"
                Answer1.setTitle("el caldo", for: UIControlState.normal)
                Answer2.setTitle("el calabacín", for: UIControlState.normal)
                Answer3.setTitle("la chuleta", for: UIControlState.normal)
                Answer4.setTitle("la cebolla", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 75:
                Question.text = "How do you say 'cabbage'?"
                Answer1.setTitle("el caldo", for: UIControlState.normal)
                Answer2.setTitle("el calabacín", for: UIControlState.normal)
                Answer3.setTitle("la col", for: UIControlState.normal)
                Answer4.setTitle("el bollo", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 76:
                Question.text = "How do you say 'Brussels sprouts'?"
                Answer1.setTitle("el caldo", for: UIControlState.normal)
                Answer2.setTitle("el calabacín", for: UIControlState.normal)
                Answer3.setTitle("el calabacín de Bruselas", for: UIControlState.normal)
                Answer4.setTitle("la col de Bruselas", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 77:
                Question.text = "How do you say 'lettuce'?"
                Answer1.setTitle("la lechuga", for: UIControlState.normal)
                Answer2.setTitle("la lenteja", for: UIControlState.normal)
                Answer3.setTitle("la lima", for: UIControlState.normal)
                Answer4.setTitle("el lechuga", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 78:
                Question.text = "How do you say 'cauliflower'?"
                Answer1.setTitle("la col",for: UIControlState.normal)
                Answer2.setTitle("la coliflor", for: UIControlState.normal)
                Answer3.setTitle("el caldo", for: UIControlState.normal)
                Answer4.setTitle("el calabacín", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 79:
                Question.text = "How do you say 'corn'?"
                Answer1.setTitle("el caldo", for: UIControlState.normal)
                Answer2.setTitle("el horno", for: UIControlState.normal)
                Answer3.setTitle("el maíz", for: UIControlState.normal)
                Answer4.setTitle("la nata", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 80:
                Question.text = "How do you say 'tomato'?"
                Answer1.setTitle("la trucha", for: UIControlState.normal)
                Answer2.setTitle("la cereza", for: UIControlState.normal)
                Answer3.setTitle("el melocotón", for: UIControlState.normal)
                Answer4.setTitle("el tomate", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 81:
                Question.text = "How do you say 'stew'?"
                Answer1.setTitle("el guiso", for: UIControlState.normal)
                Answer2.setTitle("la sopa", for: UIControlState.normal)
                Answer3.setTitle("el queso", for: UIControlState.normal)
                Answer4.setTitle("el caldo", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 82:
                Question.text = "How do you say 'soup'?"
                Answer1.setTitle("la col", for: UIControlState.normal)
                Answer2.setTitle("la sopa", for: UIControlState.normal)
                Answer3.setTitle("el guiso", for: UIControlState.normal)
                Answer4.setTitle("el supa", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 83:
                Question.text = "How do you say 'coffee'?"
                Answer1.setTitle("el té", for: UIControlState.normal)
                Answer2.setTitle("el caldo", for: UIControlState.normal)
                Answer3.setTitle("la café", for: UIControlState.normal)
                Answer4.setTitle("el cafe", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 84:
                Question.text = "How do you say 'tea'?"
                Answer1.setTitle("la café", for: UIControlState.normal)
                Answer2.setTitle("el caldo", for: UIControlState.normal)
                Answer3.setTitle("la trucha", for: UIControlState.normal)
                Answer4.setTitle("el té", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 85:
                Question.text = "How do you say 'milkshake'?"
                Answer1.setTitle("el batido", for: UIControlState.normal)
                Answer2.setTitle("la lechona", for: UIControlState.normal)
                Answer3.setTitle("el caldo", for: UIControlState.normal)
                Answer4.setTitle("el refresco", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 86:
                Question.text = "How do you say 'soft drink'?"
                Answer1.setTitle("el batido", for: UIControlState.normal)
                Answer2.setTitle("el refresco", for: UIControlState.normal)
                Answer3.setTitle("la bebida", for: UIControlState.normal)
                Answer4.setTitle("el azúcar", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 87:
                Question.text = "How do you say 'hot chocolate'?"
                Answer1.setTitle("el chocolate calor", for: UIControlState.normal)
                Answer2.setTitle("la chocolate calor", for: UIControlState.normal)
                Answer3.setTitle("el chocolate caliente", for: UIControlState.normal)
                Answer4.setTitle("la chocolate caliente", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 88:
                Question.text = "How do you say 'champagne'?"
                Answer1.setTitle("el vino", for: UIControlState.normal)
                Answer2.setTitle("el caldo", for: UIControlState.normal)
                Answer3.setTitle("el champiñón", for: UIControlState.normal)
                Answer4.setTitle("el champán", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 89:
                Question.text = "How do you say 'meatball'?"
                Answer1.setTitle("la albóndiga", for: UIControlState.normal)
                Answer2.setTitle("la afuera", for: UIControlState.normal)
                Answer3.setTitle("el agaucate", for: UIControlState.normal)
                Answer4.setTitle("el bollo", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 90:
                Question.text = "How do you say 'bacon'?"
                Answer1.setTitle("el cerdo", for: UIControlState.normal)
                Answer2.setTitle("el bacon", for: UIControlState.normal)
                Answer3.setTitle("el batido", for: UIControlState.normal)
                Answer4.setTitle("el ave", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 91:
                Question.text = "How do you say 'minced meat'?"
                Answer1.setTitle("la carne", for: UIControlState.normal)
                Answer2.setTitle("la carne mixta", for: UIControlState.normal)
                Answer3.setTitle("la carne picada", for: UIControlState.normal)
                Answer4.setTitle("la carne de vaca", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 92:
                Question.text = "How do you say 'a chop'?"
                Answer1.setTitle("un cerdo", for: UIControlState.normal)
                Answer2.setTitle("el caldo", for: UIControlState.normal)
                Answer3.setTitle("el cacahuete", for: UIControlState.normal)
                Answer4.setTitle("la chuleta", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 93:
                Question.text = "How do you say 'black pudding'?"
                Answer1.setTitle("la morcilla", for: UIControlState.normal)
                Answer2.setTitle("el pudín negro", for: UIControlState.normal)
                Answer3.setTitle("el pudín blanco", for: UIControlState.normal)
                Answer4.setTitle("la almuerza", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 94:
                Question.text = "How do you say 'poultry'?"
                Answer1.setTitle("el cerdo", for: UIControlState.normal)
                Answer2.setTitle("las aves", for: UIControlState.normal)
                Answer3.setTitle("la carne", for: UIControlState.normal)
                Answer4.setTitle("la carne de vaca", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 95:
                Question.text = "How do you say 'wheat'?"
                Answer1.setTitle("el pescado", for: UIControlState.normal)
                Answer2.setTitle("el bollo", for: UIControlState.normal)
                Answer3.setTitle("el trigo", for: UIControlState.normal)
                Answer4.setTitle("el ajo", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 96:
                Question.text = "How do you say 'olive'?"
                Answer1.setTitle("el aceite", for: UIControlState.normal)
                Answer2.setTitle("la oliva", for: UIControlState.normal)
                Answer3.setTitle("el aceituna", for: UIControlState.normal)
                Answer4.setTitle("la aceituna", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 97:
                Question.text = "How do you say 'peanuts'?"
                Answer1.setTitle("los cacahuetes", for: UIControlState.normal)
                Answer2.setTitle("los bollos", for: UIControlState.normal)
                Answer3.setTitle("las setas", for: UIControlState.normal)
                Answer4.setTitle("las morcillas", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 98:
                Question.text = "How do you say 'a sandwich'?"
                Answer1.setTitle("el batido", for: UIControlState.normal)
                Answer2.setTitle("el boacdillo", for: UIControlState.normal)
                Answer3.setTitle("el espárrago", for: UIControlState.normal)
                Answer4.setTitle("el pan", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 99:
                Question.text = "How do you say 'chips'?"
                Answer1.setTitle("las patatas", for: UIControlState.normal)
                Answer2.setTitle("las setas", for: UIControlState.normal)
                Answer3.setTitle("las patatas fritas", for: UIControlState.normal)
                Answer4.setTitle("el patato", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 100:
                Question.text = "How do you say 'a hot dog'?"
                Answer1.setTitle("el perro calor", for: UIControlState.normal)
                Answer2.setTitle("el perrito calo", for: UIControlState.normal)
                Answer3.setTitle("el perro caliente", for: UIControlState.normal)
                Answer4.setTitle("el perrito caliente", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 101:
                Question.text = "How do you say 'flour'?"
                Answer1.setTitle("la harina", for: UIControlState.normal)
                Answer2.setTitle("el flor", for: UIControlState.normal)
                Answer3.setTitle("el fuego", for: UIControlState.normal)
                Answer4.setTitle("el guiso", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 102:
                Question.text = "How do you say 'brown bread'?"
                Answer1.setTitle("el pan", for: UIControlState.normal)
                Answer2.setTitle("el pan integral", for: UIControlState.normal)
                Answer3.setTitle("el pan marrón", for: UIControlState.normal)
                Answer4.setTitle("el bocadillo", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 103:
                Question.text = "How do you say 'a bread roll'?"
                Answer1.setTitle("el pan integral", for: UIControlState.normal)
                Answer2.setTitle("el pan", for: UIControlState.normal)
                Answer3.setTitle("el bollo", for: UIControlState.normal)
                Answer4.setTitle("el guiso", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 104:
                Question.text = "How do you say 'toast'?"
                Answer1.setTitle("el pan cocinada", for: UIControlState.normal)
                Answer2.setTitle("la mantequilla", for: UIControlState.normal)
                Answer3.setTitle("el toast", for: UIControlState.normal)
                Answer4.setTitle("la tostada", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 105:
                Question.text = "How do you say 'cereal'?"
                Answer1.setTitle("el bistec", for: UIControlState.normal)
                Answer2.setTitle("los cereales", for: UIControlState.normal)
                Answer3.setTitle("el cereal", for: UIControlState.normal)
                Answer4.setTitle("la bomba", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 106:
                Question.text = "How do you say 'a cupcake'?"
                Answer1.setTitle("el pastel", for: UIControlState.normal)
                Answer2.setTitle("la hada", for: UIControlState.normal)
                Answer3.setTitle("la magdalena", for: UIControlState.normal)
                Answer4.setTitle("la tarta", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 107:
                Question.text = "How do you say 'cake'?"
                Answer1.setTitle("la magdalena", for: UIControlState.normal)
                Answer2.setTitle("la hada", for: UIControlState.normal)
                Answer3.setTitle("el pan", for: UIControlState.normal)
                Answer4.setTitle("el pastel", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 108:
                Question.text = "How do you say 'pudding'?"
                Answer1.setTitle("el pudín", for: UIControlState.normal)
                Answer2.setTitle("el bollo", for: UIControlState.normal)
                Answer3.setTitle("la morcilla", for: UIControlState.normal)
                Answer4.setTitle("el guiso", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 109:
                Question.text = "How do you say 'sweets'?"
                Answer1.setTitle("la tarta", for: UIControlState.normal)
                Answer2.setTitle("los caramelos", for: UIControlState.normal)
                Answer3.setTitle("el caramel", for: UIControlState.normal)
                Answer4.setTitle("las tartaletas", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            default:
                break
            }
            
            
        } else if quizTypeToBegin == "Animals" {
            RandomNumber = arc4random() % 50
            RandomNumber += 1
            print("\(RandomNumber)")
            
            switch (RandomNumber) {
            case 1:
                Question.text = "'El mandril' is a..."
                Answer1.setTitle("baboon", for: UIControlState())
                Answer2.setTitle("mammal", for: UIControlState())
                Answer3.setTitle("lion", for: UIControlState())
                Answer4.setTitle("seal", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 2:
                Question.text = "'El murciélago' is a..."
                Answer1.setTitle("monkey", for: UIControlState())
                Answer2.setTitle("bat", for: UIControlState())
                Answer3.setTitle("seal", for: UIControlState())
                Answer4.setTitle("penguin", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 3:
                Question.text = "'El oso' is a..."
                Answer1.setTitle("penguin", for: UIControlState())
                Answer2.setTitle("dog", for: UIControlState())
                Answer3.setTitle("bear", for: UIControlState())
                Answer4.setTitle("ostrich", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 4:
                Question.text = "'El castor' is a..."
                Answer1.setTitle("seal", for: UIControlState())
                Answer2.setTitle("ferret", for: UIControlState())
                Answer3.setTitle("gorilla", for: UIControlState())
                Answer4.setTitle("beaver", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 5:
                Question.text = "'El bufálo' is a..."
                Answer1.setTitle("buffalo", for: UIControlState())
                Answer2.setTitle("bat", for: UIControlState())
                Answer3.setTitle("baboon", for: UIControlState())
                Answer4.setTitle("bear", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 6:
                Question.text = "'El toro' is a..."
                Answer1.setTitle("buffalo", for: UIControlState())
                Answer2.setTitle("bull", for: UIControlState())
                Answer3.setTitle("dog", for: UIControlState())
                Answer4.setTitle("lion", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 7:
                Question.text = "'El camello' is a..."
                Answer1.setTitle("zebra", for: UIControlState())
                Answer2.setTitle("crocodile", for: UIControlState())
                Answer3.setTitle("camel", for: UIControlState())
                Answer4.setTitle("fish", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 8:
                Question.text = "'El gato' is a..."
                Answer1.setTitle("camel", for: UIControlState())
                Answer2.setTitle("gibbon", for: UIControlState())
                Answer3.setTitle("guinea pig", for: UIControlState())
                Answer4.setTitle("cat", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 9:
                Question.text = "'La abeja' is a..."
                Answer1.setTitle("bee", for: UIControlState())
                Answer2.setTitle("spider", for: UIControlState())
                Answer3.setTitle("wasp", for: UIControlState())
                Answer4.setTitle("fly", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 10:
                Question.text = "'El águila' is a..."
                Answer1.setTitle("fish", for: UIControlState())
                Answer2.setTitle("eagle", for: UIControlState())
                Answer3.setTitle("ant", for: UIControlState())
                Answer4.setTitle("hawk", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 11:
                Question.text = "'La araña' is a..."
                Answer1.setTitle("ant", for: UIControlState())
                Answer2.setTitle("beetle", for: UIControlState())
                Answer3.setTitle("spider", for: UIControlState())
                Answer4.setTitle("bee", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 12:
                Question.text = "'La ardilla' is a..."
                Answer1.setTitle("ant", for: UIControlState())
                Answer2.setTitle("beetle", for: UIControlState())
                Answer3.setTitle("fox", for: UIControlState())
                Answer4.setTitle("squirrel", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 13:
                Question.text = "'El avestruz' is a..."
                Answer1.setTitle("ostrich", for: UIControlState())
                Answer2.setTitle("bear", for: UIControlState())
                Answer3.setTitle("zebra", for: UIControlState())
                Answer4.setTitle("cheetah", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 14:
                Question.text = "'La avispa' is a..."
                Answer1.setTitle("bee", for: UIControlState())
                Answer2.setTitle("wasp", for: UIControlState())
                Answer3.setTitle("ant", for: UIControlState())
                Answer4.setTitle("beetle", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 15:
                Question.text = "'La ballena' is a..."
                Answer1.setTitle("dolphin", for: UIControlState())
                Answer2.setTitle("shark", for: UIControlState())
                Answer3.setTitle("whale", for: UIControlState())
                Answer4.setTitle("seahorse", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 16:
                Question.text = "'El bogavante' is a..."
                Answer1.setTitle("crab", for: UIControlState())
                Answer2.setTitle("fish", for: UIControlState())
                Answer3.setTitle("prawn", for: UIControlState())
                Answer4.setTitle("lobster", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 17:
                Question.text = "'El búho' is a..."
                Answer1.setTitle("owl", for: UIControlState())
                Answer2.setTitle("donkey", for: UIControlState())
                Answer3.setTitle("hawk", for: UIControlState())
                Answer4.setTitle("goat", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 19:
                Question.text = "'El burro' is a..."
                Answer1.setTitle("owl", for: UIControlState())
                Answer2.setTitle("donkey", for: UIControlState())
                Answer3.setTitle("goat", for: UIControlState())
                Answer4.setTitle("rabbit", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 20:
                Question.text = "'El caballo' is a..."
                Answer1.setTitle("donkey", for: UIControlState())
                Answer2.setTitle("goat", for: UIControlState())
                Answer3.setTitle("horse", for: UIControlState())
                Answer4.setTitle("sheep", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 21:
                Question.text = "'La cabra' is a..."
                Answer1.setTitle("sheep", for: UIControlState())
                Answer2.setTitle("donkey", for: UIControlState())
                Answer3.setTitle("pig", for: UIControlState())
                Answer4.setTitle("goat", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 22:
                Question.text = "'El calamar' is a..."
                Answer1.setTitle("squid", for: UIControlState())
                Answer2.setTitle("shrimp", for: UIControlState())
                Answer3.setTitle("lobster", for: UIControlState())
                Answer4.setTitle("mussel", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 23:
                Question.text = "'El cangrejo' is a..."
                Answer1.setTitle("tuna", for: UIControlState())
                Answer2.setTitle("crab", for: UIControlState())
                Answer3.setTitle("squid", for: UIControlState())
                Answer4.setTitle("lobster", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 24:
                Question.text = "'El canguro' is a..."
                Answer1.setTitle("tiger", for: UIControlState())
                Answer2.setTitle("squirrel", for: UIControlState())
                Answer3.setTitle("kangaroo", for: UIControlState())
                Answer4.setTitle("hedgehog", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 25:
                Question.text = "'El caracol' is a..."
                Answer1.setTitle("crocodile", for: UIControlState())
                Answer2.setTitle("slug", for: UIControlState())
                Answer3.setTitle("bat", for: UIControlState())
                Answer4.setTitle("snail", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 26:
                Question.text = "'La cebra' is a..."
                Answer1.setTitle("zebra", for: UIControlState())
                Answer2.setTitle("lamb", for: UIControlState())
                Answer3.setTitle("chimpanzee", for: UIControlState())
                Answer4.setTitle("cheetah", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 27:
                Question.text = "'El cerdo' is a..."
                Answer1.setTitle("lamb", for: UIControlState())
                Answer2.setTitle("pig", for: UIControlState())
                Answer3.setTitle("cheetah", for: UIControlState())
                Answer4.setTitle("wolf", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 28:
                Question.text = "'El ciervo' is a..."
                Answer1.setTitle("pig", for: UIControlState())
                Answer2.setTitle("lamb", for: UIControlState())
                Answer3.setTitle("deer", for: UIControlState())
                Answer4.setTitle("wolf", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 29:
                Question.text = "'El cisne' is a..."
                Answer1.setTitle("lamb", for: UIControlState())
                Answer2.setTitle("duck", for: UIControlState())
                Answer3.setTitle("turkey", for: UIControlState())
                Answer4.setTitle("swan", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 30:
                Question.text = "'La hormiga' is a..."
                Answer1.setTitle("ant", for: UIControlState())
                Answer2.setTitle("bee", for: UIControlState())
                Answer3.setTitle("wasp", for: UIControlState())
                Answer4.setTitle("beetle", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 31:
                Question.text = "'La cobaya' is a..."
                Answer1.setTitle("goat", for: UIControlState())
                Answer2.setTitle("guinea pig", for: UIControlState())
                Answer3.setTitle("sheep", for: UIControlState())
                Answer4.setTitle("spider", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 32:
                Question.text = "'El cocodrilo' is a..."
                Answer1.setTitle("koala", for: UIControlState())
                Answer2.setTitle("cheetah", for: UIControlState())
                Answer3.setTitle("crocodile", for: UIControlState())
                Answer4.setTitle("pig", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 33:
                Question.text = "'El cochinillo' is a..."
                Answer1.setTitle("crocodile", for: UIControlState())
                Answer2.setTitle("pig", for: UIControlState())
                Answer3.setTitle("earwig", for: UIControlState())
                Answer4.setTitle("piglet", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 34:
                Question.text = "'El ratón' is a..."
                Answer1.setTitle("mouse", for: UIControlState())
                Answer2.setTitle("mole", for: UIControlState())
                Answer3.setTitle("rat", for: UIControlState())
                Answer4.setTitle("chicken", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 35:
                Question.text = "'El conejo' is a..."
                Answer1.setTitle("rat", for: UIControlState())
                Answer2.setTitle("rabbit", for: UIControlState())
                Answer3.setTitle("mole", for: UIControlState())
                Answer4.setTitle("hare", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 36:
                Question.text = "'La cucaracha' is a..."
                Answer1.setTitle("earwig", for: UIControlState())
                Answer2.setTitle("rabbit", for: UIControlState())
                Answer3.setTitle("cockroach", for: UIControlState())
                Answer4.setTitle("crocodile", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 37:
                Question.text = "'El cuco' is a..."
                Answer1.setTitle("crocodile", for: UIControlState())
                Answer2.setTitle("penguin", for: UIControlState())
                Answer3.setTitle("cockerel", for: UIControlState())
                Answer4.setTitle("cuckoo", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 38:
                Question.text = "'El chimpancé' is a..."
                Answer1.setTitle("chimpanzee", for: UIControlState())
                Answer2.setTitle("cockerel", for: UIControlState())
                Answer3.setTitle("zebra", for: UIControlState())
                Answer4.setTitle("baboon", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 39:
                Question.text = "'El delfín' is a..."
                Answer1.setTitle("dog", for: UIControlState())
                Answer2.setTitle("dolphin", for: UIControlState())
                Answer3.setTitle("whale", for: UIControlState())
                Answer4.setTitle("donkey", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 40:
                Question.text = "'El elefante' is a..."
                Answer1.setTitle("eel", for: UIControlState())
                Answer2.setTitle("eagle", for: UIControlState())
                Answer3.setTitle("elephant", for: UIControlState())
                Answer4.setTitle("elephant seal", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 41:
                Question.text = "'El erizo' is a..."
                Answer1.setTitle("eel", for: UIControlState())
                Answer2.setTitle("slug", for: UIControlState())
                Answer3.setTitle("giraffe", for: UIControlState())
                Answer4.setTitle("hedgehog", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 42:
                Question.text = "'El faisán' is a..."
                Answer1.setTitle("pheasant", for: UIControlState())
                Answer2.setTitle("butterfly", for: UIControlState())
                Answer3.setTitle("beetle", for: UIControlState())
                Answer4.setTitle("ladybug", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 43:
                Question.text = "'La foca' is a..."
                Answer1.setTitle("snail", for: UIControlState())
                Answer2.setTitle("seal", for: UIControlState())
                Answer3.setTitle("slug", for: UIControlState())
                Answer4.setTitle("fish", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 44:
                Question.text = "'La gallina' is a..."
                Answer1.setTitle("squirrel", for: UIControlState())
                Answer2.setTitle("chicken", for: UIControlState())
                Answer3.setTitle("hen", for: UIControlState())
                Answer4.setTitle("giraffe", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 45:
                Question.text = "'La golondrina' is a..."
                Answer1.setTitle("hen", for: UIControlState())
                Answer2.setTitle("crow", for: UIControlState())
                Answer3.setTitle("giraffe", for: UIControlState())
                Answer4.setTitle("swallow", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 46:
                Question.text = "'El gorila' is a..."
                Answer1.setTitle("gorilla", for: UIControlState())
                Answer2.setTitle("giraffe", for: UIControlState())
                Answer3.setTitle("squirrel", for: UIControlState())
                Answer4.setTitle("bear", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 47:
                Question.text = "'El grillo' is a..."
                Answer1.setTitle("gorilla", for: UIControlState())
                Answer2.setTitle("cricket", for: UIControlState())
                Answer3.setTitle("giraffe", for: UIControlState())
                Answer4.setTitle("goldfish", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 48:
                Question.text = "'La grulla' is a..."
                Answer1.setTitle("gorilla", for: UIControlState())
                Answer2.setTitle("giraffe", for: UIControlState())
                Answer3.setTitle("crane", for: UIControlState())
                Answer4.setTitle("swallow", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 49:
                Question.text = "'El halcón' is a..."
                Answer1.setTitle("hamster", for: UIControlState())
                Answer2.setTitle("eagle", for: UIControlState())
                Answer3.setTitle("hedgehog", for: UIControlState())
                Answer4.setTitle("falcon", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 50:
                Question.text = "'El hurón' is a..."
                Answer1.setTitle("ferret", for: UIControlState())
                Answer2.setTitle("rabbit", for: UIControlState())
                Answer3.setTitle("mole", for: UIControlState())
                Answer4.setTitle("squirrel", for: UIControlState())
                CorrectAnswer = "1"
                break
            default:
                break
            }
        } else if quizTypeToBegin == "Clothes & Colours" {
            RandomNumber = arc4random() % 86
            RandomNumber += 1
            print("\(RandomNumber)")
            
            switch (RandomNumber) {
            case 1:
                Question.text = "How do you say 'suit'?"
                Answer1.setTitle("el traje", for: UIControlState.normal)
                Answer2.setTitle("el chándal", for: UIControlState.normal)
                Answer3.setTitle("la camisa", for: UIControlState.normal)
                Answer4.setTitle("el traje de baño", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 2:
                Question.text = "How do you say 'jacket'?"
                Answer1.setTitle("el impermeable", for: UIControlState.normal)
                Answer2.setTitle("la chaqueta", for: UIControlState.normal)
                Answer3.setTitle("el abrigo", for: UIControlState.normal)
                Answer4.setTitle("la cartera", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 3:
                Question.text = "How do you say 'trousers'?"
                Answer1.setTitle("el chándal", for: UIControlState.normal)
                Answer2.setTitle("los cazoncillos", for: UIControlState.normal)
                Answer3.setTitle("los pantalones", for: UIControlState.normal)
                Answer4.setTitle("las bragas", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 4:
                Question.text = "How do you say 'shirt'?"
                Answer1.setTitle("el traje", for: UIControlState.normal)
                Answer2.setTitle("la camiseta", for: UIControlState.normal)
                Answer3.setTitle("el traje de baño", for: UIControlState.normal)
                Answer4.setTitle("la camisa", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 5:
                Question.text = "How do you say 'belt'?"
                Answer1.setTitle("el cinturón", for: UIControlState.normal)
                Answer2.setTitle("la ropa", for: UIControlState.normal)
                Answer3.setTitle("el sujetador", for: UIControlState.normal)
                Answer4.setTitle("el mano", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 6:
                Question.text = "How do you say 'tie'?"
                Answer1.setTitle("el cinturón", for: UIControlState.normal)
                Answer2.setTitle("la corbata", for: UIControlState.normal)
                Answer3.setTitle("el collar", for: UIControlState.normal)
                Answer4.setTitle("el gorro", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 7:
                Question.text = "How do you say 't-shirt'?"
                Answer1.setTitle("el traje", for: UIControlState.normal)
                Answer2.setTitle("la camisa", for: UIControlState.normal)
                Answer3.setTitle("la camiseta", for: UIControlState.normal)
                Answer4.setTitle("la falda", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 8:
                Question.text = "How do you say 'jeans'?"
                Answer1.setTitle("los pantalones", for: UIControlState.normal)
                Answer2.setTitle("la carne de vaca", for: UIControlState.normal)
                Answer3.setTitle("las bragas", for: UIControlState.normal)
                Answer4.setTitle("los tejanos", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 9:
                Question.text = "How do you say 'shorts'?"
                Answer1.setTitle("los pantalones cortos", for: UIControlState.normal)
                Answer2.setTitle("los pantalones largos", for: UIControlState.normal)
                Answer3.setTitle("las bragas", for: UIControlState.normal)
                Answer4.setTitle("los tejanos", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 10:
                Question.text = "How do you say 'waistcoat'?"
                Answer1.setTitle("el abrigo", for: UIControlState.normal)
                Answer2.setTitle("el chaleco", for: UIControlState.normal)
                Answer3.setTitle("el chándal", for: UIControlState.normal)
                Answer4.setTitle("el traje", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 11:
                Question.text = "How do you say 'shoe'?"
                Answer1.setTitle("la bota", for: UIControlState.normal)
                Answer2.setTitle("la sandalia", for: UIControlState.normal)
                Answer3.setTitle("el zapato", for: UIControlState.normal)
                Answer4.setTitle("la zapatería", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 12:
                Question.text = "How do you say 'boot'?"
                Answer1.setTitle("el zapato", for: UIControlState.normal)
                Answer2.setTitle("las bambas", for: UIControlState.normal)
                Answer3.setTitle("la zapatería", for: UIControlState.normal)
                Answer4.setTitle("la bota", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 13:
                Question.text = "How do you say 'slipper'?"
                Answer1.setTitle("la zapatilla", for: UIControlState.normal)
                Answer2.setTitle("la zapatería", for: UIControlState.normal)
                Answer3.setTitle("el zapato", for: UIControlState.normal)
                Answer4.setTitle("la sandalia", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 14:
                Question.text = "How do you say 'sandal'?"
                Answer1.setTitle("el zapato", for: UIControlState.normal)
                Answer2.setTitle("la sandalia", for: UIControlState.normal)
                Answer3.setTitle("la bota", for: UIControlState.normal)
                Answer4.setTitle("las bambas", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 15:
                Question.text = "How do you say 'runners'?"
                Answer1.setTitle("los zapatos", for: UIControlState.normal)
                Answer2.setTitle("la sandalia", for: UIControlState.normal)
                Answer3.setTitle("las bambas", for: UIControlState.normal)
                Answer4.setTitle("las bragas", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 16:
                Question.text = "How do you say 'wool'?"
                Answer1.setTitle("cuero", for: UIControlState.normal)
                Answer2.setTitle("piel", for: UIControlState.normal)
                Answer3.setTitle("raso", for: UIControlState.normal)
                Answer4.setTitle("lana", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 17:
                Question.text = "How do you say 'cotton'?"
                Answer1.setTitle("el algodón", for: UIControlState.normal)
                Answer2.setTitle("el melocotón", for: UIControlState.normal)
                Answer3.setTitle("el terciopelo", for: UIControlState.normal)
                Answer4.setTitle("el raso", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 18:
                Question.text = "How do you say 'nylon'?"
                Answer1.setTitle("el raso", for: UIControlState.normal)
                Answer2.setTitle("el nylon", for: UIControlState.normal)
                Answer3.setTitle("la goma", for: UIControlState.normal)
                Answer4.setTitle("el plástico", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 19:
                Question.text = "How do you say 'leather'?"
                Answer1.setTitle("la miel", for: UIControlState.normal)
                Answer2.setTitle("la seda", for: UIControlState.normal)
                Answer3.setTitle("el cuero", for: UIControlState.normal)
                Answer4.setTitle("el raso", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 20:
                Question.text = "How do you say 'jumper'?"
                Answer1.setTitle("el impermeable", for: UIControlState.normal)
                Answer2.setTitle("el abrigo", for: UIControlState.normal)
                Answer3.setTitle("el chándal", for: UIControlState.normal)
                Answer4.setTitle("el jersey", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
                
            case 21:
                Question.text = "How do you say 'sweater'?"
                Answer1.setTitle("la sudadera", for: UIControlState.normal)
                Answer2.setTitle("el abrigo", for: UIControlState.normal)
                Answer3.setTitle("la cazadora", for: UIControlState.normal)
                Answer4.setTitle("el chándal", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 22:
                Question.text = "How do you say 'tracksuit'?"
                Answer1.setTitle("el traje", for: UIControlState.normal)
                Answer2.setTitle("el chándal", for: UIControlState.normal)
                Answer3.setTitle("el abrigo", for: UIControlState.normal)
                Answer4.setTitle("el impermeable", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 23:
                Question.text = "How do you say 'underwear'?"
                Answer1.setTitle("el gorro", for: UIControlState.normal)
                Answer2.setTitle("el chándal", for: UIControlState.normal)
                Answer3.setTitle("la ropa interior", for: UIControlState.normal)
                Answer4.setTitle("la vaca", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 24:
                Question.text = "How do you say 'underpants'?"
                Answer1.setTitle("el chándal", for: UIControlState.normal)
                Answer2.setTitle("el gorro", for: UIControlState.normal)
                Answer3.setTitle("el abrigo", for: UIControlState.normal)
                Answer4.setTitle("los cazoncillos", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 25:
                Question.text = "How do you say 'socks'?"
                Answer1.setTitle("los calcetines", for: UIControlState.normal)
                Answer2.setTitle("los cazoncillos", for: UIControlState.normal)
                Answer3.setTitle("los leotardos", for: UIControlState.normal)
                Answer4.setTitle("las bambas", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 26:
                Question.text = "How do you say 'coat'?"
                Answer1.setTitle("el impermeable", for: UIControlState.normal)
                Answer2.setTitle("el abrigo", for: UIControlState.normal)
                Answer3.setTitle("la bata", for: UIControlState.normal)
                Answer4.setTitle("la corbata", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 27:
                Question.text = "How do you say 'raincoat'?"
                Answer1.setTitle("el abrigo", for: UIControlState.normal)
                Answer2.setTitle("a bata", for: UIControlState.normal)
                Answer3.setTitle("el impermeable", for: UIControlState.normal)
                Answer4.setTitle("la chaqueta", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 28:
                Question.text = "How do you say 'jacket'?"
                Answer1.setTitle("el sombrero", for: UIControlState.normal)
                Answer2.setTitle("la bata", for: UIControlState.normal)
                Answer3.setTitle("el impermeable", for: UIControlState.normal)
                Answer4.setTitle("la chaqueta", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 29:
                Question.text = "How do you say 'pyjamas'?"
                Answer1.setTitle("el pijama", for: UIControlState.normal)
                Answer2.setTitle("la bata", for: UIControlState.normal)
                Answer3.setTitle("los pimientos", for: UIControlState.normal)
                Answer4.setTitle("los leotardos", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 30:
                Question.text = "How do you say 'dressing gown'?"
                Answer1.setTitle("la guna", for: UIControlState.normal)
                Answer2.setTitle("la bata", for: UIControlState.normal)
                Answer3.setTitle("el vestido", for: UIControlState.normal)
                Answer4.setTitle("la falda", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 31:
                Question.text = "How do you say 'dress'?"
                Answer1.setTitle("la falda", for: UIControlState.normal)
                Answer2.setTitle("la blusa", for: UIControlState.normal)
                Answer3.setTitle("el vestido", for: UIControlState.normal)
                Answer4.setTitle("el gorro", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 32:
                Question.text = "How do you say 'skirt'?"
                Answer1.setTitle("el vestido", for: UIControlState.normal)
                Answer2.setTitle("la blusa", for: UIControlState.normal)
                Answer3.setTitle("el sujetador", for: UIControlState.normal)
                Answer4.setTitle("la falda", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 33:
                Question.text = "How do you say 'blouse'?"
                Answer1.setTitle("la blusa", for: UIControlState.normal)
                Answer2.setTitle("el sujetador", for: UIControlState.normal)
                Answer3.setTitle("la rebeca", for: UIControlState.normal)
                Answer4.setTitle("el vestido", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 34:
                Question.text = "How do you say 'cardigan'?"
                Answer1.setTitle("el pañuelo", for: UIControlState.normal)
                Answer2.setTitle("la rebeca", for: UIControlState.normal)
                Answer3.setTitle("el paraguas", for: UIControlState.normal)
                Answer4.setTitle("el chándal", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 35:
                Question.text = "How do you say 'tights'?"
                Answer1.setTitle("los vestidos", for: UIControlState.normal)
                Answer2.setTitle("las bragas", for: UIControlState.normal)
                Answer3.setTitle("las medias", for: UIControlState.normal)
                Answer4.setTitle("los guantes", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 36:
                Question.text = "How do you say 'bra'?"
                Answer1.setTitle("la sudadera", for: UIControlState.normal)
                Answer2.setTitle("el camisón", for: UIControlState.normal)
                Answer3.setTitle("la gabardina", for: UIControlState.normal)
                Answer4.setTitle("el sujetador", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 37:
                Question.text = "How do you say 'hat'?"
                Answer1.setTitle("el sombrero", for: UIControlState.normal)
                Answer2.setTitle("la bata", for: UIControlState.normal)
                Answer3.setTitle("el camisón", for: UIControlState.normal)
                Answer4.setTitle("la gabardina", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 38:
                Question.text = "How do you say 'gloves'?"
                Answer1.setTitle("los gorros", for: UIControlState.normal)
                Answer2.setTitle("los guantes", for: UIControlState.normal)
                Answer3.setTitle("las llaves", for: UIControlState.normal)
                Answer4.setTitle("los cazoncillos", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 39:
                Question.text = "How do you say 'scarf'?"
                Answer1.setTitle("el camisón", for: UIControlState.normal)
                Answer2.setTitle("el gorro", for: UIControlState.normal)
                Answer3.setTitle("la bufanda", for: UIControlState.normal)
                Answer4.setTitle("el abrigo", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 40:
                Question.text = "How do you say 'cap'?"
                Answer1.setTitle("el abrigo", for: UIControlState.normal)
                Answer2.setTitle("el bolso", for: UIControlState.normal)
                Answer3.setTitle("el pañuelo", for: UIControlState.normal)
                Answer4.setTitle("el gorro", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 41:
                Question.text = "How do you say 'an umbrella'?"
                Answer1.setTitle("el paraguas", for: UIControlState.normal)
                Answer2.setTitle("el leotardo", for: UIControlState.normal)
                Answer3.setTitle("la bufanda", for: UIControlState.normal)
                Answer4.setTitle("la lluvia", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 42:
                Question.text = "How do you say 'jewellery'?"
                Answer1.setTitle("el gorro", for: UIControlState.normal)
                Answer2.setTitle("las joyas", for: UIControlState.normal)
                Answer3.setTitle("los pendientes", for: UIControlState.normal)
                Answer4.setTitle("los leotardos", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 43:
                Question.text = "How do you say 'necklace'?"
                Answer1.setTitle("el gorro", for: UIControlState.normal)
                Answer2.setTitle("el anillo", for: UIControlState.normal)
                Answer3.setTitle("el collar", for: UIControlState.normal)
                Answer4.setTitle("el pendiente", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 44:
                Question.text = "How do you say 'ring'?"
                Answer1.setTitle("el sujetador", for: UIControlState.normal)
                Answer2.setTitle("el pendiente", for: UIControlState.normal)
                Answer3.setTitle("el collar", for: UIControlState.normal)
                Answer4.setTitle("el anillo", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
                
            case 45:
                Question.text = "How do you say 'bracelet'?"
                Answer1.setTitle("la pulsera", for: UIControlState.normal)
                Answer2.setTitle("el anillo", for: UIControlState.normal)
                Answer3.setTitle("el gorro", for: UIControlState.normal)
                Answer4.setTitle("el collar", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 46:
                Question.text = "How do you say 'an earring'?"
                Answer1.setTitle("el collar", for: UIControlState.normal)
                Answer2.setTitle("el pendiente", for: UIControlState.normal)
                Answer3.setTitle("el anillo", for: UIControlState.normal)
                Answer4.setTitle("el monedero", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
                
            case 47:
                Question.text = "How do you say 'brooch'?"
                Answer1.setTitle("el anillo", for: UIControlState.normal)
                Answer2.setTitle("el collar", for: UIControlState.normal)
                Answer3.setTitle("el broche", for: UIControlState.normal)
                Answer4.setTitle("la pulsera", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 48:
                Question.text = "How do you say 'bag'?"
                Answer1.setTitle("la pulsera", for: UIControlState.normal)
                Answer2.setTitle("el sombrero", for: UIControlState.normal)
                Answer3.setTitle("la seda", for: UIControlState.normal)
                Answer4.setTitle("el bolso", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 49:
                Question.text = "How do you say 'purse'?"
                Answer1.setTitle("el monedero", for: UIControlState.normal)
                Answer2.setTitle("la pulsera", for: UIControlState.normal)
                Answer3.setTitle("la cartera", for: UIControlState.normal)
                Answer4.setTitle("la bufanda", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 50:
                Question.text = "How do you say 'silk'?"
                Answer1.setTitle("el terciopelo", for: UIControlState.normal)
                Answer2.setTitle("la seda", for: UIControlState.normal)
                Answer3.setTitle("la goma", for: UIControlState.normal)
                Answer4.setTitle("la piel", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 51:
                Question.text = "How do you say 'satin'?"
                Answer1.setTitle("la seda", for: UIControlState.normal)
                Answer2.setTitle("el cuero", for: UIControlState.normal)
                Answer3.setTitle("el raso", for: UIControlState.normal)
                Answer4.setTitle("el terciopelo", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 52:
                Question.text = "How do you say 'velvet'?"
                Answer1.setTitle("la seda", for: UIControlState.normal)
                Answer2.setTitle("la goma", for: UIControlState.normal)
                Answer3.setTitle("el cuero", for: UIControlState.normal)
                Answer4.setTitle("el terciopelo", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 53:
                Question.text = "How do you say 'rubber'?"
                Answer1.setTitle("la goma", for: UIControlState.normal)
                Answer2.setTitle("el terciopelo", for: UIControlState.normal)
                Answer3.setTitle("el raso", for: UIControlState.normal)
                Answer4.setTitle("el cuero", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 54:
                Question.text = "How do you say 'plastic'?"
                Answer1.setTitle("el bolso", for: UIControlState.normal)
                Answer2.setTitle("el plástico", for: UIControlState.normal)
                Answer3.setTitle("el nylon", for: UIControlState.normal)
                Answer4.setTitle("el terciopelo", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 55:
                Question.text = "How do you say 'patterned'?"
                Answer1.setTitle("de rayas", for: UIControlState.normal)
                Answer2.setTitle("a cuadros", for: UIControlState.normal)
                Answer3.setTitle("estampado/a", for: UIControlState.normal)
                Answer4.setTitle("liso/a", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 56:
                Question.text = "How do you say 'lined'?"
                Answer1.setTitle("estampado/a", for: UIControlState.normal)
                Answer2.setTitle("liso/a", for: UIControlState.normal)
                Answer3.setTitle("a cuadros", for: UIControlState.normal)
                Answer4.setTitle("de rayas", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 57:
                Question.text = "How do you say 'checked'?"
                Answer1.setTitle("a cuadros", for: UIControlState.normal)
                Answer2.setTitle("de rayas", for: UIControlState.normal)
                Answer3.setTitle("liso/a", for: UIControlState.normal)
                Answer4.setTitle("estampado/a", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 58:
                Question.text = "How do you say 'plain'?"
                Answer1.setTitle("de rayas", for: UIControlState.normal)
                Answer2.setTitle("liso/a", for: UIControlState.normal)
                Answer3.setTitle("estampado", for: UIControlState.normal)
                Answer4.setTitle("a cuadros", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 59:
                Question.text = "How do you say 'white'?"
                Answer1.setTitle("crema", for: UIControlState.normal)
                Answer2.setTitle("amarillo", for: UIControlState.normal)
                Answer3.setTitle("blanco/a", for: UIControlState.normal)
                Answer4.setTitle("negro/a", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 60:
                Question.text = "How do you say 'black'?"
                Answer1.setTitle("verde", for: UIControlState.normal)
                Answer2.setTitle("blanco/a", for: UIControlState.normal)
                Answer3.setTitle("morado/a", for: UIControlState.normal)
                Answer4.setTitle("negro/a", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 61:
                Question.text = "How do you say 'grey'?"
                Answer1.setTitle("verde", for: UIControlState.normal)
                Answer2.setTitle("gris", for: UIControlState.normal)
                Answer3.setTitle("amarillo", for: UIControlState.normal)
                Answer4.setTitle("naranja", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 62:
                Question.text = "How do you say 'green'?"
                Answer1.setTitle("naranja", for: UIControlState.normal)
                Answer2.setTitle("gris", for: UIControlState.normal)
                Answer3.setTitle("verde", for: UIControlState.normal)
                Answer4.setTitle("amarillo", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 63:
                Question.text = "How do you say 'blue'?"
                Answer1.setTitle("verde", for: UIControlState.normal)
                Answer2.setTitle("amarillo", for: UIControlState.normal)
                Answer3.setTitle("morado/a", for: UIControlState.normal)
                Answer4.setTitle("azul", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
                
            case 64:
                Question.text = "How do you say 'yellow'?"
                Answer1.setTitle("amarillo", for: UIControlState.normal)
                Answer2.setTitle("naranja", for: UIControlState.normal)
                Answer3.setTitle("verde", for: UIControlState.normal)
                Answer4.setTitle("rosa", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 65:
                Question.text = "How do you say 'orange'?"
                Answer1.setTitle("gris", for: UIControlState.normal)
                Answer2.setTitle("naranja", for: UIControlState.normal)
                Answer3.setTitle("verde", for: UIControlState.normal)
                Answer4.setTitle("rojo/a", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 66:
                Question.text = "How do you say 'red'?"
                Answer1.setTitle("naranja", for: UIControlState.normal)
                Answer2.setTitle("rosa", for: UIControlState.normal)
                Answer3.setTitle("rojo/a", for: UIControlState.normal)
                Answer4.setTitle("morado/a", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 67:
                Question.text = "How do you say 'pink'?"
                Answer1.setTitle("rojo/a", for: UIControlState.normal)
                Answer2.setTitle("verde", for: UIControlState.normal)
                Answer3.setTitle("morado/a", for: UIControlState.normal)
                Answer4.setTitle("rosa", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 68:
                Question.text = "How do you say 'purple'?"
                Answer1.setTitle("morado/a", for: UIControlState.normal)
                Answer2.setTitle("rosa", for: UIControlState.normal)
                Answer3.setTitle("rojo/a", for: UIControlState.normal)
                Answer4.setTitle("azul oscuro", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
                
            case 69:
                Question.text = "How do you say 'navy blue'?"
                Answer1.setTitle("azul", for: UIControlState.normal)
                Answer2.setTitle("azul marino", for: UIControlState.normal)
                Answer3.setTitle("azul claro", for: UIControlState.normal)
                Answer4.setTitle("azul oscuro", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 70:
                Question.text = "How do you say 'brown'?"
                Answer1.setTitle("negro", for: UIControlState.normal)
                Answer2.setTitle("verde", for: UIControlState.normal)
                Answer3.setTitle("marrón", for: UIControlState.normal)
                Answer4.setTitle("azul", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 71:
                Question.text = "How do you say 'light blue'?"
                Answer1.setTitle("azul", for: UIControlState.normal)
                Answer2.setTitle("azul oscuro", for: UIControlState.normal)
                Answer3.setTitle("azul marino", for: UIControlState.normal)
                Answer4.setTitle("azul claro", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 72:
                Question.text = "How do you say 'dark blue'?"
                Answer1.setTitle("azul oscuro", for: UIControlState.normal)
                Answer2.setTitle("azul marino", for: UIControlState.normal)
                Answer3.setTitle("azul claro", for: UIControlState.normal)
                Answer4.setTitle("azul", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 73:
                Question.text = "How do you say 'pocket'?"
                Answer1.setTitle("la cartera", for: UIControlState.normal)
                Answer2.setTitle("el bolsillo", for: UIControlState.normal)
                Answer3.setTitle("el bolso", for: UIControlState.normal)
                Answer4.setTitle("el cuero", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 74:
                Question.text = "How do you say 'zip'?"
                Answer1.setTitle("la bata", for: UIControlState.normal)
                Answer2.setTitle("el botón", for: UIControlState.normal)
                Answer3.setTitle("la cremallera", for: UIControlState.normal)
                Answer4.setTitle("el zapato", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
                
            case 75:
                Question.text = "How do you say 'button'?"
                Answer1.setTitle("el probador", for: UIControlState.normal)
                Answer2.setTitle("el vestido", for: UIControlState.normal)
                Answer3.setTitle("el impermeable", for: UIControlState.normal)
                Answer4.setTitle("el botón", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 76:
                Question.text = "How do you say 'sleeve'?"
                Answer1.setTitle("la manga", for: UIControlState.normal)
                Answer2.setTitle("la falda", for: UIControlState.normal)
                Answer3.setTitle("el gorro", for: UIControlState.normal)
                Answer4.setTitle("el corte", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 77:
                Question.text = "How do you say 'short-sleeved'?"
                Answer1.setTitle("de manga larga", for: UIControlState.normal)
                Answer2.setTitle("de manga corta", for: UIControlState.normal)
                Answer3.setTitle("de manga largo", for: UIControlState.normal)
                Answer4.setTitle("de manga corto", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 78:
                Question.text = "How do you say 'long sleeved'?"
                Answer1.setTitle("de manga largo", for: UIControlState.normal)
                Answer2.setTitle("de manga corto", for: UIControlState.normal)
                Answer3.setTitle("de manga larga", for: UIControlState.normal)
                Answer4.setTitle("de manga corta", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 79:
                Question.text = "How do you say 'size'?"
                Answer1.setTitle("el camisón", for: UIControlState.normal)
                Answer2.setTitle("la corbata", for: UIControlState.normal)
                Answer3.setTitle("la bata", for: UIControlState.normal)
                Answer4.setTitle("la talla", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 80:
                Question.text = "How do you say 'to be fashionable'?"
                Answer1.setTitle("estar de moda", for: UIControlState.normal)
                Answer2.setTitle("estoy de moda", for: UIControlState.normal)
                Answer3.setTitle("estar a moda", for: UIControlState.normal)
                Answer4.setTitle("estoy a moda", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
                
            case 81:
                Question.text = "How do you say 'changing room'?"
                Answer1.setTitle("la ropa", for: UIControlState.normal)
                Answer2.setTitle("el probador", for: UIControlState.normal)
                Answer3.setTitle("el vestido", for: UIControlState.normal)
                Answer4.setTitle("la puerta", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 82:
                Question.text = "How do you say 'wallet'?"
                Answer1.setTitle("el monedero", for: UIControlState.normal)
                Answer2.setTitle("la pulsera", for: UIControlState.normal)
                Answer3.setTitle("la cartera", for: UIControlState.normal)
                Answer4.setTitle("la carretera", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 83:
                Question.text = "How do you say 'keys'?"
                Answer1.setTitle("el llavero", for: UIControlState.normal)
                Answer2.setTitle("la llavero", for: UIControlState.normal)
                Answer3.setTitle("los llaves", for: UIControlState.normal)
                Answer4.setTitle("las llaves", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 84:
                Question.text = "How do you say 'keyring'?"
                Answer1.setTitle("el llavero", for: UIControlState.normal)
                Answer2.setTitle("la llavero", for: UIControlState.normal)
                Answer3.setTitle("los llaves", for: UIControlState.normal)
                Answer4.setTitle("las llaves", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 85:
                Question.text = "How do you say 'swimsuit'?"
                Answer1.setTitle("el traje", for: UIControlState.normal)
                Answer2.setTitle("el reloj", for: UIControlState.normal)
                Answer3.setTitle("el traje de baño", for: UIControlState.normal)
                Answer4.setTitle("la espalda", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 86:
                Question.text = "How do you say 'watch'?"
                Answer1.setTitle("el ordenador", for: UIControlState.normal)
                Answer2.setTitle("el reloj", for: UIControlState.normal)
                Answer3.setTitle("el probador", for: UIControlState.normal)
                Answer4.setTitle("la cartera", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            default:
                break
            }
        } else if quizTypeToBegin == "In the city" {
            RandomNumber = arc4random() % 84
            RandomNumber += 1
            print("\(RandomNumber)")
            
            switch (RandomNumber) {
            case 1:
                Question.text = "How do you say 'town'?"
                Answer1.setTitle("el pueblo", for: UIControlState.normal)
                Answer2.setTitle("la ciudad", for: UIControlState.normal)
                Answer3.setTitle("la zona", for: UIControlState.normal)
                Answer4.setTitle("la granja", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 2:
                Question.text = "How do you say 'city'?"
                Answer1.setTitle("el pueblo", for: UIControlState.normal)
                Answer2.setTitle("la ciudad", for: UIControlState.normal)
                Answer3.setTitle("la zona", for: UIControlState.normal)
                Answer4.setTitle("la granja", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 3:
                Question.text = "How do you say 'zone'?"
                Answer1.setTitle("el barrio", for: UIControlState.normal)
                Answer2.setTitle("el zone", for: UIControlState.normal)
                Answer3.setTitle("la zona", for: UIControlState.normal)
                Answer4.setTitle("las afueras", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 4:
                Question.text = "How do you say 'neighbourhood'?"
                Answer1.setTitle("el vecino", for: UIControlState.normal)
                Answer2.setTitle("el pueblo", for: UIControlState.normal)
                Answer3.setTitle("la granja", for: UIControlState.normal)
                Answer4.setTitle("el barrio", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 5:
                Question.text = "How do you say 'suburbs'?"
                Answer1.setTitle("las afueras", for: UIControlState.normal)
                Answer2.setTitle("el barrio", for: UIControlState.normal)
                Answer3.setTitle("los vecinos", for: UIControlState.normal)
                Answer4.setTitle("el pueblo", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 6:
                Question.text = "How do you say 'building'?"
                Answer1.setTitle("el barrio", for: UIControlState.normal)
                Answer2.setTitle("el edificio", for: UIControlState.normal)
                Answer3.setTitle("la construcción", for: UIControlState.normal)
                Answer4.setTitle("el estanco", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 7:
                Question.text = "How do you say 'shop'?"
                Answer1.setTitle("el estanco", for: UIControlState.normal)
                Answer2.setTitle("la moda", for: UIControlState.normal)
                Answer3.setTitle("la tienda", for: UIControlState.normal)
                Answer4.setTitle("el mercado", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 8:
                Question.text = "How do you say 'market'?"
                Answer1.setTitle("la tienda", for: UIControlState.normal)
                Answer2.setTitle("la zona", for: UIControlState.normal)
                Answer3.setTitle("la marca", for: UIControlState.normal)
                Answer4.setTitle("el mercado", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 9:
                Question.text = "How do you say 'supermarket'?"
                Answer1.setTitle("el supermercado", for: UIControlState.normal)
                Answer2.setTitle("el centro comercial", for: UIControlState.normal)
                Answer3.setTitle("el estanco", for: UIControlState.normal)
                Answer4.setTitle("la marca", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 10:
                Question.text = "How do you say 'shopping centre'?"
                Answer1.setTitle("el supermercado", for: UIControlState.normal)
                Answer2.setTitle("el centro comercial", for: UIControlState.normal)
                Answer3.setTitle("el estanco", for: UIControlState.normal)
                Answer4.setTitle("los grandes almacenes", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 11:
                Question.text = "How do you say 'tobacconist's'?"
                Answer1.setTitle("el quiosco", for: UIControlState.normal)
                Answer2.setTitle("el tabaco", for: UIControlState.normal)
                Answer3.setTitle("el estanco", for: UIControlState.normal)
                Answer4.setTitle("la oficina de correos", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 12:
                Question.text = "How do you say 'kiosk'?"
                Answer1.setTitle("la estanco", for: UIControlState.normal)
                Answer2.setTitle("la quiosco", for: UIControlState.normal)
                Answer3.setTitle("el estanco", for: UIControlState.normal)
                Answer4.setTitle("el quiosco", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 13:
                Question.text = "How do you say 'butcher shop'?"
                Answer1.setTitle("la carnicería", for: UIControlState.normal)
                Answer2.setTitle("la cafetería", for: UIControlState.normal)
                Answer3.setTitle("la zapatería", for: UIControlState.normal)
                Answer4.setTitle("la confitería", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 14:
                Question.text = "How do you say 'sweet shop'?"
                Answer1.setTitle("la carnicería", for: UIControlState.normal)
                Answer2.setTitle("la confitería", for: UIControlState.normal)
                Answer3.setTitle("la cafetería", for: UIControlState.normal)
                Answer4.setTitle("el heladería", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 15:
                Question.text = "How do you say 'chapel'?"
                Answer1.setTitle("la catedral", for: UIControlState.normal)
                Answer2.setTitle("la mezquita", for: UIControlState.normal)
                Answer3.setTitle("la capilla", for: UIControlState.normal)
                Answer4.setTitle("la estatua", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 16:
                Question.text = "How do you say 'church'?"
                Answer1.setTitle("la catedral", for: UIControlState.normal)
                Answer2.setTitle("el estanco", for: UIControlState.normal)
                Answer3.setTitle("la plaza", for: UIControlState.normal)
                Answer4.setTitle("la iglesia", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 17:
                Question.text = "How do you say 'cathedral'?"
                Answer1.setTitle("la cathedral", for: UIControlState.normal)
                Answer2.setTitle("la catedral", for: UIControlState.normal)
                Answer3.setTitle("el cathedral", for: UIControlState.normal)
                Answer4.setTitle("la cathedral", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 18:
                Question.text = "How do you say 'temple'?"
                Answer1.setTitle("la mezquita", for: UIControlState.normal)
                Answer2.setTitle("el templo", for: UIControlState.normal)
                Answer3.setTitle("la sinagoga", for: UIControlState.normal)
                Answer4.setTitle("la iglesia", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 19:
                Question.text = "How do you say 'monument'?"
                Answer1.setTitle("la estatua", for: UIControlState.normal)
                Answer2.setTitle("el espectáculo", for: UIControlState.normal)
                Answer3.setTitle("el monumento", for: UIControlState.normal)
                Answer4.setTitle("la arquitectura", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 20:
                Question.text = "How do you say 'statue'?"
                Answer1.setTitle("el barrio", for: UIControlState.normal)
                Answer2.setTitle("la tienda", for: UIControlState.normal)
                Answer3.setTitle("el monumento", for: UIControlState.normal)
                Answer4.setTitle("la estatua", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
                
            case 21:
                Question.text = "How do you say 'architecture'?"
                Answer1.setTitle("la arquitectura", for: UIControlState.normal)
                Answer2.setTitle("el edificio", for: UIControlState.normal)
                Answer3.setTitle("la estatua", for: UIControlState.normal)
                Answer4.setTitle("el monumento", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 22:
                Question.text = "How do you say 'museum'?"
                Answer1.setTitle("la museo", for: UIControlState.normal)
                Answer2.setTitle("el museo", for: UIControlState.normal)
                Answer3.setTitle("el museum", for: UIControlState.normal)
                Answer4.setTitle("la museum", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 23:
                Question.text = "How do you say 'circus'?"
                Answer1.setTitle("cerca", for: UIControlState.normal)
                Answer2.setTitle("el estanco", for: UIControlState.normal)
                Answer3.setTitle("el circo", for: UIControlState.normal)
                Answer4.setTitle("el teatro", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 24:
                Question.text = "How do you say 'theatre'?"
                Answer1.setTitle("la ópera", for: UIControlState.normal)
                Answer2.setTitle("el espectáculo", for: UIControlState.normal)
                Answer3.setTitle("el cine", for: UIControlState.normal)
                Answer4.setTitle("el teatro", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 25:
                Question.text = "How do you say 'bullring'?"
                Answer1.setTitle("la plaza de toros", for: UIControlState.normal)
                Answer2.setTitle("la granja de toros", for: UIControlState.normal)
                Answer3.setTitle("la sala de toros", for: UIControlState.normal)
                Answer4.setTitle("el parque de toros", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 26:
                Question.text = "How do you say 'concert hall'?"
                Answer1.setTitle("el pasillo de conciertos", for: UIControlState.normal)
                Answer2.setTitle("la sala de conciertos", for: UIControlState.normal)
                Answer3.setTitle("la plaza de conciertos", for: UIControlState.normal)
                Answer4.setTitle("el teatro", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 27:
                Question.text = "How do you say 'department store'?"
                Answer1.setTitle("la granja", for: UIControlState.normal)
                Answer2.setTitle("la tiende grande", for: UIControlState.normal)
                Answer3.setTitle("los grandes almacenes", for: UIControlState.normal)
                Answer4.setTitle("la charcutería", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 28:
                Question.text = "How do you say 'synagogue'?"
                Answer1.setTitle("el templo", for: UIControlState.normal)
                Answer2.setTitle("la iglesia", for: UIControlState.normal)
                Answer3.setTitle("la mezquita", for: UIControlState.normal)
                Answer4.setTitle("la sinagoga", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 29:
                Question.text = "How do you say 'mosque'?"
                Answer1.setTitle("la mezquita", for: UIControlState.normal)
                Answer2.setTitle("el mosque", for: UIControlState.normal)
                Answer3.setTitle("el barrio", for: UIControlState.normal)
                Answer4.setTitle("el templo", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 30:
                Question.text = "How do you say 'cinema'?"
                Answer1.setTitle("el teatro", for: UIControlState.normal)
                Answer2.setTitle("el cine", for: UIControlState.normal)
                Answer3.setTitle("la película", for: UIControlState.normal)
                Answer4.setTitle("el circo", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 31:
                Question.text = "How do you say 'pharmacy'?"
                Answer1.setTitle("la droguería", for: UIControlState.normal)
                Answer2.setTitle("la frutería", for: UIControlState.normal)
                Answer3.setTitle("la farmacia", for: UIControlState.normal)
                Answer4.setTitle("el estanco", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 32:
                Question.text = "How do you say 'fruit shop'?"
                Answer1.setTitle("la pastelería", for: UIControlState.normal)
                Answer2.setTitle("la joyería", for: UIControlState.normal)
                Answer3.setTitle("la verdulería", for: UIControlState.normal)
                Answer4.setTitle("la frutería", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 33:
                Question.text = "How do you say 'jewellery shop'?"
                Answer1.setTitle("la joyería", for: UIControlState.normal)
                Answer2.setTitle("la jewlería", for: UIControlState.normal)
                Answer3.setTitle("la juguetería", for: UIControlState.normal)
                Answer4.setTitle("la lavandería", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 34:
                Question.text = "How do you say 'toy shop'?"
                Answer1.setTitle("la joyería", for: UIControlState.normal)
                Answer2.setTitle("la juguetería", for: UIControlState.normal)
                Answer3.setTitle("la librería", for: UIControlState.normal)
                Answer4.setTitle("la toyería", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 35:
                Question.text = "How do you say 'laundrette'?"
                Answer1.setTitle("la laboratorio", for: UIControlState.normal)
                Answer2.setTitle("la pescadería", for: UIControlState.normal)
                Answer3.setTitle("la lavandería", for: UIControlState.normal)
                Answer4.setTitle("la tintorería", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 36:
                Question.text = "How do you say 'bookshop'?"
                Answer1.setTitle("la librería", for: UIControlState.normal)
                Answer2.setTitle("la papelería", for: UIControlState.normal)
                Answer3.setTitle("la fábrica", for: UIControlState.normal)
                Answer4.setTitle("la biblioteca", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 37:
                Question.text = "How do you say 'hardware shop'?"
                Answer1.setTitle("la mercería", for: UIControlState.normal)
                Answer2.setTitle("el mercado", for: UIControlState.normal)
                Answer3.setTitle("la marca", for: UIControlState.normal)
                Answer4.setTitle("la tienda de edificio", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 38:
                Question.text = "How do you say 'stationery shop'?"
                Answer1.setTitle("la peluquería", for: UIControlState.normal)
                Answer2.setTitle("la papelería", for: UIControlState.normal)
                Answer3.setTitle("la tintorería", for: UIControlState.normal)
                Answer4.setTitle("la librería", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 39:
                Question.text = "How do you say 'cake shop'?"
                Answer1.setTitle("la panadería", for: UIControlState.normal)
                Answer2.setTitle("la pescadería", for: UIControlState.normal)
                Answer3.setTitle("la pastelería", for: UIControlState.normal)
                Answer4.setTitle("el polideportivo", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 40:
                Question.text = "How do you say 'bakery'?"
                Answer1.setTitle("la pastelería", for: UIControlState.normal)
                Answer2.setTitle("el albaricoque", for: UIControlState.normal)
                Answer3.setTitle("la peluquería", for: UIControlState.normal)
                Answer4.setTitle("la panadería", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 41:
                Question.text = "How do you say 'fish shop'?"
                Answer1.setTitle("la pescadería", for: UIControlState.normal)
                Answer2.setTitle("la peluquería", for: UIControlState.normal)
                Answer3.setTitle("la panadería", for: UIControlState.normal)
                Answer4.setTitle("la pastelería", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 42:
                Question.text = "How do you say 'hairdresser's'?"
                Answer1.setTitle("la pescadería", for: UIControlState.normal)
                Answer2.setTitle("la peluquería", for: UIControlState.normal)
                Answer3.setTitle("la lavandería", for: UIControlState.normal)
                Answer4.setTitle("el estanco", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 43:
                Question.text = "How do you say 'dry cleaner's'?"
                Answer1.setTitle("la lavandería", for: UIControlState.normal)
                Answer2.setTitle("la verdulería", for: UIControlState.normal)
                Answer3.setTitle("la tintorería", for: UIControlState.normal)
                Answer4.setTitle("la zapatería", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 44:
                Question.text = "How do you say 'greengrocer's'?"
                Answer1.setTitle("la frutería", for: UIControlState.normal)
                Answer2.setTitle("la farmacia", for: UIControlState.normal)
                Answer3.setTitle("la comisaría", for: UIControlState.normal)
                Answer4.setTitle("la verdulería", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
                
            case 45:
                Question.text = "How do you say 'shoe shop'?"
                Answer1.setTitle("la zapatería", for: UIControlState.normal)
                Answer2.setTitle("la tintorería", for: UIControlState.normal)
                Answer3.setTitle("la tienda de los zapatos", for: UIControlState.normal)
                Answer4.setTitle("la mercería", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 46:
                Question.text = "How do you say 'restaurant'?"
                Answer1.setTitle("el hotel", for: UIControlState.normal)
                Answer2.setTitle("la hotel", for: UIControlState.normal)
                Answer3.setTitle("el restaurante", for: UIControlState.normal)
                Answer4.setTitle("la restaurante", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
                
            case 47:
                Question.text = "How do you say 'fast food restaurant'?"
                Answer1.setTitle("la pizzería", for: UIControlState.normal)
                Answer2.setTitle("el café", for: UIControlState.normal)
                Answer3.setTitle("la hamburguesería", for: UIControlState.normal)
                Answer4.setTitle("el restaurante rápida", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 48:
                Question.text = "How do you say 'library'?"
                Answer1.setTitle("la librería", for: UIControlState.normal)
                Answer2.setTitle("la papelería", for: UIControlState.normal)
                Answer3.setTitle("el estanco", for: UIControlState.normal)
                Answer4.setTitle("la biblioteca", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 49:
                Question.text = "How do you say 'factory'?"
                Answer1.setTitle("la fábrica", for: UIControlState.normal)
                Answer2.setTitle("la fabricación", for: UIControlState.normal)
                Answer3.setTitle("el fabricado", for: UIControlState.normal)
                Answer4.setTitle("la fabricante", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 50:
                Question.text = "How do you say 'football stadium'?"
                Answer1.setTitle("la plaza de fútbol", for: UIControlState.normal)
                Answer2.setTitle("el estadio de fútbol", for: UIControlState.normal)
                Answer3.setTitle("la pista de fútbol", for: UIControlState.normal)
                Answer4.setTitle("el campo de fútbol", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 51:
                Question.text = "How do you say 'swimming pool'?"
                Answer1.setTitle("el bañador", for: UIControlState.normal)
                Answer2.setTitle("el traje de baño", for: UIControlState.normal)
                Answer3.setTitle("la piscina", for: UIControlState.normal)
                Answer4.setTitle("la piscifactoría", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 52:
                Question.text = "How do you say 'sports centre'?"
                Answer1.setTitle("el centro de deportes", for: UIControlState.normal)
                Answer2.setTitle("el deportivo", for: UIControlState.normal)
                Answer3.setTitle("la plaza de deportes", for: UIControlState.normal)
                Answer4.setTitle("el polideportivo", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 53:
                Question.text = "How do you say 'golf course'?"
                Answer1.setTitle("el campo de golf", for: UIControlState.normal)
                Answer2.setTitle("el club de golf", for: UIControlState.normal)
                Answer3.setTitle("la pista de golf", for: UIControlState.normal)
                Answer4.setTitle("el estadio de golf", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 54:
                Question.text = "How do you say 'gym'?"
                Answer1.setTitle("la gimnasio", for: UIControlState.normal)
                Answer2.setTitle("el gimnasio", for: UIControlState.normal)
                Answer3.setTitle("la pista de atletismo", for: UIControlState.normal)
                Answer4.setTitle("el pista de atletismo", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 55:
                Question.text = "How do you say 'park'?"
                Answer1.setTitle("el paseo", for: UIControlState.normal)
                Answer2.setTitle("el pasillo", for: UIControlState.normal)
                Answer3.setTitle("el parque", for: UIControlState.normal)
                Answer4.setTitle("la parque", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 56:
                Question.text = "How do you say 'lake'?"
                Answer1.setTitle("el lago", for: UIControlState.normal)
                Answer2.setTitle("la lago", for: UIControlState.normal)
                Answer3.setTitle("el río", for: UIControlState.normal)
                Answer4.setTitle("la río", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 57:
                Question.text = "How do you say 'river'?"
                Answer1.setTitle("el río", for: UIControlState.normal)
                Answer2.setTitle("la río", for: UIControlState.normal)
                Answer3.setTitle("el lago", for: UIControlState.normal)
                Answer4.setTitle("la lago", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 58:
                Question.text = "How do you say 'zoo'?"
                Answer1.setTitle("la zoológico", for: UIControlState.normal)
                Answer2.setTitle("el zoológico", for: UIControlState.normal)
                Answer3.setTitle("la zoólogo", for: UIControlState.normal)
                Answer4.setTitle("el zoólogo", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 59:
                Question.text = "How do you say 'police station'?"
                Answer1.setTitle("el estación de policía", for: UIControlState.normal)
                Answer2.setTitle("la estación de policía", for: UIControlState.normal)
                Answer3.setTitle("la comisaría", for: UIControlState.normal)
                Answer4.setTitle("el comisaría", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 60:
                Question.text = "How do you say 'town hall'?"
                Answer1.setTitle("la plaza mayor", for: UIControlState.normal)
                Answer2.setTitle("la calle", for: UIControlState.normal)
                Answer3.setTitle("el juzgado", for: UIControlState.normal)
                Answer4.setTitle("el ayuntamiento", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 61:
                Question.text = "How do you say 'court'?"
                Answer1.setTitle("la plaza mayor", for: UIControlState.normal)
                Answer2.setTitle("el juzgado", for: UIControlState.normal)
                Answer3.setTitle("la plaza", for: UIControlState.normal)
                Answer4.setTitle("la calle", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 62:
                Question.text = "How do you say 'fire station'?"
                Answer1.setTitle("la estación de bomberos", for: UIControlState.normal)
                Answer2.setTitle("el estación de bomberos", for: UIControlState.normal)
                Answer3.setTitle("el parque de bomberos", for: UIControlState.normal)
                Answer4.setTitle("la parque de bomberos", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 63:
                Question.text = "How do you say 'car park'?"
                Answer1.setTitle("el parking", for: UIControlState.normal)
                Answer2.setTitle("la aparcamiento", for: UIControlState.normal)
                Answer3.setTitle("la parking", for: UIControlState.normal)
                Answer4.setTitle("el aparcamiento", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
                
            case 64:
                Question.text = "How do you say 'bridge'?"
                Answer1.setTitle("el puente", for: UIControlState.normal)
                Answer2.setTitle("la calle", for: UIControlState.normal)
                Answer3.setTitle("el juzgado", for: UIControlState.normal)
                Answer4.setTitle("el lago", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 65:
                Question.text = "How do you say 'street' Spanish?"
                Answer1.setTitle("el calle", for: UIControlState.normal)
                Answer2.setTitle("la calle", for: UIControlState.normal)
                Answer3.setTitle("el juzgado", for: UIControlState.normal)
                Answer4.setTitle("la juzgado", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 66:
                Question.text = "How do you say 'main square'?"
                Answer1.setTitle("el calle mayor", for: UIControlState.normal)
                Answer2.setTitle("la primera calle", for: UIControlState.normal)
                Answer3.setTitle("la plaza mayor", for: UIControlState.normal)
                Answer4.setTitle("el puente", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 67:
                Question.text = "How do you say 'airport'?"
                Answer1.setTitle("el autopista", for: UIControlState.normal)
                Answer2.setTitle("la estación de aviones", for: UIControlState.normal)
                Answer3.setTitle("el airport", for: UIControlState.normal)
                Answer4.setTitle("el aeropuerto", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 68:
                Question.text = "How do you say 'bank'?"
                Answer1.setTitle("el banco", for: UIControlState.normal)
                Answer2.setTitle("la banco", for: UIControlState.normal)
                Answer3.setTitle("el correo", for: UIControlState.normal)
                Answer4.setTitle("la correo", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 69:
                Question.text = "How do you say 'post office'?"
                Answer1.setTitle("la comisaría", for: UIControlState.normal)
                Answer2.setTitle("la oficina de correos", for: UIControlState.normal)
                Answer3.setTitle("la oficina de turismo", for: UIControlState.normal)
                Answer4.setTitle("la oficina del director", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 70:
                Question.text = "How do you say 'bus stop'?"
                Answer1.setTitle("la estación de autobuses", for: UIControlState.normal)
                Answer2.setTitle("la avenida de autobús", for: UIControlState.normal)
                Answer3.setTitle("la parada de autobús", for: UIControlState.normal)
                Answer4.setTitle("el colegio de autobús", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 71:
                Question.text = "How do you say 'address'?"
                Answer1.setTitle("el addresso", for: UIControlState.normal)
                Answer2.setTitle("la cuenta", for: UIControlState.normal)
                Answer3.setTitle("el barrio", for: UIControlState.normal)
                Answer4.setTitle("la dirección", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 72:
                Question.text = "How do you say 'train'?"
                Answer1.setTitle("el tren", for: UIControlState.normal)
                Answer2.setTitle("la tren", for: UIControlState.normal)
                Answer3.setTitle("el trene", for: UIControlState.normal)
                Answer4.setTitle("la trene", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 73:
                Question.text = "How do you say 'traffic lights'?"
                Answer1.setTitle("los aviones", for: UIControlState.normal)
                Answer2.setTitle("los semáforos", for: UIControlState.normal)
                Answer3.setTitle("las paradas", for: UIControlState.normal)
                Answer4.setTitle("los buzones", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 74:
                Question.text = "How do you say 'post box'?"
                Answer1.setTitle("la carretera", for: UIControlState.normal)
                Answer2.setTitle("la esquina", for: UIControlState.normal)
                Answer3.setTitle("el buzón", for: UIControlState.normal)
                Answer4.setTitle("la farola", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
                
            case 75:
                Question.text = "How do you say 'streetlight'?"
                Answer1.setTitle("el buzón", for: UIControlState.normal)
                Answer2.setTitle("la esquina", for: UIControlState.normal)
                Answer3.setTitle("le leche", for: UIControlState.normal)
                Answer4.setTitle("la farola", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 76:
                Question.text = "How do you say 'fountain'?"
                Answer1.setTitle("la fuente", for: UIControlState.normal)
                Answer2.setTitle("el puente", for: UIControlState.normal)
                Answer3.setTitle("el buzón", for: UIControlState.normal)
                Answer4.setTitle("el autopista", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 77:
                Question.text = "How do you say 'drain'?"
                Answer1.setTitle("el drain", for: UIControlState.normal)
                Answer2.setTitle("la alcantarilla", for: UIControlState.normal)
                Answer3.setTitle("el barco", for: UIControlState.normal)
                Answer4.setTitle("el buzón", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 78:
                Question.text = "How do you say 'sidewalk'?"
                Answer1.setTitle("la carretera", for: UIControlState.normal)
                Answer2.setTitle("el camión", for: UIControlState.normal)
                Answer3.setTitle("el acera", for: UIControlState.normal)
                Answer4.setTitle("el autopista", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 79:
                Question.text = "How do you say 'train station'?"
                Answer1.setTitle("la entrenamiento", for: UIControlState.normal)
                Answer2.setTitle("el entrenamiento", for: UIControlState.normal)
                Answer3.setTitle("el estación de trenes", for: UIControlState.normal)
                Answer4.setTitle("la estación de trenes", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 80:
                Question.text = "How do you say 'university'?"
                Answer1.setTitle("la universidad", for: UIControlState.normal)
                Answer2.setTitle("el universidad", for: UIControlState.normal)
                Answer3.setTitle("la univerdad", for: UIControlState.normal)
                Answer4.setTitle("el univerdad", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
                
            case 81:
                Question.text = "How do you say 'car park'?"
                Answer1.setTitle("la carretera", for: UIControlState.normal)
                Answer2.setTitle("el aparcamiento", for: UIControlState.normal)
                Answer3.setTitle("el ferrocarril", for: UIControlState.normal)
                Answer4.setTitle("el ahogamiento", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 82:
                Question.text = "How do you say 'bowling alley'?"
                Answer1.setTitle("la biblioteca", for: UIControlState.normal)
                Answer2.setTitle("la bomba", for: UIControlState.normal)
                Answer3.setTitle("la bolera", for: UIControlState.normal)
                Answer4.setTitle("el bar", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 83:
                Question.text = "How do you say 'jail'?"
                Answer1.setTitle("la caja", for: UIControlState.normal)
                Answer2.setTitle("la cárcel", for: UIControlState.normal)
                Answer3.setTitle("el ahogamiento", for: UIControlState.normal)
                Answer4.setTitle("el atasco", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 84:
                Question.text = "How do you say 'prison'?"
                Answer1.setTitle("la prisión", for: UIControlState.normal)
                Answer2.setTitle("la primavera", for: UIControlState.normal)
                Answer3.setTitle("el pirámide", for: UIControlState.normal)
                Answer4.setTitle("el preparatorio", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            default:
                break
            }
        } else if quizTypeToBegin == "Hobbies" {
            RandomNumber = arc4random() % 94
            RandomNumber += 1
            print("\(RandomNumber)")
            
            switch (RandomNumber) {
            case 1:
                Question.text = "'Hacer gimnasia' is..."
                Answer1.setTitle("to do gymnastics", for: UIControlState.normal)
                Answer2.setTitle("to go to the gym", for: UIControlState.normal)
                Answer3.setTitle("to lift weights", for: UIControlState.normal)
                Answer4.setTitle("to go jogging", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 2:
                Question.text = "'Hacer pesas' is..."
                Answer1.setTitle("to go to the gym", for: UIControlState.normal)
                Answer2.setTitle("to do weights", for: UIControlState.normal)
                Answer3.setTitle("to count money", for: UIControlState.normal)
                Answer4.setTitle("to do push-ups", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 3:
                Question.text = "‘Jugar al bádminton' is..."
                Answer1.setTitle("to play basketball", for: UIControlState.normal)
                Answer2.setTitle("to play football", for: UIControlState.normal)
                Answer3.setTitle("to play badminton", for: UIControlState.normal)
                Answer4.setTitle("to play tennis", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 4:
                Question.text = "'Jugar al baloncesto' is..."
                Answer1.setTitle("to play badminton", for: UIControlState.normal)
                Answer2.setTitle("to play volleyball", for: UIControlState.normal)
                Answer3.setTitle("to play squash", for: UIControlState.normal)
                Answer4.setTitle("to play basketball", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 5:
                Question.text = "'Jugar al cricket' is..."
                Answer1.setTitle("to play cricket", for: UIControlState.normal)
                Answer2.setTitle("to play basketball", for: UIControlState.normal)
                Answer3.setTitle("to play volleyball", for: UIControlState.normal)
                Answer4.setTitle("to play croquet", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 6:
                Question.text = "'Jugar al fútbol' is..."
                Answer1.setTitle("to play rugby", for: UIControlState.normal)
                Answer2.setTitle("to play football", for: UIControlState.normal)
                Answer3.setTitle("to watch football", for: UIControlState.normal)
                Answer4.setTitle("to watch rugby", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 7:
                Question.text = "'Jugar al golf' is..."
                Answer1.setTitle("to play croquet", for: UIControlState.normal)
                Answer2.setTitle("to play tennis", for: UIControlState.normal)
                Answer3.setTitle("to play golf", for: UIControlState.normal)
                Answer4.setTitle("to play hockey", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 8:
                Question.text = "'Jugar al hockey' is..."
                Answer1.setTitle("to play croquet", for: UIControlState.normal)
                Answer2.setTitle("to play ice-hockey", for: UIControlState.normal)
                Answer3.setTitle("to play bowling", for: UIControlState.normal)
                Answer4.setTitle("to play hockey", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 9:
                Question.text = "'Jugar a los bolos' is..."
                Answer1.setTitle("to play bowling", for: UIControlState.normal)
                Answer2.setTitle("to play croquet", for: UIControlState.normal)
                Answer3.setTitle("to play squash", for: UIControlState.normal)
                Answer4.setTitle("to play tennis", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 10:
                Question.text = "'Jugar al rugby' is..."
                Answer1.setTitle("to play football", for: UIControlState.normal)
                Answer2.setTitle("to play rugby", for: UIControlState.normal)
                Answer3.setTitle("to play tennis", for: UIControlState.normal)
                Answer4.setTitle("to play squash", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 11:
                Question.text = "'Jugar al squash' is..."
                Answer1.setTitle("to play tennis", for: UIControlState.normal)
                Answer2.setTitle("to play badminton", for: UIControlState.normal)
                Answer3.setTitle("to play squash", for: UIControlState.normal)
                Answer4.setTitle("to play croquet", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 12:
                Question.text = "'Jugar al tenis' is..."
                Answer1.setTitle("to play badminton", for: UIControlState.normal)
                Answer2.setTitle("to play darts", for: UIControlState.normal)
                Answer3.setTitle("to play basketball", for: UIControlState.normal)
                Answer4.setTitle("to play tennis", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 13:
                Question.text = "'El alpinismo' is..."
                Answer1.setTitle("mountaineering", for: UIControlState.normal)
                Answer2.setTitle("sailing", for: UIControlState.normal)
                Answer3.setTitle("hiking", for: UIControlState.normal)
                Answer4.setTitle("diving", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 14:
                Question.text = "'El automovilismo' is..."
                Answer1.setTitle("driving", for: UIControlState.normal)
                Answer2.setTitle("motor racing", for: UIControlState.normal)
                Answer3.setTitle("cycling", for: UIControlState.normal)
                Answer4.setTitle("fixing cars", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 15:
                Question.text = "'Las artes marciales' is..."
                Answer1.setTitle("material arts", for: UIControlState.normal)
                Answer2.setTitle("musical arts", for: UIControlState.normal)
                Answer3.setTitle("martial arts", for: UIControlState.normal)
                Answer4.setTitle("an art gallery", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 16:
                Question.text = "'El billar' is..."
                Answer1.setTitle("pool", for: UIControlState.normal)
                Answer2.setTitle("darts", for: UIControlState.normal)
                Answer3.setTitle("poker", for: UIControlState.normal)
                Answer4.setTitle("snooker", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 17:
                Question.text = "'El billar americano’ is..."
                Answer1.setTitle("pool", for: UIControlState.normal)
                Answer2.setTitle("darts", for: UIControlState.normal)
                Answer3.setTitle("poker", for: UIControlState.normal)
                Answer4.setTitle("snooker", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 18:
                Question.text = "‘Tocar música' is..."
                Answer1.setTitle("to take music lessons", for: UIControlState.normal)
                Answer2.setTitle("to play music", for: UIControlState.normal)
                Answer3.setTitle("to write music", for: UIControlState.normal)
                Answer4.setTitle("to sing", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 19:
                Question.text = "'Escuchar música' is..."
                Answer1.setTitle("to make music", for: UIControlState.normal)
                Answer2.setTitle("to play music", for: UIControlState.normal)
                Answer3.setTitle("to listen to music", for: UIControlState.normal)
                Answer4.setTitle("to sing", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 20:
                Question.text = "'Cantar' is..."
                Answer1.setTitle("to chant", for: UIControlState.normal)
                Answer2.setTitle("to sing", for: UIControlState.normal)
                Answer3.setTitle("to play an instrument", for: UIControlState.normal)
                Answer4.setTitle("to ride a horse", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
                
            case 21:
                Question.text = "'La música clasica' is..."
                Answer1.setTitle("classical music", for: UIControlState.normal)
                Answer2.setTitle("rap music", for: UIControlState.normal)
                Answer3.setTitle("folk music", for: UIControlState.normal)
                Answer4.setTitle("dance music", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 22:
                Question.text = "'La música folk' is..."
                Answer1.setTitle("rap music", for: UIControlState.normal)
                Answer2.setTitle("folk music", for: UIControlState.normal)
                Answer3.setTitle("pop music", for: UIControlState.normal)
                Answer4.setTitle("rock music", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 23:
                Question.text = "'La música pop' is..."
                Answer1.setTitle("rap music", for: UIControlState.normal)
                Answer2.setTitle("dance music", for: UIControlState.normal)
                Answer3.setTitle("pop music", for: UIControlState.normal)
                Answer4.setTitle("rock music", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 24:
                Question.text = "‘La música de baile' is..."
                Answer1.setTitle("rock music", for: UIControlState.normal)
                Answer2.setTitle("orchestral music", for: UIControlState.normal)
                Answer3.setTitle("rap music", for: UIControlState.normal)
                Answer4.setTitle("dance music", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 25:
                Question.text = "'La canción' is..."
                Answer1.setTitle("a song", for: UIControlState.normal)
                Answer2.setTitle("a singer", for: UIControlState.normal)
                Answer3.setTitle("to sing", for: UIControlState.normal)
                Answer4.setTitle("a choir", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 26:
                Question.text = "'El concierto' is..."
                Answer1.setTitle("an opera", for: UIControlState.normal)
                Answer2.setTitle("a concert", for: UIControlState.normal)
                Answer3.setTitle("a choir", for: UIControlState.normal)
                Answer4.setTitle("a show", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 27:
                Question.text = "'Lost instrumentos' is..."
                Answer1.setTitle("instrumental music", for: UIControlState.normal)
                Answer2.setTitle("a choir", for: UIControlState.normal)
                Answer3.setTitle("instruments", for: UIControlState.normal)
                Answer4.setTitle("an orchestra", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 28:
                Question.text = "'La guitarrra' is..."
                Answer1.setTitle("the bass", for: UIControlState.normal)
                Answer2.setTitle("the electric guitar", for: UIControlState.normal)
                Answer3.setTitle("the cello", for: UIControlState.normal)
                Answer4.setTitle("the guitar", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 29:
                Question.text = "'El piano' is..."
                Answer1.setTitle("the piano", for: UIControlState.normal)
                Answer2.setTitle("the keyboard", for: UIControlState.normal)
                Answer3.setTitle("the xylophone", for: UIControlState.normal)
                Answer4.setTitle("the orchestra", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 30:
                Question.text = "'El teclado' is..."
                Answer1.setTitle("the drums", for: UIControlState.normal)
                Answer2.setTitle("the keyboard", for: UIControlState.normal)
                Answer3.setTitle("the electric guitar", for: UIControlState.normal)
                Answer4.setTitle("the piano", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 31:
                Question.text = "'La batería' is..."
                Answer1.setTitle("batteries", for: UIControlState.normal)
                Answer2.setTitle("the guitar", for: UIControlState.normal)
                Answer3.setTitle("the drums", for: UIControlState.normal)
                Answer4.setTitle("the keyboard", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 32:
                Question.text = "'El violín' is..."
                Answer1.setTitle("the guitar", for: UIControlState.normal)
                Answer2.setTitle("the cello", for: UIControlState.normal)
                Answer3.setTitle("the viola", for: UIControlState.normal)
                Answer4.setTitle("the violin", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 33:
                Question.text = "‘La lectura' is..."
                Answer1.setTitle("reading", for: UIControlState.normal)
                Answer2.setTitle("to read", for: UIControlState.normal)
                Answer3.setTitle("a book", for: UIControlState.normal)
                Answer4.setTitle("a lecturer", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 34:
                Question.text = "'Leer' is..."
                Answer1.setTitle("a river", for: UIControlState.normal)
                Answer2.setTitle("to read", for: UIControlState.normal)
                Answer3.setTitle("to sing", for: UIControlState.normal)
                Answer4.setTitle("to lecture", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 35:
                Question.text = "'El libro' is..."
                Answer1.setTitle("a library", for: UIControlState.normal)
                Answer2.setTitle("a dictionary", for: UIControlState.normal)
                Answer3.setTitle("a book", for: UIControlState.normal)
                Answer4.setTitle("a bookstore", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 36:
                Question.text = "'El buceo' is..."
                Answer1.setTitle("sailing", for: UIControlState.normal)
                Answer2.setTitle("swimming", for: UIControlState.normal)
                Answer3.setTitle("canoeing", for: UIControlState.normal)
                Answer4.setTitle("diving", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 37:
                Question.text = "'Correr' is..."
                Answer1.setTitle("to run", for: UIControlState.normal)
                Answer2.setTitle("to walk", for: UIControlState.normal)
                Answer3.setTitle("to jog", for: UIControlState.normal)
                Answer4.setTitle("to go", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 38:
                Question.text = "'Los deportes acuáticos' is..."
                Answer1.setTitle("team sports", for: UIControlState.normal)
                Answer2.setTitle("water sports", for: UIControlState.normal)
                Answer3.setTitle("combat sports", for: UIControlState.normal)
                Answer4.setTitle("competition sports", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 39:
                Question.text = "'Los deportes de combate' is..."
                Answer1.setTitle("water sports", for: UIControlState.normal)
                Answer2.setTitle("team sports", for: UIControlState.normal)
                Answer3.setTitle("combat sports", for: UIControlState.normal)
                Answer4.setTitle("competition sports", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 40:
                Question.text = "'La equitación' is..."
                Answer1.setTitle("skate boarding", for: UIControlState.normal)
                Answer2.setTitle("fishing", for: UIControlState.normal)
                Answer3.setTitle("sailing", for: UIControlState.normal)
                Answer4.setTitle("horse riding", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 41:
                Question.text = "'La escalada' is..."
                Answer1.setTitle("climbing", for: UIControlState.normal)
                Answer2.setTitle("an elevator", for: UIControlState.normal)
                Answer3.setTitle("mountaineering", for: UIControlState.normal)
                Answer4.setTitle("heights", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 42:
                Question.text = "'El esquí' is..."
                Answer1.setTitle("skating", for: UIControlState.normal)
                Answer2.setTitle("skiing", for: UIControlState.normal)
                Answer3.setTitle("sailing", for: UIControlState.normal)
                Answer4.setTitle("ice-skating", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 43:
                Question.text = "'El footing' is..."
                Answer1.setTitle("running", for: UIControlState.normal)
                Answer2.setTitle("feet", for: UIControlState.normal)
                Answer3.setTitle("jogging", for: UIControlState.normal)
                Answer4.setTitle("walking", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 44:
                Question.text = "'Montar el monopatín' is..."
                Answer1.setTitle("horse riding", for: UIControlState.normal)
                Answer2.setTitle("hunting", for: UIControlState.normal)
                Answer3.setTitle("darts", for: UIControlState.normal)
                Answer4.setTitle("to skateboard", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
                
            case 45:
                Question.text = "'El patinaje' is..."
                Answer1.setTitle("skating", for: UIControlState.normal)
                Answer2.setTitle("ice-skating ", for: UIControlState.normal)
                Answer3.setTitle("swimming", for: UIControlState.normal)
                Answer4.setTitle("skiing", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 46:
                Question.text = "'El patinaje sobre hielo' is..."
                Answer1.setTitle("skating", for: UIControlState.normal)
                Answer2.setTitle("ice-skating", for: UIControlState.normal)
                Answer3.setTitle("swimming", for: UIControlState.normal)
                Answer4.setTitle("skiing", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
                
            case 47:
                Question.text = "'La pesca' is..."
                Answer1.setTitle("sailing", for: UIControlState.normal)
                Answer2.setTitle("swimming", for: UIControlState.normal)
                Answer3.setTitle("fishing", for: UIControlState.normal)
                Answer4.setTitle("canoeing", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 48:
                Question.text = "'El piragüismo' is..."
                Answer1.setTitle("hiking", for: UIControlState.normal)
                Answer2.setTitle("swimming", for: UIControlState.normal)
                Answer3.setTitle("sailing", for: UIControlState.normal)
                Answer4.setTitle("canoeing", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 49:
                Question.text = "'Remar' is..."
                Answer1.setTitle("to row", for: UIControlState.normal)
                Answer2.setTitle("to sail", for: UIControlState.normal)
                Answer3.setTitle("to swim", for: UIControlState.normal)
                Answer4.setTitle("to hike", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 50:
                Question.text = "'El senderismo' is..."
                Answer1.setTitle("canoeing", for: UIControlState.normal)
                Answer2.setTitle("hiking", for: UIControlState.normal)
                Answer3.setTitle("sailing", for: UIControlState.normal)
                Answer4.setTitle("swimming", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 51:
                Question.text = "'El tiro con arco' is..."
                Answer1.setTitle("sailing", for: UIControlState.normal)
                Answer2.setTitle("swimming", for: UIControlState.normal)
                Answer3.setTitle("archery", for: UIControlState.normal)
                Answer4.setTitle("paintball", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 52:
                Question.text = "'La vela' is..."
                Answer1.setTitle("reading", for: UIControlState.normal)
                Answer2.setTitle("shooting", for: UIControlState.normal)
                Answer3.setTitle("swimming", for: UIControlState.normal)
                Answer4.setTitle("sailing", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 53:
                Question.text = "'La novela' is..."
                Answer1.setTitle("a novel", for: UIControlState.normal)
                Answer2.setTitle("a reference book", for: UIControlState.normal)
                Answer3.setTitle("a fairy", for: UIControlState.normal)
                Answer4.setTitle("a children's book", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 54:
                Question.text = "'La revista' is..."
                Answer1.setTitle("a newspaper", for: UIControlState.normal)
                Answer2.setTitle("a magazine", for: UIControlState.normal)
                Answer3.setTitle("a map", for: UIControlState.normal)
                Answer4.setTitle("a leaflet", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 55:
                Question.text = "'El cómic' is..."
                Answer1.setTitle("funny", for: UIControlState.normal)
                Answer2.setTitle("a comedy film", for: UIControlState.normal)
                Answer3.setTitle("a comic", for: UIControlState.normal)
                Answer4.setTitle("a romantic comedy film", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 56:
                Question.text = "'Los juegos' is..."
                Answer1.setTitle("children", for: UIControlState.normal)
                Answer2.setTitle("toys", for: UIControlState.normal)
                Answer3.setTitle("matches", for: UIControlState.normal)
                Answer4.setTitle("games", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 57:
                Question.text = "‘Los juegos de mesa' is..."
                Answer1.setTitle("board games", for: UIControlState.normal)
                Answer2.setTitle("outdoor games", for: UIControlState.normal)
                Answer3.setTitle("computer games", for: UIControlState.normal)
                Answer4.setTitle("messy games", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 58:
                Question.text = "'Los dardos' is..."
                Answer1.setTitle("chess", for: UIControlState.normal)
                Answer2.setTitle("darts", for: UIControlState.normal)
                Answer3.setTitle("draughts", for: UIControlState.normal)
                Answer4.setTitle("board games", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 59:
                Question.text = "'Las cartas' is..."
                Answer1.setTitle("paper", for: UIControlState.normal)
                Answer2.setTitle("money", for: UIControlState.normal)
                Answer3.setTitle("cards", for: UIControlState.normal)
                Answer4.setTitle("tickets", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 60:
                Question.text = "'El ajedrez' is..."
                Answer1.setTitle("hockey", for: UIControlState.normal)
                Answer2.setTitle("draughts", for: UIControlState.normal)
                Answer3.setTitle("darts", for: UIControlState.normal)
                Answer4.setTitle("chess", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 61:
                Question.text = "'Pintar' is..."
                Answer1.setTitle("to wash", for: UIControlState.normal)
                Answer2.setTitle("to paint", for: UIControlState.normal)
                Answer3.setTitle("to draw", for: UIControlState.normal)
                Answer4.setTitle("to colour", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 62:
                Question.text = "'La pintura' is..."
                Answer1.setTitle("drawing", for: UIControlState.normal)
                Answer2.setTitle("colouring", for: UIControlState.normal)
                Answer3.setTitle("painting", for: UIControlState.normal)
                Answer4.setTitle("washing", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 63:
                Question.text = "'Dibujar' is..."
                Answer1.setTitle("to paint", for: UIControlState.normal)
                Answer2.setTitle("to colour", for: UIControlState.normal)
                Answer3.setTitle("to wash", for: UIControlState.normal)
                Answer4.setTitle("to draw", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
                
            case 64:
                Question.text = "'El dibujo' is..."
                Answer1.setTitle("drawing", for: UIControlState.normal)
                Answer2.setTitle("painting", for: UIControlState.normal)
                Answer3.setTitle("colouring", for: UIControlState.normal)
                Answer4.setTitle("washing", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 65:
                Question.text = "'El escaltura' is..."
                Answer1.setTitle("climbing", for: UIControlState.normal)
                Answer2.setTitle("sculpture", for: UIControlState.normal)
                Answer3.setTitle("scripture", for: UIControlState.normal)
                Answer4.setTitle("trampolining", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 66:
                Question.text = "'La moda' is..."
                Answer1.setTitle("health", for: UIControlState.normal)
                Answer2.setTitle("education", for: UIControlState.normal)
                Answer3.setTitle("fashion", for: UIControlState.normal)
                Answer4.setTitle("technology", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 67:
                Question.text = "'Sacar fotos' is..."
                Answer1.setTitle("to be a photographer", for: UIControlState.normal)
                Answer2.setTitle("to print photos", for: UIControlState.normal)
                Answer3.setTitle("to edit pictures", for: UIControlState.normal)
                Answer4.setTitle("to take pictures", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 68:
                Question.text = "'La fotografía' is..."
                Answer1.setTitle("a photograph", for: UIControlState.normal)
                Answer2.setTitle("a photographer", for: UIControlState.normal)
                Answer3.setTitle("photography", for: UIControlState.normal)
                Answer4.setTitle("a camera", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
                
            case 69:
                Question.text = "'Salir con los amigos' is..."
                Answer1.setTitle("to go to the cinema", for: UIControlState.normal)
                Answer2.setTitle("to go out with friends", for: UIControlState.normal)
                Answer3.setTitle("to stay with friends", for: UIControlState.normal)
                Answer4.setTitle("to play with friends", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 70:
                Question.text = "‘Ir de compras' is..."
                Answer1.setTitle("to go to the park", for: UIControlState.normal)
                Answer2.setTitle("to go for a walk", for: UIControlState.normal)
                Answer3.setTitle("to go shopping", for: UIControlState.normal)
                Answer4.setTitle("to go on a trip", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 71:
                Question.text = "'Ir al parque temático' is..."
                Answer1.setTitle("to go to the park", for: UIControlState.normal)
                Answer2.setTitle("to go to the playground", for: UIControlState.normal)
                Answer3.setTitle("to go on holidays", for: UIControlState.normal)
                Answer4.setTitle("to go to the theme park", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 72:
                Question.text = "‘Ir de paseo' is..."
                Answer1.setTitle("to go for a walk", for: UIControlState.normal)
                Answer2.setTitle("to go to the park", for: UIControlState.normal)
                Answer3.setTitle("to go to the cinema", for: UIControlState.normal)
                Answer4.setTitle("to go shopping", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 73:
                Question.text = "'Ir de excursión' is..."
                Answer1.setTitle("to go for a walk", for: UIControlState.normal)
                Answer2.setTitle("to go on a trip", for: UIControlState.normal)
                Answer3.setTitle("to go to the park", for: UIControlState.normal)
                Answer4.setTitle("to go to the cinema", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 74:
                Question.text = "'Ir a cine' is..."
                Answer1.setTitle("to go to the bowling alley", for: UIControlState.normal)
                Answer2.setTitle("to go to the park", for: UIControlState.normal)
                Answer3.setTitle("to go to the cinema", for: UIControlState.normal)
                Answer4.setTitle("to watch a film", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
                
            case 75:
                Question.text = "'La película' is..."
                Answer1.setTitle("a DVD", for: UIControlState.normal)
                Answer2.setTitle("popcorn", for: UIControlState.normal)
                Answer3.setTitle("a cinema", for: UIControlState.normal)
                Answer4.setTitle("a film", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 76:
                Question.text = "'La comedia' is..."
                Answer1.setTitle("a comedy film", for: UIControlState.normal)
                Answer2.setTitle("an adventure film", for: UIControlState.normal)
                Answer3.setTitle("a children’s film", for: UIControlState.normal)
                Answer4.setTitle("a thriller film", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 77:
                Question.text = "'La película de suspense' is..."
                Answer1.setTitle("a horror film", for: UIControlState.normal)
                Answer2.setTitle("a thriller film", for: UIControlState.normal)
                Answer3.setTitle("a comedy film", for: UIControlState.normal)
                Answer4.setTitle("an adventure film", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 78:
                Question.text = "'La película de aventuras' is..."
                Answer1.setTitle("a science-fiction film", for: UIControlState.normal)
                Answer2.setTitle("an animated film", for: UIControlState.normal)
                Answer3.setTitle("an adventure film", for: UIControlState.normal)
                Answer4.setTitle("a comedy film", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 79:
                Question.text = "'La película de terror' is..."
                Answer1.setTitle("a thriller film", for: UIControlState.normal)
                Answer2.setTitle("a romance film", for: UIControlState.normal)
                Answer3.setTitle("a science-fiction film", for: UIControlState.normal)
                Answer4.setTitle("a horror film", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 80:
                Question.text = "'La película del oeste' is..."
                Answer1.setTitle("a western film", for: UIControlState.normal)
                Answer2.setTitle("an animated film", for: UIControlState.normal)
                Answer3.setTitle("a science-fiction film", for: UIControlState.normal)
                Answer4.setTitle("a romance film", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
                
            case 81:
                Question.text = "'La película de ciencia ficción' is..."
                Answer1.setTitle("an animated film", for: UIControlState.normal)
                Answer2.setTitle("a science-fiction film", for: UIControlState.normal)
                Answer3.setTitle("a western film", for: UIControlState.normal)
                Answer4.setTitle("a comedy film", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 82:
                Question.text = "'La película de dibujos animados' is..."
                Answer1.setTitle("a comedy film", for: UIControlState.normal)
                Answer2.setTitle("an art film", for: UIControlState.normal)
                Answer3.setTitle("an animated film", for: UIControlState.normal)
                Answer4.setTitle("a science-fiction film", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 83:
                Question.text = "'El ordenador' is..."
                Answer1.setTitle("a laptop", for: UIControlState.normal)
                Answer2.setTitle("a mouse", for: UIControlState.normal)
                Answer3.setTitle("a screen", for: UIControlState.normal)
                Answer4.setTitle("a computer", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 84:
                Question.text = "'El ordenador portatíl' is..."
                Answer1.setTitle("a laptop", for: UIControlState.normal)
                Answer2.setTitle("a desktop PC", for: UIControlState.normal)
                Answer3.setTitle("a screen", for: UIControlState.normal)
                Answer4.setTitle("a USB flash drive", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 85:
                Question.text = "'La pantalla' is..."
                Answer1.setTitle("a keyboard", for: UIControlState.normal)
                Answer2.setTitle("a screen", for: UIControlState.normal)
                Answer3.setTitle("a mouse", for: UIControlState.normal)
                Answer4.setTitle("a desktop PC", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 86:
                Question.text = "'El raton' is..."
                Answer1.setTitle("a rating", for: UIControlState.normal)
                Answer2.setTitle("a rat", for: UIControlState.normal)
                Answer3.setTitle("a mouse", for: UIControlState.normal)
                Answer4.setTitle("a keyboard", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
                
            case 87:
                Question.text = "'Descargar' is..."
                Answer1.setTitle("to undo", for: UIControlState.normal)
                Answer2.setTitle("to enjoy", for: UIControlState.normal)
                Answer3.setTitle("to upload", for: UIControlState.normal)
                Answer4.setTitle("to download", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 88:
                Question.text = "'Correo electrónica' is..."
                Answer1.setTitle("email", for: UIControlState.normal)
                Answer2.setTitle("post", for: UIControlState.normal)
                Answer3.setTitle("electricity", for: UIControlState.normal)
                Answer4.setTitle("a computer", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 89:
                Question.text = "'El sitio web' is..."
                Answer1.setTitle("an email", for: UIControlState.normal)
                Answer2.setTitle("a website", for: UIControlState.normal)
                Answer3.setTitle("a webpage", for: UIControlState.normal)
                Answer4.setTitle("an internet browser", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 90:
                Question.text = "'En línea' is..."
                Answer1.setTitle("an email", for: UIControlState.normal)
                Answer2.setTitle("a website", for: UIControlState.normal)
                Answer3.setTitle("online", for: UIControlState.normal)
                Answer4.setTitle("offline", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 91:
                Question.text = "'Buscar' is..."
                Answer1.setTitle("to navigate", for: UIControlState.normal)
                Answer2.setTitle("to busk", for: UIControlState.normal)
                Answer3.setTitle("to drink", for: UIControlState.normal)
                Answer4.setTitle("to search", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 92:
                Question.text = "'Navegar' is..."
                Answer1.setTitle("to navigate", for: UIControlState.normal)
                Answer2.setTitle("to search", for: UIControlState.normal)
                Answer3.setTitle("to row", for: UIControlState.normal)
                Answer4.setTitle("to swim", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 93:
                Question.text = "'El ciclismo' is..."
                Answer1.setTitle("cycling", for: UIControlState.normal)
                Answer2.setTitle("gymnastics", for: UIControlState.normal)
                Answer3.setTitle("rowing", for: UIControlState.normal)
                Answer4.setTitle("jogging", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 94:
                Question.text = "'La película romántica' is..."
                Answer1.setTitle("a romance film", for: UIControlState.normal)
                Answer2.setTitle("an animated film", for: UIControlState.normal)
                Answer3.setTitle("a science-fiction film", for: UIControlState.normal)
                Answer4.setTitle("a western film", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            default:
                break
            }
        } else if quizTypeToBegin == "School" {
            RandomNumber = arc4random() % 55
            RandomNumber += 1
            print("\(RandomNumber)")
            
            switch (RandomNumber) {
            case 1:
                Question.text = "'La escuela' is a..."
                Answer1.setTitle("school", for: UIControlState.normal)
                Answer2.setTitle("university", for: UIControlState.normal)
                Answer3.setTitle("college", for: UIControlState.normal)
                Answer4.setTitle("nursery", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 2:
                Question.text = "'La pizarra' is a..."
                Answer1.setTitle("whiteboard", for: UIControlState.normal)
                Answer2.setTitle("blackboard", for: UIControlState.normal)
                Answer3.setTitle("display board", for: UIControlState.normal)
                Answer4.setTitle("drawing board", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 3:
                Question.text = "'La mesa' is a..."
                Answer1.setTitle("chair", for: UIControlState.normal)
                Answer2.setTitle("wall", for: UIControlState.normal)
                Answer3.setTitle("desk", for: UIControlState.normal)
                Answer4.setTitle("cupboard", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 4:
                Question.text = "'La silla' is a..."
                Answer1.setTitle("door", for: UIControlState.normal)
                Answer2.setTitle("table", for: UIControlState.normal)
                Answer3.setTitle("desk", for: UIControlState.normal)
                Answer4.setTitle("chair", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 5:
                Question.text = "'El ordenador' is a..."
                Answer1.setTitle("computer", for: UIControlState.normal)
                Answer2.setTitle("monitor", for: UIControlState.normal)
                Answer3.setTitle("desk", for: UIControlState.normal)
                Answer4.setTitle("laptop", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 6:
                Question.text = "'El proyector' is a..."
                Answer1.setTitle("television", for: UIControlState.normal)
                Answer2.setTitle("projector", for: UIControlState.normal)
                Answer3.setTitle("map", for: UIControlState.normal)
                Answer4.setTitle("lightbulb", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
                
            case 7:
                Question.text = "'El director' is a..."
                Answer1.setTitle("director", for: UIControlState.normal)
                Answer2.setTitle("dictator", for: UIControlState.normal)
                Answer3.setTitle("principal", for: UIControlState.normal)
                Answer4.setTitle("teacher", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 8:
                Question.text = "'El estudiante' is a..."
                Answer1.setTitle("teacher", for: UIControlState.normal)
                Answer2.setTitle("study", for: UIControlState.normal)
                Answer3.setTitle("pencil", for: UIControlState.normal)
                Answer4.setTitle("student", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 9:
                Question.text = "'La bolsa' is a..."
                Answer1.setTitle("bag", for: UIControlState.normal)
                Answer2.setTitle("box", for: UIControlState.normal)
                Answer3.setTitle("pencil case", for: UIControlState.normal)
                Answer4.setTitle("bottle", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 10:
                Question.text = "'El libro' is a..."
                Answer1.setTitle("library", for: UIControlState.normal)
                Answer2.setTitle("book", for: UIControlState.normal)
                Answer3.setTitle("copy", for: UIControlState.normal)
                Answer4.setTitle("journal", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 11:
                Question.text = "'El cuaderno' is a..."
                Answer1.setTitle("textbook", for: UIControlState.normal)
                Answer2.setTitle("journal", for: UIControlState.normal)
                Answer3.setTitle("copy", for: UIControlState.normal)
                Answer4.setTitle("pencil case", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 12:
                Question.text = "'El estuche' is a..."
                Answer1.setTitle("calculator", for: UIControlState.normal)
                Answer2.setTitle("shelf", for: UIControlState.normal)
                Answer3.setTitle("bag", for: UIControlState.normal)
                Answer4.setTitle("pencil case", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
                
            case 13:
                Question.text = "'La calculadora' is a..."
                Answer1.setTitle("calculator", for: UIControlState.normal)
                Answer2.setTitle("pencil case", for: UIControlState.normal)
                Answer3.setTitle("compass", for: UIControlState.normal)
                Answer4.setTitle("computer", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 14:
                Question.text = "'Los apuntes' are..."
                Answer1.setTitle("pencil sharpeners", for: UIControlState.normal)
                Answer2.setTitle("notes", for: UIControlState.normal)
                Answer3.setTitle("books", for: UIControlState.normal)
                Answer4.setTitle("copies", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 15:
                Question.text = "'La agenda' is a..."
                Answer1.setTitle("folder", for: UIControlState.normal)
                Answer2.setTitle("copy", for: UIControlState.normal)
                Answer3.setTitle("journal", for: UIControlState.normal)
                Answer4.setTitle("textbook", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 16:
                Question.text = "'Los idiomas' are..."
                Answer1.setTitle("studies", for: UIControlState.normal)
                Answer2.setTitle("journals", for: UIControlState.normal)
                Answer3.setTitle("maths", for: UIControlState.normal)
                Answer4.setTitle("languages", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 17:
                Question.text = "'El inglés' is..."
                Answer1.setTitle("English", for: UIControlState.normal)
                Answer2.setTitle("Welsh", for: UIControlState.normal)
                Answer3.setTitle("Scottish", for: UIControlState.normal)
                Answer4.setTitle("German", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 19:
                Question.text = "'El irlandés' is..."
                Answer1.setTitle("Ireland", for: UIControlState.normal)
                Answer2.setTitle("Irish", for: UIControlState.normal)
                Answer3.setTitle("Scottish", for: UIControlState.normal)
                Answer4.setTitle("Welsh", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
                
            case 20:
                Question.text = "'El francés' is..."
                Answer1.setTitle("Japanese", for: UIControlState.normal)
                Answer2.setTitle("German", for: UIControlState.normal)
                Answer3.setTitle("French", for: UIControlState.normal)
                Answer4.setTitle("Irish", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 21:
                Question.text = "'El alemán' is..."
                Answer1.setTitle("Aracbic", for: UIControlState.normal)
                Answer2.setTitle("Albanian", for: UIControlState.normal)
                Answer3.setTitle("Austrian", for: UIControlState.normal)
                Answer4.setTitle("German", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 22:
                Question.text = "'El italiano' is..."
                Answer1.setTitle("Italian", for: UIControlState.normal)
                Answer2.setTitle("French", for: UIControlState.normal)
                Answer3.setTitle("Chinese", for: UIControlState.normal)
                Answer4.setTitle("Irish", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 23:
                Question.text = "'El latín' is..."
                Answer1.setTitle("language", for: UIControlState.normal)
                Answer2.setTitle("Latin", for: UIControlState.normal)
                Answer3.setTitle("Luxembourg", for: UIControlState.normal)
                Answer4.setTitle("music", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 24:
                Question.text = "'El griego' is..."
                Answer1.setTitle("Gaelic", for: UIControlState.normal)
                Answer2.setTitle("German", for: UIControlState.normal)
                Answer3.setTitle("Greek", for: UIControlState.normal)
                Answer4.setTitle("Welsh", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 25:
                Question.text = "'El portugués' is..."
                Answer1.setTitle("Polish", for: UIControlState.normal)
                Answer2.setTitle("Spanish", for: UIControlState.normal)
                Answer3.setTitle("Puerto Rico", for: UIControlState.normal)
                Answer4.setTitle("Portuguese", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
                
            case 26:
                Question.text = "'El ruso' is..."
                Answer1.setTitle("Russian", for: UIControlState.normal)
                Answer2.setTitle("roads", for: UIControlState.normal)
                Answer3.setTitle("rushes", for: UIControlState.normal)
                Answer4.setTitle("rap music", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 27:
                Question.text = "'La informática' is..."
                Answer1.setTitle("information", for: UIControlState.normal)
                Answer2.setTitle("computers", for: UIControlState.normal)
                Answer3.setTitle("home economics", for: UIControlState.normal)
                Answer4.setTitle("business studies", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 28:
                Question.text = "‘La geografía' is..."
                Answer1.setTitle("physics", for: UIControlState.normal)
                Answer2.setTitle("history", for: UIControlState.normal)
                Answer3.setTitle("geography", for: UIControlState.normal)
                Answer4.setTitle("science", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 29:
                Question.text = "‘La ciencia' is..."
                Answer1.setTitle("chemistry", for: UIControlState.normal)
                Answer2.setTitle("physics", for: UIControlState.normal)
                Answer3.setTitle("biology", for: UIControlState.normal)
                Answer4.setTitle("science", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 30:
                Question.text = "'La qúimica' is..."
                Answer1.setTitle("chemistry", for: UIControlState.normal)
                Answer2.setTitle("physics", for: UIControlState.normal)
                Answer3.setTitle("biology", for: UIControlState.normal)
                Answer4.setTitle("exams", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 31:
                Question.text = "'La física' is..."
                Answer1.setTitle("P.E.", for: UIControlState.normal)
                Answer2.setTitle("physics", for: UIControlState.normal)
                Answer3.setTitle("geography", for: UIControlState.normal)
                Answer4.setTitle("mountaineering", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 32:
                Question.text = "'El comercio' is..."
                Answer1.setTitle("chemistry", for: UIControlState.normal)
                Answer2.setTitle("accounting", for: UIControlState.normal)
                Answer3.setTitle("business studies", for: UIControlState.normal)
                Answer4.setTitle("home economics", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 33:
                Question.text = "'El bolígrafo' is a(n)..."
                Answer1.setTitle("eraser", for: UIControlState.normal)
                Answer2.setTitle("sharpener", for: UIControlState.normal)
                Answer3.setTitle("pencil", for: UIControlState.normal)
                Answer4.setTitle("pen", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 34:
                Question.text = "'El rotulador' is a..."
                Answer1.setTitle("marker", for: UIControlState.normal)
                Answer2.setTitle("pen", for: UIControlState.normal)
                Answer3.setTitle("compass", for: UIControlState.normal)
                Answer4.setTitle("globe", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 35:
                Question.text = "'El lápiz' is a(n)..."
                Answer1.setTitle("pen", for: UIControlState.normal)
                Answer2.setTitle("pencil", for: UIControlState.normal)
                Answer3.setTitle("eraser", for: UIControlState.normal)
                Answer4.setTitle("sharpener", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 36:
                Question.text = "'La goma' is a(n)..."
                Answer1.setTitle("gummy bear", for: UIControlState.normal)
                Answer2.setTitle("sharpener", for: UIControlState.normal)
                Answer3.setTitle("eraser", for: UIControlState.normal)
                Answer4.setTitle("compass", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 37:
                Question.text = "'El sacapuntas' is a(n)..."
                Answer1.setTitle("pencil case", for: UIControlState.normal)
                Answer2.setTitle("school bag", for: UIControlState.normal)
                Answer3.setTitle("eraser", for: UIControlState.normal)
                Answer4.setTitle("sharpener", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 38:
                Question.text = "'La regla' is a..."
                Answer1.setTitle("ruler", for: UIControlState.normal)
                Answer2.setTitle("compass", for: UIControlState.normal)
                Answer3.setTitle("protractor", for: UIControlState.normal)
                Answer4.setTitle("set square", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 39:
                Question.text = "'El aula' is a(n)..."
                Answer1.setTitle("intercom", for: UIControlState.normal)
                Answer2.setTitle("classroom", for: UIControlState.normal)
                Answer3.setTitle("student", for: UIControlState.normal)
                Answer4.setTitle("announcement", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 40:
                Question.text = "'El comedor' is a..."
                Answer1.setTitle("meeting room", for: UIControlState.normal)
                Answer2.setTitle("classroom", for: UIControlState.normal)
                Answer3.setTitle("canteen", for: UIControlState.normal)
                Answer4.setTitle("staff room", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 41:
                Question.text = "'El pasillo' is a..."
                Answer1.setTitle("desk", for: UIControlState.normal)
                Answer2.setTitle("bench", for: UIControlState.normal)
                Answer3.setTitle("bridge", for: UIControlState.normal)
                Answer4.setTitle("corridor", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 42:
                Question.text = "'El patio' is a..."
                Answer1.setTitle("yard", for: UIControlState.normal)
                Answer2.setTitle("patio", for: UIControlState.normal)
                Answer3.setTitle("square", for: UIControlState.normal)
                Answer4.setTitle("football pitch", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 43:
                Question.text = "'El laboratorio' is a..."
                Answer1.setTitle("library", for: UIControlState.normal)
                Answer2.setTitle("laboratory", for: UIControlState.normal)
                Answer3.setTitle("classroom", for: UIControlState.normal)
                Answer4.setTitle("gym", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 44:
                Question.text = "'El taller de arte' is a(n)..."
                Answer1.setTitle("computer room", for: UIControlState.normal)
                Answer2.setTitle("woodwork room", for: UIControlState.normal)
                Answer3.setTitle("art room", for: UIControlState.normal)
                Answer4.setTitle("drawing room", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 45:
                Question.text = "'El gimnasio' is a..."
                Answer1.setTitle("science lab", for: UIControlState.normal)
                Answer2.setTitle("woodwork room", for: UIControlState.normal)
                Answer3.setTitle("group", for: UIControlState.normal)
                Answer4.setTitle("gym", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 46:
                Question.text = "'Los vestuarios' are..."
                Answer1.setTitle("changing rooms", for: UIControlState.normal)
                Answer2.setTitle("lockers", for: UIControlState.normal)
                Answer3.setTitle("vests", for: UIControlState.normal)
                Answer4.setTitle("t-shirts", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 47:
                Question.text = "'La economía' is..."
                Answer1.setTitle("business studies", for: UIControlState.normal)
                Answer2.setTitle("economics", for: UIControlState.normal)
                Answer3.setTitle("home economics", for: UIControlState.normal)
                Answer4.setTitle("accountancy", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 48:
                Question.text = "'La contabilidad' is..."
                Answer1.setTitle("technology", for: UIControlState.normal)
                Answer2.setTitle("biology", for: UIControlState.normal)
                Answer3.setTitle("acccountancy", for: UIControlState.normal)
                Answer4.setTitle("social studies", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 49:
                Question.text = "'El dibujo' is..."
                Answer1.setTitle("history", for: UIControlState.normal)
                Answer2.setTitle("biology", for: UIControlState.normal)
                Answer3.setTitle("technical graphics", for: UIControlState.normal)
                Answer4.setTitle("art", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 50:
                Question.text = "'La religión' is..."
                Answer1.setTitle("religion", for: UIControlState.normal)
                Answer2.setTitle("social studies", for: UIControlState.normal)
                Answer3.setTitle("woodwork", for: UIControlState.normal)
                Answer4.setTitle("biology", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 51:
                Question.text = "'La música' is..."
                Answer1.setTitle("physics", for: UIControlState.normal)
                Answer2.setTitle("music", for: UIControlState.normal)
                Answer3.setTitle("P.E.", for: UIControlState.normal)
                Answer4.setTitle("classical studies", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            case 52:
                Question.text = "'La oficina' is a(n)..."
                Answer1.setTitle("meeting room", for: UIControlState.normal)
                Answer2.setTitle("classroom", for: UIControlState.normal)
                Answer3.setTitle("office", for: UIControlState.normal)
                Answer4.setTitle("staff room", for: UIControlState.normal)
                CorrectAnswer = "3"
                break
            case 53:
                Question.text = "'La sala de profesores' is..."
                Answer1.setTitle("yard", for: UIControlState.normal)
                Answer2.setTitle("the classroom", for: UIControlState.normal)
                Answer3.setTitle("the principal's office", for: UIControlState.normal)
                Answer4.setTitle("the staff room", for: UIControlState.normal)
                CorrectAnswer = "4"
                break
            case 54:
                Question.text = "'La recepción' is..."
                Answer1.setTitle("the reception", for: UIControlState.normal)
                Answer2.setTitle("the intercom", for: UIControlState.normal)
                Answer3.setTitle("assembly", for: UIControlState.normal)
                Answer4.setTitle("a play", for: UIControlState.normal)
                CorrectAnswer = "1"
                break
            case 55:
                Question.text = "'La capilla' is a(n)..."
                Answer1.setTitle("laboartory", for: UIControlState.normal)
                Answer2.setTitle("oratory", for: UIControlState.normal)
                Answer3.setTitle("music room", for: UIControlState.normal)
                Answer4.setTitle("storage room", for: UIControlState.normal)
                CorrectAnswer = "2"
                break
            default:
                break
            }
        } else if quizTypeToBegin == "Verbs" {
            RandomNumber = arc4random() % 202
            RandomNumber += 1
            print("\(RandomNumber)")
            
            switch (RandomNumber) {
            case 1:
                Question.text = "Which verb means 'to accept'?"
                Answer1.setTitle("aceptar", for: UIControlState())
                Answer2.setTitle("acercar", for: UIControlState())
                Answer3.setTitle("acertar", for: UIControlState())
                Answer4.setTitle("acordar", for: UIControlState())
                CorrectAnswer = "1"
                break
                
            case 2:
                Question.text = "Which verb means 'to ask'?"
                Answer1.setTitle("predicir", for: UIControlState())
                Answer2.setTitle("preguntar", for: UIControlState())
                Answer3.setTitle("prestar", for: UIControlState())
                Answer4.setTitle("poner", for: UIControlState())
                CorrectAnswer = "2"
                break
                
            case 3:
                Question.text = "Which verb means 'to believe'?"
                Answer1.setTitle("crecer", for: UIControlState())
                Answer2.setTitle("cuidarse", for: UIControlState())
                Answer3.setTitle("creer", for: UIControlState())
                Answer4.setTitle("criar", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 4:
                Question.text = "Which verb means 'to grow'?"
                Answer1.setTitle("creer", for: UIControlState())
                Answer2.setTitle("criar", for: UIControlState())
                Answer3.setTitle("correr", for: UIControlState())
                Answer4.setTitle("crecer", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 5:
                Question.text = "Which verb means 'to borrow'?"
                Answer1.setTitle("prestar", for: UIControlState())
                Answer2.setTitle("permitir", for: UIControlState())
                Answer3.setTitle("pararse", for: UIControlState())
                Answer4.setTitle("poseer", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 6:
                Question.text = "Which verb means 'to break'?"
                Answer1.setTitle("recoger", for: UIControlState())
                Answer2.setTitle("romper", for: UIControlState())
                Answer3.setTitle("renegar", for: UIControlState())
                Answer4.setTitle("reñir", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 7:
                Question.text = "Which verb means 'to bring'?"
                Answer1.setTitle("trenzar", for: UIControlState())
                Answer2.setTitle("trizar", for: UIControlState())
                Answer3.setTitle("traer", for: UIControlState())
                Answer4.setTitle("trillar", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 8:
                Question.text = "Which verb means 'to buy'?"
                Answer1.setTitle("coger", for: UIControlState())
                Answer2.setTitle("colonizar", for: UIControlState())
                Answer3.setTitle("componer", for: UIControlState())
                Answer4.setTitle("comprar", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 9:
                Question.text = "Which verb means 'to cancel'?"
                Answer1.setTitle("cancelar", for: UIControlState())
                Answer2.setTitle("cansarse", for: UIControlState())
                Answer3.setTitle("cerrar", for: UIControlState())
                Answer4.setTitle("censurar", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 10:
                Question.text = "Which verb means 'to close'?"
                Answer1.setTitle("censurar", for: UIControlState())
                Answer2.setTitle("cerrar", for: UIControlState())
                Answer3.setTitle("conducir", for: UIControlState())
                Answer4.setTitle("cuidar", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 11:
                Question.text = "Which verb means 'to change'?"
                Answer1.setTitle("chocar", for: UIControlState())
                Answer2.setTitle("cobrar", for: UIControlState())
                Answer3.setTitle("cambiar", for: UIControlState())
                Answer4.setTitle("cepillar", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 12:
                Question.text = "Which verb means 'to develop'?"
                Answer1.setTitle("derivar", for: UIControlState())
                Answer2.setTitle("descolgar", for: UIControlState())
                Answer3.setTitle("devolver", for: UIControlState())
                Answer4.setTitle("desarrollar", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 13:
                Question.text = "Which verb means 'to clean'?"
                Answer1.setTitle("limpiar", for: UIControlState())
                Answer2.setTitle("llamar", for: UIControlState())
                Answer3.setTitle("llenar", for: UIControlState())
                Answer4.setTitle("laburar", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 14:
                Question.text = "Which verb means 'to work'?"
                Answer1.setTitle("luchar", for: UIControlState())
                Answer2.setTitle("trabajar", for: UIControlState())
                Answer3.setTitle("labrar", for: UIControlState())
                Answer4.setTitle("lamer", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 15:
                Question.text = "Which verb means 'to complain'?"
                Answer1.setTitle("quebrar", for: UIControlState())
                Answer2.setTitle("quedar", for: UIControlState())
                Answer3.setTitle("quejarse", for: UIControlState())
                Answer4.setTitle("quitar", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 16:
                Question.text = "Which verb means 'to cut'?"
                Answer1.setTitle("contar", for: UIControlState())
                Answer2.setTitle("coser", for: UIControlState())
                Answer3.setTitle("cultivar", for: UIControlState())
                Answer4.setTitle("cortar", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 17:
                Question.text = "Which verb means 'to cough'?"
                Answer1.setTitle("toser", for: UIControlState())
                Answer2.setTitle("tallar", for: UIControlState())
                Answer3.setTitle("talar", for: UIControlState())
                Answer4.setTitle("tolerar", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 18:
                Question.text = "Which verb means 'to dance'?"
                Answer1.setTitle("bajar", for: UIControlState())
                Answer2.setTitle("bailar", for: UIControlState())
                Answer3.setTitle("bendecir", for: UIControlState())
                Answer4.setTitle("bambolear", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 19:
                Question.text = "Which verb means 'to count'?"
                Answer1.setTitle("conjugar", for: UIControlState())
                Answer2.setTitle("contener", for: UIControlState())
                Answer3.setTitle("contar", for: UIControlState())
                Answer4.setTitle("cortar", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 20:
                Question.text = "Which verb means 'to drink'?"
                Answer1.setTitle("barrer", for: UIControlState())
                Answer2.setTitle("balsear", for: UIControlState())
                Answer3.setTitle("bailar", for: UIControlState())
                Answer4.setTitle("beber", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 21:
                Question.text = "Which verb means 'to draw'?"
                Answer1.setTitle("dibujar", for: UIControlState())
                Answer2.setTitle("deber", for: UIControlState())
                Answer3.setTitle("damasquinar", for: UIControlState())
                Answer4.setTitle("doler", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 22:
                Question.text = "Which verb means 'to drive'?"
                Answer1.setTitle("caminar", for: UIControlState())
                Answer2.setTitle("conducir", for: UIControlState())
                Answer3.setTitle("charlar", for: UIControlState())
                Answer4.setTitle("correr", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 23:
                Question.text = "Which verb means 'to eat'?"
                Answer1.setTitle("carnear", for: UIControlState())
                Answer2.setTitle("calar", for: UIControlState())
                Answer3.setTitle("comer", for: UIControlState())
                Answer4.setTitle("catar", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 24:
                Question.text = "Which verb means 'to explain'?"
                Answer1.setTitle("extraer", for: UIControlState())
                Answer2.setTitle("exceptuar", for: UIControlState())
                Answer3.setTitle("excluir", for: UIControlState())
                Answer4.setTitle("explicar", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 25:
                Question.text = "Which verb means 'to fall'?"
                Answer1.setTitle("caer", for: UIControlState())
                Answer2.setTitle("confiar", for: UIControlState())
                Answer3.setTitle("cazar", for: UIControlState())
                Answer4.setTitle("fallar", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 26:
                Question.text = "Which verb means 'to fill'?"
                Answer1.setTitle("llegar", for: UIControlState())
                Answer2.setTitle("llenar", for: UIControlState())
                Answer3.setTitle("llevar", for: UIControlState())
                Answer4.setTitle("lograr", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 27:
                Question.text = "Which verb means 'to find'?"
                Answer1.setTitle("entender", for: UIControlState())
                Answer2.setTitle("fiar", for: UIControlState())
                Answer3.setTitle("encontrar", for: UIControlState())
                Answer4.setTitle("foliar", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 28:
                Question.text = "Which verb means 'to finish'?"
                Answer1.setTitle("fregar", for: UIControlState())
                Answer2.setTitle("forjar", for: UIControlState())
                Answer3.setTitle("tracionar", for: UIControlState())
                Answer4.setTitle("terminar", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 29:
                Question.text = "Which verb means 'to fit'?"
                Answer1.setTitle("caber", for: UIControlState())
                Answer2.setTitle("cobrar", for: UIControlState())
                Answer3.setTitle("fiar", for: UIControlState())
                Answer4.setTitle("frotar", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 30:
                Question.text = "Which verb means 'to photograph'?"
                Answer1.setTitle("fruncir", for: UIControlState())
                Answer2.setTitle("fotografiar", for: UIControlState())
                Answer3.setTitle("frecuentar", for: UIControlState())
                Answer4.setTitle("fotografier", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 31:
                Question.text = "Which verb means 'to fix'?"
                Answer1.setTitle("romper", for: UIControlState())
                Answer2.setTitle("rehusar", for: UIControlState())
                Answer3.setTitle("reparar", for: UIControlState())
                Answer4.setTitle("recoger", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 32:
                Question.text = "Which verb means 'to fly'?"
                Answer1.setTitle("correr", for: UIControlState())
                Answer2.setTitle("fliar", for: UIControlState())
                Answer3.setTitle("viajar", for: UIControlState())
                Answer4.setTitle("volar", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 33:
                Question.text = "Which verb means 'to forget'?"
                Answer1.setTitle("olvidar", for: UIControlState())
                Answer2.setTitle("odiar", for: UIControlState())
                Answer3.setTitle("forgetar", for: UIControlState())
                Answer4.setTitle("ondular", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 34:
                Question.text = "Which verb means 'to learn'?"
                Answer1.setTitle("acordarse", for: UIControlState())
                Answer2.setTitle("aprender", for: UIControlState())
                Answer3.setTitle("aporrear", for: UIControlState())
                Answer4.setTitle("apresurar", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 35:
                Question.text = "Which verb means 'to give'?"
                Answer1.setTitle("deber", for: UIControlState())
                Answer2.setTitle("desear", for: UIControlState())
                Answer3.setTitle("dar", for: UIControlState())
                Answer4.setTitle("dorar", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 36:
                Question.text = "Which verb means 'to listen'?"
                Answer1.setTitle("ejercer", for: UIControlState())
                Answer2.setTitle("ensuciar", for: UIControlState())
                Answer3.setTitle("escoger", for: UIControlState())
                Answer4.setTitle("escuchar", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 37:
                Question.text = "Which verb means 'to live'?"
                Answer1.setTitle("vivir", for: UIControlState())
                Answer2.setTitle("volar", for: UIControlState())
                Answer3.setTitle("vacar", for: UIControlState())
                Answer4.setTitle("virar", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 38:
                Question.text = "Which verb means 'to need'?"
                Answer1.setTitle("nacer", for: UIControlState())
                Answer2.setTitle("necesitar", for: UIControlState())
                Answer3.setTitle("nevar", for: UIControlState())
                Answer4.setTitle("nublar", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 39:
                Question.text = "Which verb means 'to look'?"
                Answer1.setTitle("mostrat", for: UIControlState())
                Answer2.setTitle("ver", for: UIControlState())
                Answer3.setTitle("mirar", for: UIControlState())
                Answer4.setTitle("marcar", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 40:
                Question.text = "Which verb means 'to lose'?"
                Answer1.setTitle("palmar", for: UIControlState())
                Answer2.setTitle("patinar", for: UIControlState())
                Answer3.setTitle("paracer", for: UIControlState())
                Answer4.setTitle("perder", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 41:
                Question.text = "Which verb means 'to open'?"
                Answer1.setTitle("abrir", for: UIControlState())
                Answer2.setTitle("abortar", for: UIControlState())
                Answer3.setTitle("abordar", for: UIControlState())
                Answer4.setTitle("acortar", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 42:
                Question.text = "Which verb means 'to close'?"
                Answer1.setTitle("cesar", for: UIControlState())
                Answer2.setTitle("cerrar", for: UIControlState())
                Answer3.setTitle("cargar", for: UIControlState())
                Answer4.setTitle("crear", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 43:
                Question.text = "Which verb means 'to pay'?"
                Answer1.setTitle("cuestar", for: UIControlState())
                Answer2.setTitle("pegar", for: UIControlState())
                Answer3.setTitle("pagar", for: UIControlState())
                Answer4.setTitle("payasear", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 44:
                Question.text = "Which verb means 'to play'?"
                Answer1.setTitle("plagar", for: UIControlState())
                Answer2.setTitle("juzgar", for: UIControlState())
                Answer3.setTitle("jubliar", for: UIControlState())
                Answer4.setTitle("jugar", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 45:
                Question.text = "Which verb means 'to put'?"
                Answer1.setTitle("poner", for: UIControlState())
                Answer2.setTitle("pisar", for: UIControlState())
                Answer3.setTitle("podar", for: UIControlState())
                Answer4.setTitle("pulgar", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 46:
                Question.text = "Which verb means 'to rain'?"
                Answer1.setTitle("llorar", for: UIControlState())
                Answer2.setTitle("llover", for: UIControlState())
                Answer3.setTitle("llevar", for: UIControlState())
                Answer4.setTitle("lacear", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 47:
                Question.text = "Which verb means 'to read'?"
                Answer1.setTitle("laurear", for: UIControlState())
                Answer2.setTitle("lucir", for: UIControlState())
                Answer3.setTitle("leer", for: UIControlState())
                Answer4.setTitle("llamar", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 48:
                Question.text = "Which verb means 'to reply'?"
                Answer1.setTitle("recoger", for: UIControlState())
                Answer2.setTitle("regar", for: UIControlState())
                Answer3.setTitle("respetar", for: UIControlState())
                Answer4.setTitle("responder", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 49:
                Question.text = "Which verb means 'to run'?"
                Answer1.setTitle("correr", for: UIControlState())
                Answer2.setTitle("corregir", for: UIControlState())
                Answer3.setTitle("caminar", for: UIControlState())
                Answer4.setTitle("curar", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 50:
                Question.text = "Which verb means 'to say'?"
                Answer1.setTitle("declarar", for: UIControlState())
                Answer2.setTitle("decir", for: UIControlState())
                Answer3.setTitle("dejar", for: UIControlState())
                Answer4.setTitle("devorar", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 51:
                Question.text = "Which verb means 'to see'?"
                Answer1.setTitle("valer", for: UIControlState())
                Answer2.setTitle("venerar", for: UIControlState())
                Answer3.setTitle("ver", for: UIControlState())
                Answer4.setTitle("ventilar", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 52:
                Question.text = "Which verb means 'to sell'?"
                Answer1.setTitle("vallar", for: UIControlState())
                Answer2.setTitle("vomitar", for: UIControlState())
                Answer3.setTitle("vengar", for: UIControlState())
                Answer4.setTitle("vender", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 53:
                Question.text = "Which verb means 'to send'?"
                Answer1.setTitle("enviar", for: UIControlState())
                Answer2.setTitle("echar", for: UIControlState())
                Answer3.setTitle("encender", for: UIControlState())
                Answer4.setTitle("entregar", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 54:
                Question.text = "Which verb means 'to sign'?"
                Answer1.setTitle("florecer", for: UIControlState())
                Answer2.setTitle("firmar", for: UIControlState())
                Answer3.setTitle("fallar", for: UIControlState())
                Answer4.setTitle("fluir", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 55:
                Question.text = "Which verb means 'to sing'?"
                Answer1.setTitle("bailar", for: UIControlState())
                Answer2.setTitle("decir", for: UIControlState())
                Answer3.setTitle("cantar", for: UIControlState())
                Answer4.setTitle("castigar", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 56:
                Question.text = "Which verb means 'to sit'?"
                Answer1.setTitle("levantarse", for: UIControlState())
                Answer2.setTitle("salir", for: UIControlState())
                Answer3.setTitle("situar", for: UIControlState())
                Answer4.setTitle("sentarse", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 57:
                Question.text = "Which verb means 'to sleep'?"
                Answer1.setTitle("dormir", for: UIControlState())
                Answer2.setTitle("acostarse", for: UIControlState())
                Answer3.setTitle("levantarse", for: UIControlState())
                Answer4.setTitle("derretir", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 58:
                Question.text = "Which verb means 'to smoke'?"
                Answer1.setTitle("fallar", for: UIControlState())
                Answer2.setTitle("fumar", for: UIControlState())
                Answer3.setTitle("fiar", for: UIControlState())
                Answer4.setTitle("foliar", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 59:
                Question.text = "Which verb means 'to speak'?"
                Answer1.setTitle("decir", for: UIControlState())
                Answer2.setTitle("cantar", for: UIControlState())
                Answer3.setTitle("hablar", for: UIControlState())
                Answer4.setTitle("hacer", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 60:
                Question.text = "Which verb means 'to spell'?"
                Answer1.setTitle("suponer", for: UIControlState())
                Answer2.setTitle("dobla", for: UIControlState())
                Answer3.setTitle("decapar", for: UIControlState())
                Answer4.setTitle("deletrear", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 61:
                Question.text = "Which verb means 'to spend money'?"
                Answer1.setTitle("gastar", for: UIControlState())
                Answer2.setTitle("pasar", for: UIControlState())
                Answer3.setTitle("ganar", for: UIControlState())
                Answer4.setTitle("pelear", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 62:
                Question.text = "Which verb means 'to commence'?"
                Answer1.setTitle("casar", for: UIControlState())
                Answer2.setTitle("comenzar", for: UIControlState())
                Answer3.setTitle("charlar", for: UIControlState())
                Answer4.setTitle("colocar", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 63:
                Question.text = "Which verb means 'to study'?"
                Answer1.setTitle("situar", for: UIControlState())
                Answer2.setTitle("secundar", for: UIControlState())
                Answer3.setTitle("estudiar", for: UIControlState())
                Answer4.setTitle("esquiar", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 64:
                Question.text = "Which verb means 'to swim'?"
                Answer1.setTitle("nacer", for: UIControlState())
                Answer2.setTitle("nublar", for: UIControlState())
                Answer3.setTitle("necear", for: UIControlState())
                Answer4.setTitle("nadar", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 65:
                Question.text = "Which verb means 'to take'?"
                Answer1.setTitle("tomar", for: UIControlState())
                Answer2.setTitle("salir", for: UIControlState())
                Answer3.setTitle("torcer", for: UIControlState())
                Answer4.setTitle("tachar", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 66:
                Question.text = "Which verb means 'to teach'?"
                Answer1.setTitle("traducir", for: UIControlState())
                Answer2.setTitle("enseñar", for: UIControlState())
                Answer3.setTitle("tabicar", for: UIControlState())
                Answer4.setTitle("enfadar", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 67:
                Question.text = "Which verb means 'to think'?"
                Answer1.setTitle("tachar", for: UIControlState())
                Answer2.setTitle("tajar", for: UIControlState())
                Answer3.setTitle("pensar", for: UIControlState())
                Answer4.setTitle("pedir", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 68:
                Question.text = "Which verb means 'to translate'?"
                Answer1.setTitle("tapar", for: UIControlState())
                Answer2.setTitle("tartamudear", for: UIControlState())
                Answer3.setTitle("transformar", for: UIControlState())
                Answer4.setTitle("traducir", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 69:
                Question.text = "Which verb means 'to travel'?"
                Answer1.setTitle("viajar", for: UIControlState())
                Answer2.setTitle("tramitar", for: UIControlState())
                Answer3.setTitle("traspasar", for: UIControlState())
                Answer4.setTitle("voler", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 70:
                Question.text = "Which verb means 'to try'?"
                Answer1.setTitle("trazar", for: UIControlState())
                Answer2.setTitle("intentar", for: UIControlState())
                Answer3.setTitle("inventar", for: UIControlState())
                Answer4.setTitle("trotar", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 71:
                Question.text = "Which verb means 'to turn off'?"
                Answer1.setTitle("encender", for: UIControlState())
                Answer2.setTitle("acabar", for: UIControlState())
                Answer3.setTitle("apagar", for: UIControlState())
                Answer4.setTitle("abrir", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 72:
                Question.text = "Which verb means 'to turn on'?"
                Answer1.setTitle("cerrar", for: UIControlState())
                Answer2.setTitle("apagar", for: UIControlState())
                Answer3.setTitle("acabar", for: UIControlState())
                Answer4.setTitle("encender", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 73:
                Question.text = "Which verb means 'to understand'?"
                Answer1.setTitle("entender", for: UIControlState())
                Answer2.setTitle("untar", for: UIControlState())
                Answer3.setTitle("entregar", for: UIControlState())
                Answer4.setTitle("ursupar", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 74:
                Question.text = "Which verb means 'to use'?"
                Answer1.setTitle("uncir", for: UIControlState())
                Answer2.setTitle("untar", for: UIControlState())
                Answer3.setTitle("ultrjar", for: UIControlState())
                Answer4.setTitle("ultilzar", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 75:
                Question.text = "Which verb means 'to wait'?"
                Answer1.setTitle("enfadar", for: UIControlState())
                Answer2.setTitle("enojar", for: UIControlState())
                Answer3.setTitle("esperar", for: UIControlState())
                Answer4.setTitle("enviar", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 76:
                Question.text = "Which verb means 'to wake up'?"
                Answer1.setTitle("dormir", for: UIControlState())
                Answer2.setTitle("levantar", for: UIControlState())
                Answer3.setTitle("acostarse", for: UIControlState())
                Answer4.setTitle("despertar", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 77:
                Question.text = "Which verb means 'to want'?"
                Answer1.setTitle("querer", for: UIControlState())
                Answer2.setTitle("quitar", for: UIControlState())
                Answer3.setTitle("qeujar", for: UIControlState())
                Answer4.setTitle("quehacer", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 78:
                Question.text = "Which verb means 'to take away'?"
                Answer1.setTitle("quejar", for: UIControlState())
                Answer2.setTitle("quitar", for: UIControlState())
                Answer3.setTitle("quásar", for: UIControlState())
                Answer4.setTitle("quehacer", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 79:
                Question.text = "Which verb means 'to worry'?"
                Answer1.setTitle("peinar", for: UIControlState())
                Answer2.setTitle("predicir", for: UIControlState())
                Answer3.setTitle("preocuparse", for: UIControlState())
                Answer4.setTitle("parchear", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 80:
                Question.text = "Which verb means 'to write'?"
                Answer1.setTitle("enojar", for: UIControlState())
                Answer2.setTitle("esconder", for: UIControlState())
                Answer3.setTitle("evitar", for: UIControlState())
                Answer4.setTitle("escribir", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 81:
                Question.text = "Which verb means 'to make'?"
                Answer1.setTitle("hacer", for: UIControlState())
                Answer2.setTitle("crear", for: UIControlState())
                Answer3.setTitle("hallar", for: UIControlState())
                Answer4.setTitle("hincar", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 82:
                Question.text = "Which verb means 'to come'?"
                Answer1.setTitle("violar", for: UIControlState())
                Answer2.setTitle("venir", for: UIControlState())
                Answer3.setTitle("velar", for: UIControlState())
                Answer4.setTitle("llegar", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 83:
                Question.text = "Which verb means 'to return'?"
                Answer1.setTitle("vendar", for: UIControlState())
                Answer2.setTitle("viciar", for: UIControlState())
                Answer3.setTitle("volver", for: UIControlState())
                Answer4.setTitle("volverse", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 84:
                Question.text = "Which verb means 'to leave'?"
                Answer1.setTitle("situar", for: UIControlState())
                Answer2.setTitle("saltar", for: UIControlState())
                Answer3.setTitle("sanar", for: UIControlState())
                Answer4.setTitle("salir", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 85:
                Question.text = "Which verb means 'to know'?"
                Answer1.setTitle("conocer", for: UIControlState())
                Answer2.setTitle("chismear", for: UIControlState())
                Answer3.setTitle("coger", for: UIControlState())
                Answer4.setTitle("crecer", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 86:
                Question.text = "Which verb means 'to follow'?"
                Answer1.setTitle("secarse", for: UIControlState())
                Answer2.setTitle("seguir", for: UIControlState())
                Answer3.setTitle("sugerir", for: UIControlState())
                Answer4.setTitle("saborear", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 87:
                Question.text = "Which verb means 'to carry'?"
                Answer1.setTitle("calcular", for: UIControlState())
                Answer2.setTitle("caller", for: UIControlState())
                Answer3.setTitle("llevar", for: UIControlState())
                Answer4.setTitle("cazar", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 88:
                Question.text = "Which verb means 'to like'?"
                Answer1.setTitle("guinchar", for: UIControlState())
                Answer2.setTitle("globular", for: UIControlState())
                Answer3.setTitle("graznar", for: UIControlState())
                Answer4.setTitle("gustar", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 89:
                Question.text = "Which verb means 'to prefer'?"
                Answer1.setTitle("preferir", for: UIControlState())
                Answer2.setTitle("picar", for: UIControlState())
                Answer3.setTitle("preguntar", for: UIControlState())
                Answer4.setTitle("propner", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 90:
                Question.text = "Which verb means 'to die'?"
                Answer1.setTitle("meter", for: UIControlState())
                Answer2.setTitle("morir", for: UIControlState())
                Answer3.setTitle("majar", for: UIControlState())
                Answer4.setTitle("maliciar", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 91:
                Question.text = "Which verb means 'to look for'?"
                Answer1.setTitle("ver", for: UIControlState())
                Answer2.setTitle("buscar", for: UIControlState())
                Answer3.setTitle("mirar", for: UIControlState())
                Answer4.setTitle("bailar", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 92:
                Question.text = "Which verb means 'to laugh'?"
                Answer1.setTitle("robar", for: UIControlState())
                Answer2.setTitle("regresar", for: UIControlState())
                Answer3.setTitle("reír", for: UIControlState())
                Answer4.setTitle("rayar", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 93:
                Question.text = "Which verb means 'to walk'?"
                Answer1.setTitle("volver", for: UIControlState())
                Answer2.setTitle("correr", for: UIControlState())
                Answer3.setTitle("apostar", for: UIControlState())
                Answer4.setTitle("andar", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 94:
                Question.text = "Which verb means 'to dress'?"
                Answer1.setTitle("vestir", for: UIControlState())
                Answer2.setTitle("venir", for: UIControlState())
                Answer3.setTitle("violar", for: UIControlState())
                Answer4.setTitle("vedar", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 95:
                Question.text = "Which verb means 'to play an instrument'?"
                Answer1.setTitle("tantear", for: UIControlState())
                Answer2.setTitle("tocar", for: UIControlState())
                Answer3.setTitle("jugar", for: UIControlState())
                Answer4.setTitle("topar", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 96:
                Question.text = "Which verb means 'to have lunch'?"
                Answer1.setTitle("comer", for: UIControlState())
                Answer2.setTitle("linchar", for: UIControlState())
                Answer3.setTitle("almorzar", for: UIControlState())
                Answer4.setTitle("llagar", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 97:
                Question.text = "Which verb means 'to take out'?"
                Answer1.setTitle("salir", for: UIControlState())
                Answer2.setTitle("soñar", for: UIControlState())
                Answer3.setTitle("saber", for: UIControlState())
                Answer4.setTitle("sacar", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 98:
                Question.text = "Which verb means 'to raise'?"
                Answer1.setTitle("levantar", for: UIControlState())
                Answer2.setTitle("labrar", for: UIControlState())
                Answer3.setTitle("ladear", for: UIControlState())
                Answer4.setTitle("latir", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 99:
                Question.text = "Which verb means 'to choose'?"
                Answer1.setTitle("echar", for: UIControlState())
                Answer2.setTitle("elegir", for: UIControlState())
                Answer3.setTitle("encantar", for: UIControlState())
                Answer4.setTitle("exponer", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 100:
                Question.text = "Which verb means 'to come up'?"
                Answer1.setTitle("sanar", for: UIControlState())
                Answer2.setTitle("sufrir", for: UIControlState())
                Answer3.setTitle("subir", for: UIControlState())
                Answer4.setTitle("sanear", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 101:
                Question.text = "Which verb means 'to seem'?"
                Answer1.setTitle("sufrir", for: UIControlState())
                Answer2.setTitle("prever", for: UIControlState())
                Answer3.setTitle("secarse", for: UIControlState())
                Answer4.setTitle("parecer", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 102:
                Question.text = "Which verb means 'to win'?"
                Answer1.setTitle("ganar", for: UIControlState())
                Answer2.setTitle("gastar", for: UIControlState())
                Answer3.setTitle("gerenciar", for: UIControlState())
                Answer4.setTitle("guiñar", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 103:
                Question.text = "Which verb means 'to comb'?"
                Answer1.setTitle("comer", for: UIControlState())
                Answer2.setTitle("peinar", for: UIControlState())
                Answer3.setTitle("reir", for: UIControlState())
                Answer4.setTitle("pensar", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 104:
                Question.text = "Which verb means 'to hear'?"
                Answer1.setTitle("ver", for: UIControlState())
                Answer2.setTitle("escuchar", for: UIControlState())
                Answer3.setTitle("oir ", for: UIControlState())
                Answer4.setTitle("oler", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 105:
                Question.text = "Which verb means 'to hurt'?"
                Answer1.setTitle("hacer", for: UIControlState())
                Answer2.setTitle("defender", for: UIControlState())
                Answer3.setTitle("dudar", for: UIControlState())
                Answer4.setTitle("dañar", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 106:
                Question.text = "Which verb means 'to knock down'?"
                Answer1.setTitle("abatir", for: UIControlState())
                Answer2.setTitle("reír", for: UIControlState())
                Answer3.setTitle("advertir", for: UIControlState())
                Answer4.setTitle("golpear", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 107:
                Question.text = "Which verb means 'to acquit'?"
                Answer1.setTitle("quitar", for: UIControlState())
                Answer2.setTitle("absolver", for: UIControlState())
                Answer3.setTitle("alquilar", for: UIControlState())
                Answer4.setTitle("arder", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 108:
                Question.text = "Which verb means 'to bore'?"
                Answer1.setTitle("arribar", for: UIControlState())
                Answer2.setTitle("implicar", for: UIControlState())
                Answer3.setTitle("aburrir", for: UIControlState())
                Answer4.setTitle("borrar", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 109:
                Question.text = "Which verb means 'to finish'?"
                Answer1.setTitle("pensar", for: UIControlState())
                Answer2.setTitle("fingir", for: UIControlState())
                Answer3.setTitle("festejarse", for: UIControlState())
                Answer4.setTitle("acabar", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 110:
                Question.text = "Which verb means 'to hurry'?"
                Answer1.setTitle("acelerar", for: UIControlState())
                Answer2.setTitle("hallar", for: UIControlState())
                Answer3.setTitle("acercar", for: UIControlState())
                Answer4.setTitle("huir", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 111:
                Question.text = "Which verb means 'to approach'?"
                Answer1.setTitle("apostar", for: UIControlState())
                Answer2.setTitle("acercarse", for: UIControlState())
                Answer3.setTitle("encontrar", for: UIControlState())
                Answer4.setTitle("esperar", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 112:
                Question.text = "Which verb means 'to shout'?"
                Answer1.setTitle("decir", for: UIControlState())
                Answer2.setTitle("sudar", for: UIControlState())
                Answer3.setTitle("gritar", for: UIControlState())
                Answer4.setTitle("reír", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 113:
                Question.text = "Which verb means 'to make clear'?"
                Answer1.setTitle("hacer", for: UIControlState())
                Answer2.setTitle("aliviar", for: UIControlState())
                Answer3.setTitle("abollar", for: UIControlState())
                Answer4.setTitle("aclarar", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 114:
                Question.text = "Which verb means 'to accompany'?"
                Answer1.setTitle("acompañar", for: UIControlState())
                Answer2.setTitle("llegar", for: UIControlState())
                Answer3.setTitle("regresar", for: UIControlState())
                Answer4.setTitle("acolchar", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 115:
                Question.text = "Which verb means 'to advise'?"
                Answer1.setTitle("adelantar", for: UIControlState())
                Answer2.setTitle("aconsejar", for: UIControlState())
                Answer3.setTitle("agachar", for: UIControlState())
                Answer4.setTitle("adivinar", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 116:
                Question.text = "Which verb means 'to cut open'?"
                Answer1.setTitle("actuar", for: UIControlState())
                Answer2.setTitle("cortar", for: UIControlState())
                Answer3.setTitle("acuchillar", for: UIControlState())
                Answer4.setTitle("acicalarse", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 117:
                Question.text = "Which verb means 'to attend'?"
                Answer1.setTitle("acodar", for: UIControlState())
                Answer2.setTitle("agotar", for: UIControlState())
                Answer3.setTitle("abarcar", for: UIControlState())
                Answer4.setTitle("acudir", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 118:
                Question.text = "Which verb means 'to advance'?"
                Answer1.setTitle("adelantar", for: UIControlState())
                Answer2.setTitle("abogar", for: UIControlState())
                Answer3.setTitle("acceder", for: UIControlState())
                Answer4.setTitle("absolver", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 119:
                Question.text = "Which verb means 'to obtain'?"
                Answer1.setTitle("oler", for: UIControlState())
                Answer2.setTitle("agarrar", for: UIControlState())
                Answer3.setTitle("obstinar", for: UIControlState())
                Answer4.setTitle("obturar", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 120:
                Question.text = "Which verb means 'to exhaust'?"
                Answer1.setTitle("explotar", for: UIControlState())
                Answer2.setTitle("exhortar", for: UIControlState())
                Answer3.setTitle("agotar", for: UIControlState())
                Answer4.setTitle("abuchear", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 121:
                Question.text = "Which verb means 'to please'?"
                Answer1.setTitle("pensar", for: UIControlState())
                Answer2.setTitle("pelear", for: UIControlState())
                Answer3.setTitle("apostar", for: UIControlState())
                Answer4.setTitle("agradar", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 122:
                Question.text = "Which verb means 'to increase'?"
                Answer1.setTitle("incrementar", for: UIControlState())
                Answer2.setTitle("iniciar", for: UIControlState())
                Answer3.setTitle("injertar", for: UIControlState())
                Answer4.setTitle("incitar", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 123:
                Question.text = "Which verb means ‘to bandage'?"
                Answer1.setTitle("vender", for: UIControlState())
                Answer2.setTitle("vendar", for: UIControlState())
                Answer3.setTitle("burlar", for: UIControlState())
                Answer4.setTitle("balear", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 124:
                Question.text = "Which verb means ‘to trip'?"
                Answer1.setTitle("caerse", for: UIControlState())
                Answer2.setTitle("tropezar", for: UIControlState())
                Answer3.setTitle("trocar", for: UIControlState())
                Answer4.setTitle("tapar", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 125:
                Question.text = "Which verb means ‘to take place'?"
                Answer1.setTitle("ocasionar", for: UIControlState())
                Answer2.setTitle("tajear", for: UIControlState())
                Answer3.setTitle("transcurrir", for: UIControlState())
                Answer4.setTitle("oponerse", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 126:
                Question.text = "Which verb means ‘to sprain'?"
                Answer1.setTitle("trotar", for: UIControlState())
                Answer2.setTitle("esperar", for: UIControlState())
                Answer3.setTitle("soltar", for: UIControlState())
                Answer4.setTitle("torcer", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 127:
                Question.text = "Which verb means ‘to pull'?"
                Answer1.setTitle("tirar", for: UIControlState())
                Answer2.setTitle("caer", for: UIControlState())
                Answer3.setTitle("trotar", for: UIControlState())
                Answer4.setTitle("bajar", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 128:
                Question.text = "Which verb means ‘to fail'?"
                Answer1.setTitle("aprobar ", for: UIControlState())
                Answer2.setTitle("suspender", for: UIControlState())
                Answer3.setTitle("firmar", for: UIControlState())
                Answer4.setTitle("fugarse", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 129:
                Question.text = "Which verb means ‘to overcome'?"
                Answer1.setTitle("ondular", for: UIControlState())
                Answer2.setTitle("oscurecer", for: UIControlState())
                Answer3.setTitle("superar", for: UIControlState())
                Answer4.setTitle("sepultar", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 130:
                Question.text = "Which verb means ‘to be lucky'?"
                Answer1.setTitle("llamar", for: UIControlState())
                Answer2.setTitle("soñar", for: UIControlState())
                Answer3.setTitle("limpiar", for: UIControlState())
                Answer4.setTitle("suerte", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 131:
                Question.text = "Which verb means ‘to sweat'?"
                Answer1.setTitle("sudar", for: UIControlState())
                Answer2.setTitle("secar", for: UIControlState())
                Answer3.setTitle("soñar", for: UIControlState())
                Answer4.setTitle("soler", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 132:
                Question.text = "Which verb means ‘to ring'?"
                Answer1.setTitle("salar", for: UIControlState())
                Answer2.setTitle("sonar", for: UIControlState())
                Answer3.setTitle("sanar", for: UIControlState())
                Answer4.setTitle("soñar", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 133:
                Question.text = "Which verb means ‘to ask for'?"
                Answer1.setTitle("dar", for: UIControlState())
                Answer2.setTitle("saltear", for: UIControlState())
                Answer3.setTitle("solicitar", for: UIControlState())
                Answer4.setTitle("segregar", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 134:
                Question.text = "Which verb means ‘to feel'?"
                Answer1.setTitle("esperar", for: UIControlState())
                Answer2.setTitle("doler", for: UIControlState())
                Answer3.setTitle("pensar", for: UIControlState())
                Answer4.setTitle("sentirse", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 135:
                Question.text = "Which verb means ‘to dry'?"
                Answer1.setTitle("secar", for: UIControlState())
                Answer2.setTitle("mojar", for: UIControlState())
                Answer3.setTitle("doler", for: UIControlState())
                Answer4.setTitle("dirigir", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 136:
                Question.text = "Which verb means ‘to snore'?"
                Answer1.setTitle("rezar", for: UIControlState())
                Answer2.setTitle("roncar", for: UIControlState())
                Answer3.setTitle("soler", for: UIControlState())
                Answer4.setTitle("raer", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 137:
                Question.text = "Which verb means ‘to tow away'?"
                Answer1.setTitle("roncar", for: UIControlState())
                Answer2.setTitle("volver", for: UIControlState())
                Answer3.setTitle("retirar", for: UIControlState())
                Answer4.setTitle("regresar", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 138:
                Question.text = "Which verb means ‘to relax'?"
                Answer1.setTitle("soñar", for: UIControlState())
                Answer2.setTitle("regalar", for: UIControlState())
                Answer3.setTitle("saciar", for: UIControlState())
                Answer4.setTitle("relajarse", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 139:
                Question.text = "Which verb means ‘to prescribe'?"
                Answer1.setTitle("recetar", for: UIControlState())
                Answer2.setTitle("pegar", for: UIControlState())
                Answer3.setTitle("patentizar", for: UIControlState())
                Answer4.setTitle("preguntar", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 140:
                Question.text = "Which verb means ‘to carry out'?"
                Answer1.setTitle("caller", for: UIControlState())
                Answer2.setTitle("realizar", for: UIControlState())
                Answer3.setTitle("cargar", for: UIControlState())
                Answer4.setTitle("narrar", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 141:
                Question.text = "Which verb means ‘to scratch'?"
                Answer1.setTitle("necear", for: UIControlState())
                Answer2.setTitle("socavar", for: UIControlState())
                Answer3.setTitle("rascar", for: UIControlState())
                Answer4.setTitle("renacer", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 142:
                Question.text = "Which verb means ‘to burn'?"
                Answer1.setTitle("quemar", for: UIControlState())
                Answer2.setTitle("rogar", for: UIControlState())
                Answer3.setTitle("brindar", for: UIControlState())
                Answer4.setTitle("rapar", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 143:
                Question.text = "Which verb means ‘to be able'?"
                Answer1.setTitle("pensar", for: UIControlState())
                Answer2.setTitle("poder", for: UIControlState())
                Answer3.setTitle("andar", for: UIControlState())
                Answer4.setTitle("vacar", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 144:
                Question.text = "Which verb means ‘to hit'?"
                Answer1.setTitle("hartar", for: UIControlState())
                Answer2.setTitle("hundir", for: UIControlState())
                Answer3.setTitle("pegar", for: UIControlState())
                Answer4.setTitle("parchar", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 145:
                Question.text = "Which verb means ‘to skate'?"
                Answer1.setTitle("provocar", for: UIControlState())
                Answer2.setTitle("sanear", for: UIControlState())
                Answer3.setTitle("escoger", for: UIControlState())
                Answer4.setTitle("patinar", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 146:
                Question.text = "Which verb means ‘to stop'?"
                Answer1.setTitle("parar", for: UIControlState())
                Answer2.setTitle("entregar", for: UIControlState())
                Answer3.setTitle("padecer", for: UIControlState())
                Answer4.setTitle("empezar", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 147:
                Question.text = "Which verb means ‘to award'?"
                Answer1.setTitle("oler", for: UIControlState())
                Answer2.setTitle("otorgar", for: UIControlState())
                Answer3.setTitle("obrar", for: UIControlState())
                Answer4.setTitle("ostentar", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 148:
                Question.text = "Which verb means ‘to be born'?"
                Answer1.setTitle("borrar", for: UIControlState())
                Answer2.setTitle("nevar", for: UIControlState())
                Answer3.setTitle("nacer", for: UIControlState())
                Answer4.setTitle("boquear", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 149:
                Question.text = "Which verb means ‘to score'?"
                Answer1.setTitle("suponer", for: UIControlState())
                Answer2.setTitle("sorprender", for: UIControlState())
                Answer3.setTitle("quásar", for: UIControlState())
                Answer4.setTitle("marcar", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 150:
                Question.text = "Which verb means ‘to fight'?"
                Answer1.setTitle("luchar", for: UIControlState())
                Answer2.setTitle("fatiar", for: UIControlState())
                Answer3.setTitle("yodar", for: UIControlState())
                Answer4.setTitle("zambullir", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 151:
                Question.text = "Which verb means ‘to cheer on'?"
                Answer1.setTitle("jugar", for: UIControlState())
                Answer2.setTitle("jalear", for: UIControlState())
                Answer3.setTitle("jurar", for: UIControlState())
                Answer4.setTitle("jactar", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 152:
                Question.text = "Which verb means ‘to be admitted'?"
                Answer1.setTitle("admitir", for: UIControlState())
                Answer2.setTitle("indignar", for: UIControlState())
                Answer3.setTitle("ingresar", for: UIControlState())
                Answer4.setTitle("agradar", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 153:
                Question.text = "Which verb means ‘to care'?"
                Answer1.setTitle("comer", for: UIControlState())
                Answer2.setTitle("calar", for: UIControlState())
                Answer3.setTitle("invitar", for: UIControlState())
                Answer4.setTitle("importar", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 154:
                Question.text = "Which verb means ‘to have'?"
                Answer1.setTitle("haber", for: UIControlState())
                Answer2.setTitle("hacer", for: UIControlState())
                Answer3.setTitle("halar", for: UIControlState())
                Answer4.setTitle("hundir", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 155:
                Question.text = "Which verb means ‘to hit'?"
                Answer1.setTitle("hincar", for: UIControlState())
                Answer2.setTitle("golpear", for: UIControlState())
                Answer3.setTitle("gobernar", for: UIControlState())
                Answer4.setTitle("herir", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 156:
                Question.text = "Which verb means ‘to swerve'?"
                Answer1.setTitle("golpear", for: UIControlState())
                Answer2.setTitle("soplar", for: UIControlState())
                Answer3.setTitle("girar", for: UIControlState())
                Answer4.setTitle("sumir", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 157:
                Question.text = "Which verb means ‘to turn'?"
                Answer1.setTitle("traer", for: UIControlState())
                Answer2.setTitle("hacer", for: UIControlState())
                Answer3.setTitle("tantear", for: UIControlState())
                Answer4.setTitle("torcer", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 158:
                Question.text = "Which verb means ‘to avoid'?"
                Answer1.setTitle("evitar", for: UIControlState())
                Answer2.setTitle("embrujar", for: UIControlState())
                Answer3.setTitle("abusar", for: UIControlState())
                Answer4.setTitle("avisar", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 159:
                Question.text = "Which verb means ‘to love'?"
                Answer1.setTitle("llover", for: UIControlState())
                Answer2.setTitle("encantar", for: UIControlState())
                Answer3.setTitle("soler", for: UIControlState())
                Answer4.setTitle("gustar", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 160:
                Question.text = "Which verb means ‘to begin'?"
                Answer1.setTitle("borrar", for: UIControlState())
                Answer2.setTitle("calmar", for: UIControlState())
                Answer3.setTitle("empezar", for: UIControlState())
                Answer4.setTitle("invocar", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 161:
                Question.text = "Which verb means ‘to rest'?"
                Answer1.setTitle("sepultar", for: UIControlState())
                Answer2.setTitle("dormir", for: UIControlState())
                Answer3.setTitle("vociferar", for: UIControlState())
                Answer4.setTitle("descansar", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 162:
                Question.text = "Which verb means ‘to skid'?"
                Answer1.setTitle("derrapar", for: UIControlState())
                Answer2.setTitle("seducir", for: UIControlState())
                Answer3.setTitle("saldar", for: UIControlState())
                Answer4.setTitle("despedir", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 163:
                Question.text = "Which verb means ‘to show'?"
                Answer1.setTitle("espantar", for: UIControlState())
                Answer2.setTitle("mostrar", for: UIControlState())
                Answer3.setTitle("mamar", for: UIControlState())
                Answer4.setTitle("manar", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 164:
                Question.text = "Which verb means ‘to leave'?"
                Answer1.setTitle("ocultar", for: UIControlState())
                Answer2.setTitle("ultrajar", for: UIControlState())
                Answer3.setTitle("dejar", for: UIControlState())
                Answer4.setTitle("haber", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 165:
                Question.text = "Which verb means ‘to mind'?"
                Answer1.setTitle("mezclar", for: UIControlState())
                Answer2.setTitle("bufar", for: UIControlState())
                Answer3.setTitle("lidiar", for: UIControlState())
                Answer4.setTitle("cuidar", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 166:
                Question.text = "Which verb means ‘to share'?"
                Answer1.setTitle("compartir", for: UIControlState())
                Answer2.setTitle("ventear", for: UIControlState())
                Answer3.setTitle("conocer", for: UIControlState())
                Answer4.setTitle("juzgar", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 167:
                Question.text = "Which verb means ‘to celebrate'?"
                Answer1.setTitle("fortalecer", for: UIControlState())
                Answer2.setTitle("celebrar", for: UIControlState())
                Answer3.setTitle("novelar", for: UIControlState())
                Answer4.setTitle("ducharse", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 168:
                Question.text = "Which verb means ‘to dive'?"
                Answer1.setTitle("caer", for: UIControlState())
                Answer2.setTitle("divisar", for: UIControlState())
                Answer3.setTitle("bucear", for: UIControlState())
                Answer4.setTitle("dividir", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 169:
                Question.text = "Which verb means ‘to bless'?"
                Answer1.setTitle("magullar", for: UIControlState())
                Answer2.setTitle("relatar", for: UIControlState())
                Answer3.setTitle("campar", for: UIControlState())
                Answer4.setTitle("bendecir", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 170:
                Question.text = "Which verb means ‘to beat'?"
                Answer1.setTitle("batir", for: UIControlState())
                Answer2.setTitle("soltar", for: UIControlState())
                Answer3.setTitle("dividir", for: UIControlState())
                Answer4.setTitle("enfermar", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 171:
                Question.text = "Which verb means ‘to sweep'?"
                Answer1.setTitle("saltar", for: UIControlState())
                Answer2.setTitle("barrer", for: UIControlState())
                Answer3.setTitle("chocar", for: UIControlState())
                Answer4.setTitle("brillar", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 172:
                Question.text = "Which verb means ‘to go down'?"
                Answer1.setTitle("subir", for: UIControlState())
                Answer2.setTitle("barrer", for: UIControlState())
                Answer3.setTitle("bajar", for: UIControlState())
                Answer4.setTitle("obrar", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 173:
                Question.text = "Which verb means ‘to help'?"
                Answer1.setTitle("halagar", for: UIControlState())
                Answer2.setTitle("tamizar", for: UIControlState())
                Answer3.setTitle("olvidar", for: UIControlState())
                Answer4.setTitle("ayudar", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 174:
                Question.text = "Which verb means ‘to increase'?"
                Answer1.setTitle("aumentar", for: UIControlState())
                Answer2.setTitle("sugerir", for: UIControlState())
                Answer3.setTitle("invertir", for: UIControlState())
                Answer4.setTitle("yugular", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 175:
                Question.text = "Which verb means ‘to tidy'?"
                Answer1.setTitle("limpiar", for: UIControlState())
                Answer2.setTitle("arreglar", for: UIControlState())
                Answer3.setTitle("trocear", for: UIControlState())
                Answer4.setTitle("graznar", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 176:
                Question.text = "Which verb means ‘to pass'?"
                Answer1.setTitle("suspender", for: UIControlState())
                Answer2.setTitle("parecer", for: UIControlState())
                Answer3.setTitle("aprobar", for: UIControlState())
                Answer4.setTitle("burlarse", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 177:
                Question.text = "Which verb means ‘to lean on'?"
                Answer1.setTitle("llenar", for: UIControlState())
                Answer2.setTitle("necear", for: UIControlState())
                Answer3.setTitle("mudarse", for: UIControlState())
                Answer4.setTitle("apoyar", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 178:
                Question.text = "Which verb means ‘to earn'?"
                Answer1.setTitle("ganar", for: UIControlState())
                Answer2.setTitle("pagar", for: UIControlState())
                Answer3.setTitle("gozar", for: UIControlState())
                Answer4.setTitle("reinar", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 179:
                Question.text = "Which verb means ‘to rent'?"
                Answer1.setTitle("aprobar", for: UIControlState())
                Answer2.setTitle("alquilar", for: UIControlState())
                Answer3.setTitle("vender", for: UIControlState())
                Answer4.setTitle("entretener", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 180:
                Question.text = "Which verb means ‘to reach'?"
                Answer1.setTitle("reír", for: UIControlState())
                Answer2.setTitle("saciar", for: UIControlState())
                Answer3.setTitle("alcanzar", for: UIControlState())
                Answer4.setTitle("guiar", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 181:
                Question.text = "Which verb means ‘to save'?"
                Answer1.setTitle("sentirse", for: UIControlState())
                Answer2.setTitle("castigar", for: UIControlState())
                Answer3.setTitle("acortar", for: UIControlState())
                Answer4.setTitle("ahorrar", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 182:
                Question.text = "Which verb means ‘to overtake'?"
                Answer1.setTitle("adelantar", for: UIControlState())
                Answer2.setTitle("ahorrar", for: UIControlState())
                Answer3.setTitle("rezar", for: UIControlState())
                Answer4.setTitle("recargar", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 183:
                Question.text = "Which verb means ‘to upset'?"
                Answer1.setTitle("sentirse", for: UIControlState())
                Answer2.setTitle("disgustar", for: UIControlState())
                Answer3.setTitle("usurpar", for: UIControlState())
                Answer4.setTitle("unirse", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 184:
                Question.text = "Which verb means ‘to go'?"
                Answer1.setTitle("volver", for: UIControlState())
                Answer2.setTitle("adelantar", for: UIControlState())
                Answer3.setTitle("ir", for: UIControlState())
                Answer4.setTitle("dar", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 185:
                Question.text = "Which verb means ‘to iron'?"
                Answer1.setTitle("iniciar", for: UIControlState())
                Answer2.setTitle("imantar", for: UIControlState())
                Answer3.setTitle("flirtear", for: UIControlState())
                Answer4.setTitle("planchar", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 186:
                Question.text = "Which verb means ‘to fill a tooth'?"
                Answer1.setTitle("empastar", for: UIControlState())
                Answer2.setTitle("llenar", for: UIControlState())
                Answer3.setTitle("formalizar", for: UIControlState())
                Answer4.setTitle("surgir", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 187:
                Question.text = "Which verb means ‘to have lunch'?"
                Answer1.setTitle("cenar", for: UIControlState())
                Answer2.setTitle("almorzar", for: UIControlState())
                Answer3.setTitle("acampar", for: UIControlState())
                Answer4.setTitle("comer", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 188:
                Question.text = "Which verb means ‘to have dinner'?"
                Answer1.setTitle("almorzar", for: UIControlState())
                Answer2.setTitle("comer", for: UIControlState())
                Answer3.setTitle("cenar", for: UIControlState())
                Answer4.setTitle("desayunar", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 189:
                Question.text = "Which verb means ‘to have breakfast'?"
                Answer1.setTitle("almorzar", for: UIControlState())
                Answer2.setTitle("cenar", for: UIControlState())
                Answer3.setTitle("comer", for: UIControlState())
                Answer4.setTitle("desayunar", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 190:
                Question.text = "Which verb means ‘to add'?"
                Answer1.setTitle("añadir", for: UIControlState())
                Answer2.setTitle("incrementar", for: UIControlState())
                Answer3.setTitle("adelantar", for: UIControlState())
                Answer4.setTitle("adivinar", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 191:
                Question.text = "Which verb means ‘to attend'?"
                Answer1.setTitle("aprender", for: UIControlState())
                Answer2.setTitle("asistir", for: UIControlState())
                Answer3.setTitle("ir", for: UIControlState())
                Answer4.setTitle("alcanzar", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 192:
                Question.text = "Which verb means ‘to cross'?"
                Answer1.setTitle("llevar", for: UIControlState())
                Answer2.setTitle("causar", for: UIControlState())
                Answer3.setTitle("atravesar", for: UIControlState())
                Answer4.setTitle("cargar", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 193:
                Question.text = "Which verb means ‘to tan'?"
                Answer1.setTitle("tener", for: UIControlState())
                Answer2.setTitle("tirar", for: UIControlState())
                Answer3.setTitle("granizar", for: UIControlState())
                Answer4.setTitle("broncear", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 194:
                Question.text = "Which verb means ‘to wear shoes'?"
                Answer1.setTitle("calzar", for: UIControlState())
                Answer2.setTitle("usar los zapatos", for: UIControlState())
                Answer3.setTitle("tirar los zapatos", for: UIControlState())
                Answer4.setTitle("llevar", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 195:
                Question.text = "Which verb means ‘to become tired'?"
                Answer1.setTitle("sentirse", for: UIControlState())
                Answer2.setTitle("cansarse", for: UIControlState())
                Answer3.setTitle("tirar", for: UIControlState())
                Answer4.setTitle("dormir", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 196:
                Question.text = "Which verb means ‘to collect'?"
                Answer1.setTitle("brindar", for: UIControlState())
                Answer2.setTitle("elegir", for: UIControlState())
                Answer3.setTitle("colegir", for: UIControlState())
                Answer4.setTitle("ejecutar", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 197:
                Question.text = "Which verb means ‘to cross'?"
                Answer1.setTitle("torcer", for: UIControlState())
                Answer2.setTitle("uncir", for: UIControlState())
                Answer3.setTitle("derribar", for: UIControlState())
                Answer4.setTitle("cruzar", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 198:
                Question.text = "Which verb means ‘to discover'?"
                Answer1.setTitle("descubrir", for: UIControlState())
                Answer2.setTitle("desacatar", for: UIControlState())
                Answer3.setTitle("elegir", for: UIControlState())
                Answer4.setTitle("encontrar", for: UIControlState())
                CorrectAnswer = "1"
                break
            case 199:
                Question.text = "Which verb means ‘to destroy'?"
                Answer1.setTitle("conseguir", for: UIControlState())
                Answer2.setTitle("deshacer", for: UIControlState())
                Answer3.setTitle("romper", for: UIControlState())
                Answer4.setTitle("quejarse", for: UIControlState())
                CorrectAnswer = "2"
                break
            case 200:
                Question.text = "Which verb means ‘to direct'?"
                Answer1.setTitle("quásar", for: UIControlState())
                Answer2.setTitle("derretir", for: UIControlState())
                Answer3.setTitle("dirigir", for: UIControlState())
                Answer4.setTitle("vivificar", for: UIControlState())
                CorrectAnswer = "3"
                break
            case 201:
                Question.text = "Which verb means ‘to ski'?"
                Answer1.setTitle("escoger", for: UIControlState())
                Answer2.setTitle("sitiar", for: UIControlState())
                Answer3.setTitle("oxidar", for: UIControlState())
                Answer4.setTitle("esquiar", for: UIControlState())
                CorrectAnswer = "4"
                break
            case 202:
                Question.text = "Which verb means ‘to choose'?"
                Answer1.setTitle("escoger", for: UIControlState())
                Answer2.setTitle("cuidar", for: UIControlState())
                Answer3.setTitle("ostentar", for: UIControlState())
                Answer4.setTitle("cobrar", for: UIControlState())
                CorrectAnswer = "1"
                break
            default:
                break
            }
        }
    }
    
    
}

