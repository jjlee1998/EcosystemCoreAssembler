//
//  FactorDetailViewController.swift
//  Ecosystem Core Assembler
//
//  Created by Jonathan J. Lee on 5/20/17.
//  Copyright © 2017 Jonathan J. Lee. All rights reserved.
//

import UIKit

class FactorDetailViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var hashValueLabel: UILabel!
    @IBOutlet var speciesPickerView: UIPickerView!
    @IBOutlet var levelTextField: UITextField!
    
    var factorTableVC: FactorTableViewController?
    var availableSpecies = [SpeciesEntity]()
    var activeFactor: FactorEntity? {
        didSet {
            view.isHidden = (activeFactor == nil)
        }
    }
    
    override func viewDidLoad() {
        self.view.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        availableSpecies = (factorTableVC == nil) ? [SpeciesEntity]() : factorTableVC!.availableSpecies
        if let currentSpecies = activeFactor?.speciesEntity {
            availableSpecies.append(currentSpecies)
        }
        speciesPickerView.reloadComponent(0)
        updateContent()
    }
    
    func updateContent() {
        if activeFactor != nil {
            hashValueLabel.text = "Factor: \(activeFactor!.hashValue)"
            speciesPickerView.selectRow(Int(availableSpecies.index(of: activeFactor!.speciesEntity!)!), inComponent: 0, animated: true)
            levelTextField.text = String(activeFactor!.level)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {return 1}
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return availableSpecies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return availableSpecies[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        activeFactor?.speciesEntity = availableSpecies[row]
        factorTableVC?.refresh()
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == levelTextField {
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
            activeFactor?.level = Double(levelTextField.text!)!
            factorTableVC?.refresh()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard(sender: textField)
        return false
    }
    
    @discardableResult func checkLegalityOf(textField: UITextField) -> Bool {
        var textFieldIsLegal = true
        if textField == levelTextField {
            textFieldIsLegal = (Double(textField.text!) != nil)
        }
        textField.backgroundColor = (textFieldIsLegal ? UIColor.white : UIColor.red)
        return textFieldIsLegal
    }
    
    @IBAction func dismissKeyboard(sender: Any) {
        _ = levelTextField.resignFirstResponder()
    }
    
}
