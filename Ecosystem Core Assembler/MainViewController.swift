//
//  ViewController.swift
//  Ecosystem Core Assembler
//
//  Created by Jonathan J. Lee on 5/12/17.
//  Copyright © 2017 Jonathan J. Lee. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController {
    
    var appDelegate: AppDelegate!
    var assemblyManager: AssemblyManager!
    
    @IBAction func unwideToMain(segue: UIStoryboardSegue) {
        print("Unwinding segue back to main triggered!")
    }
    
    override func viewDidLoad() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        assemblyManager = appDelegate.assemblyManager
        //appDelegate.wipeContext()
    }
    
}

