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
        executeTasks()
    }
    
    func executeTasks() {
        //appDelegate.wipeContext()
        
        //assemblyManager.createEcosystemEntity(name: "Desert Ecosystem", eulerIntervals: 100, extinctionThreshold: 1e-3, imagePath: "imagePathFake")
        /*assemblyManager.createNewSpecies(name: "Grey Wolf", type: .Consumer, movement: .Terrestrial, standardPopulationSize: 4, renderLogBase: 2.0, isPackHunter: true, imagePath: "wolfPath")
        assemblyManager.createNewSpecies(name: "Arctic Hare", type: .Consumer, movement: .Terrestrial, standardPopulationSize: 6, renderLogBase: 2.5, isPackHunter: false, imagePath: "harePath")
        assemblyManager.createNewSpecies(name: "Arctic Wildflower", type: .Producer, movement: .Static, standardPopulationSize: 10, renderLogBase: 3.0, isPackHunter: true, imagePath: "wildflowerPath")*/
        
        //assemblyManager.printEntityDiagnostics()
        //print(assemblyManager.directorateEntity.speciesEntities as! Set<SpeciesEntity>)
        //assemblyManager.printEntityDiagnostics()
        
    }
    
}

