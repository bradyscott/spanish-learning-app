//
//  QuizSelectionViewController.swift
//  Verbos en español
//
//  Created by Scott Brady on 03/06/2016.
//  Copyright © 2016 Scott Brady. All rights reserved.
//

import UIKit
import Foundation
class QuizSelectionViewController: UIViewController {
    
    //@IBOutlet var Name: UILabel!
    @IBOutlet var Verbs: UIButton!
    @IBOutlet var Animals: UIButton!
    @IBOutlet var Food: UIButton!
    @IBOutlet var City: UIButton!
    @IBOutlet var School: UIButton!
    @IBOutlet var Clothes: UIButton!
    @IBOutlet var Hobbies: UIButton!
    @IBOutlet var QuestionNumber: UILabel!
    @IBOutlet var QuestionSlider: UISlider!
    var quizType = String()
    //var numberOfQuestions = Double()
    var numberOfQuestions = Int()
    
    override func viewDidAppear(_ animated: Bool) {
        
        if ConnectionCheck.isConnectedToNetwork() {
            print("Connected")
        }
        else{
            
            let networkAlert = UIAlertController(title: "No Network Connection", message: "Turn on Mobile Data or connect to a Wi-Fi network to access quizzes", preferredStyle: .alert)
            
            networkAlert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil/*{ action in
                let upgradeAlertController = UIAlertController(title: "Upgrade to enable offline mode", message: "Upgrade Concurso español to access quizzes offline and enjoy an ad-free experience!", preferredStyle: .alert)
                upgradeAlertController.addAction(UIAlertAction(title: "Upgrade!", style: .default, handler: { action in
                    self.performSegue(withIdentifier: "showStore", sender: nil)
            }*/))
                //self.present(upgradeAlertController, animated: true, completion: nil)
            // }))
            
            networkAlert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { action in
                let url = URL(string: "App-Prefs:root=WIFI")
                let app = UIApplication.shared
                app.openURL(url!)
            }))
            
            self.present(networkAlert, animated: true, completion: nil)

        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        getNumberOfQuestions()

        self.QuestionNumber.layer.masksToBounds = true
        self.QuestionNumber.layer.cornerRadius = 7
        
        animateButtons(Animals, buttonDelay: 0)
        animateButtons(Clothes, buttonDelay: 0.075)
        animateButtons(Food, buttonDelay: 0.15)
        animateButtons(City, buttonDelay: 0.225)
        animateButtons(Hobbies, buttonDelay: 0.3)
        animateButtons(School, buttonDelay: 0.375)
        animateButtons(Verbs, buttonDelay: 0.425)

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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "StartQuiz" {
            
            if let destinationVC = segue.destination as? FoodViewController {
                
                destinationVC.quizTypeToBegin = quizType
                destinationVC.numberOfQuestionsToBegin = numberOfQuestions
                
            }
        }
    }
    
    func getNumberOfQuestions() {
        numberOfQuestions = Int(QuestionSlider.value)
        QuestionNumber.text = "Number of questions: \(numberOfQuestions)"
    }
    
    @IBAction func clothes(_ sender: Any) {
        quizType = "Clothes & Colours"
        performSegue(withIdentifier: "StartQuiz", sender: nil)
    }
    
    @IBAction func verbs(_ sender: AnyObject) {
        quizType = "Verbs"
        performSegue(withIdentifier: "StartQuiz", sender: nil)
    }
    
    @IBAction func animals(_ sender: AnyObject) {
        quizType = "Animals"
        performSegue(withIdentifier: "StartQuiz", sender: nil)
    }
    
    @IBAction func food(_ sender: Any) {
        quizType = "Food"
        performSegue(withIdentifier: "StartQuiz", sender: nil)
    }
    
    @IBAction func hobbies(_ sender: Any) {
        quizType = "Hobbies"
        performSegue(withIdentifier: "StartQuiz", sender: nil)
        
    }
    
    @IBAction func school(_ sender: Any) {
        quizType = "School"
        performSegue(withIdentifier: "StartQuiz", sender: nil)
        
    }
    @IBAction func city(_ sender: Any) {
        quizType = "In the city"
        performSegue(withIdentifier: "StartQuiz", sender: nil)
        
    }
    @IBAction func sliderMoved(_ sender: Any) {
        
        getNumberOfQuestions()
        
        print("\(numberOfQuestions)")
        
    }
    
}
