//
//  SpeciesManagerViewController.swift
//  Ecosystem Core Assembler
//
//  Created by Jonathan J. Lee on 5/17/17.
//  Copyright © 2017 Jonathan J. Lee. All rights reserved.
//

import UIKit
import CoreData

class InteractionSecondaryTableViewController: UITableViewController {
    
    // These variables are set in the viewDidLoad method.
    var appDelegate: AppDelegate!
    var assemblyManager: AssemblyManager!
    
    var species: [SpeciesEntity] {return assemblyManager.species}
    var interactions: [InteractionEntity] {return assemblyManager.interactions}
    
    // These variables are set by the interactionPrimaryTableViewController via the displaySpeciesTargetsSegue.
    // Note that this class does not contain any reference back to the interactionPrimaryTableViewController.
    // It doesn't need one – it's read-only.
    var activeSpecies: SpeciesEntity? {
        didSet {self.view.isHidden = (activeSpecies == nil)}
    }
    var targetSpecies: SpeciesEntity?
    
    override func viewDidLoad() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        assemblyManager = appDelegate.assemblyManager
        self.view.isHidden = true
    }
    
    func updateDetailViewController() {
        performSegue(withIdentifier: "displayInteractionDetailSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "displayInteractionDetailSegue" {
            if let interactionDetailVC = segue.destination as? InteractionDetailViewController {
                interactionDetailVC.interactionSecondaryTableViewController = self
                interactionDetailVC.assemblyManager = assemblyManager
                interactionDetailVC.activeSpecies = activeSpecies
                interactionDetailVC.targetSpecies = targetSpecies
            }
        }
    }
    
    func refresh() {
        assemblyManager?.save()
        self.tableView.reloadData()
        if targetSpecies != nil {
            tableView.selectRow(at: IndexPath(row: Int(species.index(of: targetSpecies!)!), section: 0), animated: true, scrollPosition: .none)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {return 1}
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return species.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SecondarySpeciesCell", for: indexPath) as! SecondarySpeciesCell
        let speciesTwo = species[indexPath.row]
        cell.nameLabel.text = speciesTwo.name
        let potentialInteractions = interactions.filter({$0.species == activeSpecies && $0.conjugateInteractionEntity?.species == speciesTwo})
        cell.interaction = (potentialInteractions.count >= 1) ? potentialInteractions.first : nil
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected \(assemblyManager?.species[indexPath.row].name ?? "<unknown species>")")
        targetSpecies = assemblyManager?.species[indexPath.row]
        updateDetailViewController()
    }
    
}
