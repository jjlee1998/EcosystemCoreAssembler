//
//  LevelTextViewController.swift
//  Ecosystem Core Assembler
//
//  Created by Jonathan J. Lee on 5/21/17.
//  Copyright © 2017 Jonathan J. Lee. All rights reserved.
//

import UIKit

class LevelTextViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var appDelegate: AppDelegate!
    var assemblyManager: AssemblyManager!
    var activeLevel: LevelEntity?
    var ecosystems: [EcosystemEntity] {
        return assemblyManager.ecosystems.sorted(by: {$0.name! < $1.name!})
    }
    @IBOutlet var levelTitle: UITextField!
    @IBOutlet var levelSubtitle: UITextField!
    @IBOutlet var introText: UITextView!
    @IBOutlet var outroText: UITextView!
    @IBOutlet var ecosystemPicker: UIPickerView!
    @IBOutlet var imageView: UIImageView!
    var activeTextField: UITextField?
    var activeTextView: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        assemblyManager = appDelegate.assemblyManager
        updateContent()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == levelTitle && textField.text == "" {
            textField.backgroundColor = UIColor.red
            let title = "Every level needs a title!"
            let ac = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
            ac.popoverPresentationController?.sourceView = textField
            present(ac, animated: true, completion: nil)
        } else {
            switch textField {
            case levelTitle:
                activeLevel?.title = levelTitle.text
            case levelSubtitle:
                activeLevel?.subtitle = levelSubtitle.text
            default:
                break
            }
        }
        assemblyManager.save()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return false
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextView = textView
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        switch textView {
        case introText:
            activeLevel?.introText = introText.text
        case outroText:
            activeLevel?.outroText = outroText.text
        default:
            break
        }
        assemblyManager.save()
    }
    
    @IBAction func dismissKeyboard() {
        _ = activeTextField?.resignFirstResponder()
        _ = activeTextView?.resignFirstResponder()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {return 1}
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ecosystems.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "No Ecosystem Selected"
        } else {
            return ecosystems[row - 1].name
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard row > 0 else {
            activeLevel?.ecosystemEntity = nil
            imageView.image = nil
            return
        }
        activeLevel?.ecosystemEntity = ecosystems[row - 1]
        loadImage()
        assemblyManager.save()
    }
    
    func updateContent() {
        levelTitle.text = activeLevel?.title
        levelSubtitle.text = activeLevel?.subtitle
        introText.text = activeLevel?.introText
        outroText.text = activeLevel?.outroText
        if let activeEcosystem = activeLevel?.ecosystemEntity, let row = ecosystems.index(of: activeEcosystem) {
            ecosystemPicker.selectRow(row + 1, inComponent: 0, animated: true)
            loadImage()
        }
    }
    
    func loadImage() {
        if let imagePath = activeLevel?.ecosystemEntity?.imagePath {
            imageView.image = UIImage(named: imagePath)
        }
    }
}
