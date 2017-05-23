//
//  SpeciesDetailViewController.swift
//  Ecosystem Core Assembler
//
//  Created by Jonathan J. Lee on 5/17/17.
//  Copyright © 2017 Jonathan J. Lee. All rights reserved.
//

import UIKit
import CoreData

class SpeciesDetailViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // These variables are set in the viewDidLoad method.
    var appDelegate: AppDelegate!
    var assemblyManager: AssemblyManager!
    
    var imagePaths: [String] {return assemblyManager.imageNames}
    
    // These variables are set by the speciesTableViewController via the displaySpeciesDetailSegue.
    var speciesTableViewController: SpeciesTableViewController!
    var activeSpecies: SpeciesEntity? {
        didSet {self.view.isHidden = (activeSpecies == nil)}
    }
    
    @IBOutlet var hashValueLabel: UILabel!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var imagePathPicker: UIPickerView!
    @IBOutlet var typeControl: UISegmentedControl!
    @IBOutlet var movementControl: UISegmentedControl!
    @IBOutlet var standardPopulationSizeTextField: UITextField!
    @IBOutlet var renderLogBaseTextField: UITextField!
    @IBOutlet var packBehaviorLabel: UILabel!
    @IBOutlet var packBehaviorSwitch: UISwitch!
    @IBOutlet var imageView: UIImageView!
    var activeTextField: UITextField?
    

    
    override func viewDidLoad() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        assemblyManager = appDelegate.assemblyManager
        self.view.isHidden = true
        updateText()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let imagePath = activeSpecies?.imagePath, let targetRow = assemblyManager.imageNames.index(of: imagePath) {
            imagePathPicker.selectRow(targetRow + 1, inComponent: 0, animated: true)
            loadImage()
        }
    }
    
    @IBAction func save(sender: UIView) {
        switch sender {
        case nameTextField:
            activeSpecies?.name = nameTextField.text
        case imagePathPicker:
            if let imagePath = getCurrentImagePath() {
                activeSpecies?.imagePath = imagePath
            }
        case typeControl:
            switch typeControl.selectedSegmentIndex {
            case 0: activeSpecies?.type = "Resource"
            case 1: activeSpecies?.type = "Producer"
            default: activeSpecies?.type = "Consumer"
            }
        case movementControl:
            switch movementControl.selectedSegmentIndex {
            case 1: activeSpecies?.movement = "Terrestrial"
            case 2: activeSpecies?.movement = "Aerial"
            default: activeSpecies?.movement = "Static"
            }
        case standardPopulationSizeTextField:
            activeSpecies?.standardPopulationSize = Int64(standardPopulationSizeTextField.text!)!
        case renderLogBaseTextField:
            activeSpecies?.renderLogBase = Double(renderLogBaseTextField.text!)!
        case packBehaviorSwitch:
            activeSpecies?.isPackHunter = packBehaviorSwitch.isOn
        default:
            break
        }
        speciesTableViewController.refresh()
    }
    
    
    // PICKER VIEW AND IMAGE HANDLING >>>>>>>>>>>>>>>>>>>>>
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let rows = assemblyManager?.imageNames.count {
            return rows + 1
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "No Image Selected"
        } else {
            return assemblyManager?.imageNames[row - 1]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        loadImage()
        save(sender: pickerView)
    }
    
    func loadImage() {
        if let imagePath = getCurrentImagePath(), let image = UIImage(named: imagePath) {
            imageView.image = image
        } else {
            imageView.image = nil
        }
    }
    
    func getCurrentImagePath() -> String? {
        let imageRow = imagePathPicker.selectedRow(inComponent: 0) - 1
        guard imageRow >= 0 else {
            return nil
        }
        return imagePaths[imageRow]
    }
    
    
    // TEXT HANDLING >>>>>>>>>>>>>>>>>>    
    
    func updateText() {
        if activeSpecies != nil {
            hashValueLabel.text = "Editing Species: " + String(activeSpecies!.hashValue)
            nameTextField.text = activeSpecies!.name
            
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
            packBehaviorSwitch.setOn(activeSpecies!.isPackHunter, animated: true)
            updatePackBehaviorLabel()
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var legalCharacters = CharacterSet()
        switch textField {
        case nameTextField:
            legalCharacters = CharacterSet.alphanumerics.union(CharacterSet.whitespaces)
        case standardPopulationSizeTextField:
            legalCharacters = CharacterSet(charactersIn: "0123456789")
        case renderLogBaseTextField:
            legalCharacters = CharacterSet(charactersIn: "0123456789.")
            if textField.text?.range(of: ".") != nil && string.range(of: ".") != nil {return false}
        default:
            break
        }
        let illegalCharacters = CharacterSet(charactersIn: string).subtracting(legalCharacters)
        return illegalCharacters.isEmpty
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.backgroundColor = UIColor.white
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if checkLegalityOf(textField: textField) {
            save(sender: textField)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard(sender: textField)
        return false
    }
    
    @discardableResult func checkLegalityOf(textField: UITextField) -> Bool {
        var textFieldIsLegal = true
        switch textField {
        case nameTextField:
            textFieldIsLegal = (textField.text! != "")
        case standardPopulationSizeTextField:
            textFieldIsLegal = (Int(textField.text!) != nil)
        case renderLogBaseTextField:
            textFieldIsLegal = (Double(textField.text!) != nil)
        default:
            break
        }
        textField.backgroundColor = (textFieldIsLegal ? UIColor.white : UIColor.red)
        return textFieldIsLegal
    }
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        _ = activeTextField?.resignFirstResponder()
        activeTextField = nil
    }
    
}
