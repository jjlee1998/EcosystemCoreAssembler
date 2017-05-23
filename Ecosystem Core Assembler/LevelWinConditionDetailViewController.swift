//
//  LevelWinConditionDetailViewController.swift
//  Ecosystem Core Assembler
//
//  Created by Jonathan J. Lee on 5/22/17.
//  Copyright © 2017 Jonathan J. Lee. All rights reserved.
//

import UIKit

class LevelWinConditionDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet var factorPicker: UIPickerView!
    @IBOutlet var comparisonPicker: UIPickerView!
    @IBOutlet var thresholdTextField: UITextField!
    
    var winConditionTableVC: LevelWinConditionTableViewController?
    var appDelegate: AppDelegate!
    var assemblyManager: AssemblyManager!
    //var activeLevel: LevelEntity?
    var activeCondition: WinConditionEntity? {
        didSet {
            view.isHidden = (activeCondition == nil)
        }
    }
    
    override func viewDidLoad() {
        self.view.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateContent()
    }
    
    var availableFactors = [FactorEntity]()

    func updateContent() {
        availableFactors = (winConditionTableVC != nil) ? winConditionTableVC!.availableFactors : [FactorEntity]()
        if let currentFactor = activeCondition?.factorEntity {
            availableFactors.insert(currentFactor, at: 0)
        }
        factorPicker.reloadComponent(0)
        if activeCondition != nil {
            factorPicker.selectRow(Int(availableFactors.index(of: activeCondition!.factorEntity!)!), inComponent: 0, animated: true)
            comparisonPicker.selectRow((activeCondition!.greaterThan ? 0 : 1), inComponent: 0, animated: true)
            thresholdTextField.text = String(activeCondition!.threshold)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == factorPicker {
            return availableFactors.count
        } else {
            return 2
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == factorPicker {
            return availableFactors[row].speciesEntity?.name
        } else {
            return [">=", "<="][row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == factorPicker {
            activeCondition?.factorEntity = availableFactors[row]
        } else {
            activeCondition?.greaterThan = (row == 0)
        }
        winConditionTableVC?.refresh()
        pickerView.reloadComponent(0)
    }
    
    
    ///////
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == thresholdTextField {
            let legalCharacters = CharacterSet(charactersIn: "0123456789.")
            let illegalCharacters = CharacterSet(charactersIn: string).subtracting(legalCharacters)
            if textField.text?.range(of: ".") != nil && string.range(of: ".") != nil {return false}
            return illegalCharacters.isEmpty
        } else {
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.backgroundColor = UIColor.white
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if checkLegalityOf(textField: textField) {
            activeCondition?.threshold = Double(thresholdTextField.text!)!
            winConditionTableVC?.refresh()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard(sender: textField)
        return false
    }
    
    @discardableResult func checkLegalityOf(textField: UITextField) -> Bool {
        var textFieldIsLegal = true
        if textField == thresholdTextField {
            textFieldIsLegal = (Double(textField.text!) != nil)
        }
        textField.backgroundColor = (textFieldIsLegal ? UIColor.white : UIColor.red)
        return textFieldIsLegal
    }
    
    @IBAction func dismissKeyboard(sender: Any) {
        _ = thresholdTextField.resignFirstResponder()
    }
    
    
}
