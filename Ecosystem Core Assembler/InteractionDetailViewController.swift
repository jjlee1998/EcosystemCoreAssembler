//
//  SpeciesDetailViewController.swift
//  Ecosystem Core Assembler
//
//  Created by Jonathan J. Lee on 5/17/17.
//  Copyright © 2017 Jonathan J. Lee. All rights reserved.
//

import UIKit
import CoreData

class InteractionDetailViewController: UIViewController, UITextFieldDelegate {
    
    // These variables are set in the viewDidLoad method.
    var appDelegate: AppDelegate!
    var assemblyManager: AssemblyManager!
    
    var interactionSecondaryTableViewController: InteractionSecondaryTableViewController!
    
    var interaction: InteractionEntity? {
        didSet {
            if interaction == nil {
                deleteInteractionButton.title = "Interaction Does Not Exist"
                deleteInteractionButton.isEnabled = false
                deleteInteractionButton.tintColor = UIColor.blue
            } else {
                deleteInteractionButton.title = "Delete Interaction"
                deleteInteractionButton.isEnabled = true
                deleteInteractionButton.tintColor = UIColor.red
            }
        }
    }
    @IBOutlet var deleteInteractionButton: UIBarButtonItem!
    @IBOutlet var species1Label: UILabel!
    @IBOutlet var species2Label: UILabel!
    @IBOutlet var species1ImageView: UIImageView!
    @IBOutlet var species2ImageView: UIImageView!
    @IBOutlet var coeff1TextField: UITextField!
    @IBOutlet var coeff2TextField: UITextField!
    @IBOutlet var species1InteractionLabel: UILabel!
    @IBOutlet var species2InteractionLabel: UILabel!
    var activeTextField: UITextField?
    var editingSelf = false
    
    var activeSpecies: SpeciesEntity?
    var targetSpecies: SpeciesEntity? {
        didSet {
            self.view.isHidden = (targetSpecies == nil)
            let potentialInteractions = assemblyManager!.interactions.filter({$0.species == activeSpecies && $0.conjugateInteractionEntity?.species == targetSpecies})
            if potentialInteractions.count >= 1 {
                interaction = potentialInteractions.first!
            }
            editingSelf = (targetSpecies == activeSpecies)
            if editingSelf {
                species2Label.isHidden = editingSelf
                species2ImageView.isHidden = editingSelf
                coeff2TextField.isHidden = editingSelf
                species2InteractionLabel.isHidden = editingSelf
                species1InteractionLabel.text = editingSelf ? "Natural Change Constant:" : "Interaction Coefficient:"
            }
            updateText()
        }
    }
    
    @IBAction func deleteInteraction(sender: UIBarButtonItem) {
        let title = "Delete Interaction?"
        let message = "This cannot be undone."
        let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        ac.popoverPresentationController?.barButtonItem = sender
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
            self.assemblyManager?.delete(entity: self.interaction!)
            self.interaction = nil
            self.updateText()
            self.interactionSecondaryTableViewController.refresh()
        })
        ac.addAction(deleteAction)
        
        present(ac, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        assemblyManager = appDelegate.assemblyManager
        self.view.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        loadImages()
    }
    
    func updateText() {
        species1Label.text = "\(activeSpecies!.name!)"
        species2Label.text = "\(targetSpecies!.name!)"
        loadImages()
        if interaction != nil && interaction?.conjugateInteractionEntity != nil {
            coeff1TextField.text = String(interaction!.coefficient)
            coeff2TextField.text = String(interaction!.conjugateInteractionEntity!.coefficient)
        } else {
            coeff1TextField.text = ""
            coeff2TextField.text = ""
        }
    }
    
    func loadImages() {
        if let imagePathOne = activeSpecies?.imagePath, let image = UIImage(named: imagePathOne) {
            species1ImageView.image = image
        } else {
            species1ImageView.image = nil
        }
        if let imagePathTwo = targetSpecies?.imagePath, let image = UIImage(named: imagePathTwo) {
            species2ImageView.image = image
        } else {
            species2ImageView.image = nil
        }
    }
    
    
    
    
    // TEXT FIELD HANDLING
    
    var baseSplitVC: UIViewController? {
        return (self.splitViewController?.splitViewController)
    }
    
    func setViewVerticalOffset(_ offset: CGFloat) {
        var rect: CGRect = baseSplitVC!.view.frame
        rect.origin.y = -offset
        baseSplitVC?.view.frame = rect
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == coeff1TextField || textField == coeff2TextField {
            let legalDecimalCharacters = Set<Character>("-0123456789e.".characters)
            let illegalCharacters = Set<Character>(string.characters).subtracting(legalDecimalCharacters)
            if !illegalCharacters.isEmpty {
                return false
            }
            if textField.text?.range(of: ".") != nil && string.range(of: ".") != nil {
                return false
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.backgroundColor = UIColor.white
        activeTextField = textField
        if textField == coeff2TextField {
            setViewVerticalOffset(self.view.frame.height / 2)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard(sender: textField)
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if editingSelf {
            coeff2TextField.text = coeff1TextField.text
        }
        if checkLegalityOf(textField: textField) {
            if interaction == nil, let coeff1 = Double(coeff1TextField.text!), let coeff2 = Double(coeff2TextField.text!), let (newInteraction, _) = assemblyManager?.createBlankInteractionEntityPair(species1: activeSpecies!, species2: targetSpecies!, coeff1: coeff1, coeff2: coeff2) {
                interaction = newInteraction
            }
            save(sender: textField)
        }
        if (coeff1TextField.text!.isEmpty || Double(coeff1TextField.text!) == 0) && (coeff2TextField.text!.isEmpty || Double(coeff2TextField.text!) == 0) && interaction != nil {
            print("deleting")
            assemblyManager?.delete(entity: interaction!)  // Because of the cascade effect, this will also destroy the conjugate
            interactionSecondaryTableViewController.refresh()
        }
        setViewVerticalOffset(0)
    }
    
    @discardableResult func checkLegalityOf(textField: UITextField) -> Bool {
        if textField == coeff1TextField || textField == coeff2TextField {
            if Double(textField.text!) == nil {
                textField.backgroundColor = UIColor.red
                return false
            }
        }
        textField.backgroundColor = UIColor.white
        return true
    }
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        _ = activeTextField?.resignFirstResponder()
        setViewVerticalOffset(CGFloat(0.0))
        activeTextField = nil
    }
    
    @IBAction func save(sender: UIView) {
        switch sender {
        case coeff1TextField:
            interaction?.coefficient = Double(coeff1TextField.text!)!
        case coeff2TextField:
            interaction?.conjugateInteractionEntity?.coefficient = Double(coeff2TextField.text!)!
        default:
            break
        }
        interactionSecondaryTableViewController.refresh()
    }
}
