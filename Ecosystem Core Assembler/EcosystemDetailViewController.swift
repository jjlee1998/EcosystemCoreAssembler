//
//  EcosystemDetailViewController.swift
//  Ecosystem Core Assembler
//
//  Created by Jonathan J. Lee on 5/17/17.
//  Copyright © 2017 Jonathan J. Lee. All rights reserved.
//

import UIKit
import CoreData

class EcosystemDetailViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // These variables are set in the viewDidLoad method.
    var appDelegate: AppDelegate!
    var assemblyManager: AssemblyManager!
    
    var imagePaths: [String] {return assemblyManager.imageNames}

    // These variables are set by the ecosystemTableViewController via the displayEcosystemDetailSegue.
    var ecosystemTableViewController: EcosystemTableViewController!
    var activeEcosystem: EcosystemEntity? {
        didSet {
            self.view.isHidden = (activeEcosystem == nil)
            factorTableViewController?.activeEcosystem = activeEcosystem
        }
    }
    
    var factorTableViewController: FactorTableViewController?
    
    @IBOutlet var hashValueLabel: UILabel!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var imagePathPicker: UIPickerView!
    @IBOutlet var eulerIntervalsTextField: UITextField!
    @IBOutlet var extinctionThresholdTextField: UITextField!
    @IBOutlet var imageView: UIImageView!
    var activeTextField: UITextField?
    
    override func viewDidLoad() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        assemblyManager = appDelegate.assemblyManager
        self.view.isHidden = true
        updateText()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let imagePath = activeEcosystem?.imagePath, let targetRow = imagePaths.index(of: imagePath) {
            imagePathPicker.selectRow(targetRow + 1, inComponent: 0, animated: true)
            loadImage()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedFactorSplitView", let splitVC = segue.destination as? UISplitViewController, let navVC = splitVC.viewControllers.first as? UINavigationController, let factorTableVC = navVC.topViewController as? FactorTableViewController {
            self.factorTableViewController = factorTableVC
        }
    }
    
    @IBAction func save(sender: UIView) {
        switch sender {
        case nameTextField:
            activeEcosystem?.name = nameTextField.text
        case imagePathPicker:
            if let imagePath = getCurrentImagePath() {
                activeEcosystem?.imagePath = imagePath
            }
        case eulerIntervalsTextField:
            activeEcosystem?.eulerIntervals = Int64(eulerIntervalsTextField.text!)!
        case extinctionThresholdTextField:
            activeEcosystem?.extinctionThreshold = Double(extinctionThresholdTextField.text!)! / 1000
        default:
            break
        }
        ecosystemTableViewController.refresh()
    }
    
    // PICKER VIEW AND IMAGE HANDLING >>>>>>>>>>>>>>>>>>>>>
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {return 1}
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return imagePaths.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "No Image Selected"
        } else {
            return imagePaths[row - 1]
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
        if activeEcosystem != nil {
            hashValueLabel.text = "Editing Ecosystem: " + String(activeEcosystem!.hashValue)
            nameTextField.text = activeEcosystem!.name
            eulerIntervalsTextField.text = String(activeEcosystem!.eulerIntervals)
            extinctionThresholdTextField.text = String(activeEcosystem!.extinctionThreshold * 1000)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var legalCharacters = CharacterSet()
        switch textField {
        case nameTextField:
            legalCharacters = CharacterSet.alphanumerics.union(CharacterSet.whitespaces)
        case eulerIntervalsTextField:
            legalCharacters = CharacterSet(charactersIn: "0123456789")
        case extinctionThresholdTextField:
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
        dismissKeyboard(sender: self)
        return false
    }
    
    @discardableResult func checkLegalityOf(textField: UITextField) -> Bool {
        var textFieldIsLegal = true
        switch textField {
        case nameTextField:
            textFieldIsLegal = (textField.text! != "")
        case eulerIntervalsTextField:
            textFieldIsLegal = (Int(textField.text!) != nil)
        case extinctionThresholdTextField:
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
