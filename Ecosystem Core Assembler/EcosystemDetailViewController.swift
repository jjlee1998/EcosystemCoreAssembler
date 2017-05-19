//
//  EcosystemDetailViewController.swift
//  Ecosystem Core Assembler
//
//  Created by Jonathan J. Lee on 5/17/17.
//  Copyright © 2017 Jonathan J. Lee. All rights reserved.
//

import UIKit
import CoreData

class EcosystemDetailViewController: UIViewController, UITextFieldDelegate {

    var ecosystemTableViewController: EcosystemTableViewController!
    @IBOutlet var hashValueLabel: UILabel!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var imagePathTextField: UITextField!
    @IBOutlet var eulerIntervalsTextField: UITextField!
    @IBOutlet var extinctionThresholdTextField: UITextField!
    
    var activeEcosystem: EcosystemEntity? {
        didSet {
            if activeEcosystem != nil {
                self.view.isHidden = false
            } else {
                self.view.isHidden = true
            }
        }
    }
    
    override func viewDidLoad() {
        self.view.isHidden = true
        updateText()
    }
    
    func updateText() {
        if activeEcosystem != nil {
            hashValueLabel.text = "Editing Ecosystem: " + String(activeEcosystem!.hashValue)
            nameTextField.text = activeEcosystem!.name
            imagePathTextField.text = activeEcosystem!.imagePath
            eulerIntervalsTextField.text = String(activeEcosystem!.eulerIntervals)
            extinctionThresholdTextField.text = String(activeEcosystem!.extinctionThreshold * 1000)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField {
        case eulerIntervalsTextField:
            let legalIntCharacters = Set<Character>("0123456789".characters)
            let illegalCharacters = Set<Character>(string.characters).subtracting(legalIntCharacters)
            if !illegalCharacters.isEmpty {
                return false
            }
        case extinctionThresholdTextField:
            let legalDecimalCharacters = Set<Character>("0123456789.".characters)
            let illegalCharacters = Set<Character>(string.characters).subtracting(legalDecimalCharacters)
            if !illegalCharacters.isEmpty {
                return false
            }
            if textField.text?.range(of: ".") != nil && string.range(of: ".") != nil {
                return false
            }
        default:
            break
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.backgroundColor = UIColor.white
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard(sender: self)
        return false
    }
    
    @discardableResult func checkLegalityOf(textField: UITextField) -> Bool {
        switch textField {
        case nameTextField, imagePathTextField:
            if textField.text!.characters.isEmpty {
                textField.backgroundColor = UIColor.red
                return false
            }
        case eulerIntervalsTextField:
            if Int(textField.text!) == nil {
                textField.backgroundColor = UIColor.red
                return false
            }
        case extinctionThresholdTextField:
            if Double(textField.text!) == nil {
                textField.backgroundColor = UIColor.red
                return false
            }
        default:
            break
        }
        textField.backgroundColor = UIColor.white
        return true
    }
    
    func save(textField: UITextField) {
        switch textField {
        case nameTextField:
            activeEcosystem?.name = nameTextField.text
        case imagePathTextField:
            activeEcosystem?.imagePath = imagePathTextField.text
        case eulerIntervalsTextField:
            activeEcosystem?.eulerIntervals = Int64(eulerIntervalsTextField.text!)!
        case extinctionThresholdTextField:
            activeEcosystem?.extinctionThreshold = Double(extinctionThresholdTextField.text!)! / 1000
        default:
            break
        }
        ecosystemTableViewController.refresh()
    }
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        for textField in [nameTextField, imagePathTextField, eulerIntervalsTextField, extinctionThresholdTextField] {
            if checkLegalityOf(textField: textField!) {
                save(textField: textField!)
            }
            textField?.resignFirstResponder()
        }
    }
}
