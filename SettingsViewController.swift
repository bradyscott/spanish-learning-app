//
//  SettingsViewController.swift
//  Concurso español
//
//  Created by Scott on 22/08/2017.
//  Copyright © 2017 Scott Brady. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet var musicSwitch: UISwitch!
    @IBOutlet var numberTextField: UITextField!
    
    let numbers = ["10", "15", "20", "25", "30", "35", "40", "45", "50"]
    
    var selectedNumber: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        createNumberPicker()
    }

    func createNumberPicker() {
        
        let numberPicker = UIPickerView()
        numberPicker.delegate = self
        
        numberTextField.inputView = numberPicker
        
    }
    
}

extension SettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numbers.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return numbers[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedNumber = numbers[row]
        numberTextField.text = selectedNumber
    }
    
}
