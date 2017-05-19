//
//  SpeciesDetailViewController.swift
//  Ecosystem Core Assembler
//
//  Created by Jonathan J. Lee on 5/17/17.
//  Copyright © 2017 Jonathan J. Lee. All rights reserved.
//

import UIKit
import CoreData

class SpeciesDetailViewController: UIViewController, UITextFieldDelegate {
    
    var speciesTableViewController: SpeciesTableViewController!
    @IBOutlet var hashValueLabel: UILabel!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var imagePathTextField: UITextField!
    @IBOutlet var typeControl: UISegmentedControl!
    @IBOutlet var movementControl: UISegmentedControl!
    @IBOutlet var standardPopulationSizeTextField: UITextField!
    @IBOutlet var renderLogBaseTextField: UITextField!
    @IBOutlet var packBehaviorLabel: UILabel!
    @IBOutlet var packBehaviorSwitch: UISwitch!
    @IBOutlet var imageView: UIImageView!
    
    var activeSpecies: SpeciesEntity? {
        didSet {
            if activeSpecies != nil {
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
        if activeSpecies != nil {
            hashValueLabel.text = "Editing Species: " + String(activeSpecies!.hashValue)
            nameTextField.text = activeSpecies!.name
            imagePathTextField.text = activeSpecies!.imagePath
            switch activeSpecies!.type! {
            case "Resource": typeControl.selectedSegmentIndex = 0
            case "Producer": typeControl.selectedSegmentIndex = 1
            case "Consumer": typeControl.selectedSegmentIndex = 2
            default: typeControl.selectedSegmentIndex = -1
            }
            switch activeSpecies!.movement! {
            case "Static": movementControl.selectedSegmentIndex = 0
            case "Terrestrial": movementControl.selectedSegmentIndex = 1
            case "Aerial": movementControl.selectedSegmentIndex = 2
            default: typeControl.selectedSegmentIndex = -1
            }
            standardPopulationSizeTextField.text = String(activeSpecies!.standardPopulationSize)
            renderLogBaseTextField.text = String(activeSpecies!.renderLogBase)
            if activeSpecies!.isPackHunter {
                packBehaviorSwitch.setOn(true, animated: true)
            } else {
                packBehaviorSwitch.setOn(false, animated: true)
            }
            updatePackBehaviorLabel()
            loadImage(sender: self)
        }
    }
    
    @IBAction func updatePackBehaviorLabel() {
        if packBehaviorSwitch.isOn {
            packBehaviorLabel.textColor = UIColor.black
            packBehaviorLabel.text = "Species Obeys Pack Behavior"
        } else {
            packBehaviorLabel.textColor = UIColor.gray
            packBehaviorLabel.text = "Species Does Not Obey Pack Behavior"
        }
    }
    
    @IBAction func loadImage(sender: Any) {
        if let image = UIImage(named: imagePathTextField.text!) {
            imageView.image = image
        } else {
            imageView.image = nil
        }

    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField {
        case standardPopulationSizeTextField:
            let legalIntCharacters = Set<Character>("0123456789".characters)
            let illegalCharacters = Set<Character>(string.characters).subtracting(legalIntCharacters)
            if !illegalCharacters.isEmpty {
                return false
            }
        case renderLogBaseTextField:
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
        case standardPopulationSizeTextField:
            if Int(textField.text!) == nil {
                textField.backgroundColor = UIColor.red
                return false
            }
        case renderLogBaseTextField:
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
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        for textField in [nameTextField, imagePathTextField, standardPopulationSizeTextField, renderLogBaseTextField] {
            if checkLegalityOf(textField: textField!) {
                save(textField: textField!)
            }
            textField?.resignFirstResponder()
        }
    }
    
    func save(textField: UITextField) {
        switch textField {
        case nameTextField:
            activeSpecies?.name = nameTextField.text
        case imagePathTextField:
            activeSpecies?.imagePath = imagePathTextField.text
        case standardPopulationSizeTextField:
            activeSpecies?.standardPopulationSize = Int64(standardPopulationSizeTextField.text!)!
        case renderLogBaseTextField:
            activeSpecies?.renderLogBase = Double(renderLogBaseTextField.text!)! / 1000
        default:
            break
        }
        speciesTableViewController.refresh()
    }
}
