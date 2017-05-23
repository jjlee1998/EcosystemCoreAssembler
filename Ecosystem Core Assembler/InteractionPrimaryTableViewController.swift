//
//  SpeciesManagerViewController.swift
//  Ecosystem Core Assembler
//
//  Created by Jonathan J. Lee on 5/17/17.
//  Copyright © 2017 Jonathan J. Lee. All rights reserved.
//

import UIKit
import CoreData

class InteractionPrimaryTableViewController: UITableViewController {
    
    var appDelegate: AppDelegate!
    var assemblyManager: AssemblyManager!
    
    var species: [SpeciesEntity] {return assemblyManager.species}
    
    var activeSpecies: SpeciesEntity? {
        didSet{updateDetailViewController()}
    }
    
    override func viewDidLoad() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        assemblyManager = appDelegate.assemblyManager
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PrimarySpeciesCell")
    }
    
    func updateDetailViewController() {
        performSegue(withIdentifier: "displaySpeciesTargetsSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "displaySpeciesTargetsSegue" {
            if let splitVC = segue.destination as? UISplitViewController, let navVC = splitVC.viewControllers.first as? UINavigationController, let secondaryVC = navVC.topViewController as? InteractionSecondaryTableViewController {
                secondaryVC.activeSpecies = activeSpecies
            }
        }
    }
    
    func refresh() {
        assemblyManager.save()
        self.tableView.reloadData()
        if activeSpecies != nil {
            tableView.selectRow(at: IndexPath(row: Int(species.index(of: activeSpecies!)!), section: 0), animated: true, scrollPosition: .none)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {return 1}
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return species.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nextSpecies = species[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrimarySpeciesCell", for: indexPath)
        cell.textLabel?.text = nextSpecies.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected \(species[indexPath.row].name ?? "<unknown species>")")
        activeSpecies = species[indexPath.row]
    }
    
}
