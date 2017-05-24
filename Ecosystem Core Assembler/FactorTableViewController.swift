//
//  FactorTableViewController.swift
//  Ecosystem Core Assembler
//
//  Created by Jonathan J. Lee on 5/20/17.
//  Copyright © 2017 Jonathan J. Lee. All rights reserved.
//

import UIKit
import CoreData

class FactorTableViewController: UITableViewController {
    
    var appDelegate: AppDelegate!
    var assemblyManager: AssemblyManager!
    var detailVC: FactorDetailViewController?
    var activeEcosystem: EcosystemEntity? {
        didSet {
            tableView.reloadData()
        }
    }
    var activeFactor: FactorEntity? {
        didSet {
            performSegue(withIdentifier: "showFactorDetailSegue", sender: self)
            refresh()
        }
    }
    
    var factors: [FactorEntity] {
        if let factorEntities = activeEcosystem?.factorEntities as? Set<FactorEntity> {
            return Array(factorEntities).sorted(by: {$0.speciesEntity!.name! < $1.speciesEntity!.name!})
        } else {
            return [FactorEntity]()
        }
    }
    
    var usedSpecies: [SpeciesEntity] {
        return factors.map({$0.speciesEntity!})
    }
    
    var availableSpecies: [SpeciesEntity] {
        return assemblyManager.species.filter({!usedSpecies.contains($0)})
    }
    
    override func viewDidLoad() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        assemblyManager = appDelegate.assemblyManager
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFactorDetailSegue" {
            let detailVC = segue.destination as! FactorDetailViewController
            detailVC.activeFactor = self.activeFactor
            detailVC.factorTableVC = self
        }
    }
    
    @IBAction func newFactor(sender: UIBarButtonItem) {
        guard !availableSpecies.isEmpty else {
            let title = "No available species."
            let message = "All existing species have already been imported into the ecosystem."
            let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            ac.popoverPresentationController?.barButtonItem = sender
            present(ac, animated: true, completion: nil)
            return
        }
        guard activeEcosystem != nil else {
            print("Missing ecosystem to which to add a factor!")
            return
        }
        activeFactor = assemblyManager.createFactor(ecosystem: activeEcosystem!, species: availableSpecies.first!, level: 1.0)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return factors.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        activeFactor = factors[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let factor = factors[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "FactorCell", for: indexPath)
        cell.textLabel?.text = factor.speciesEntity?.name
        cell.detailTextLabel?.text = String(factor.level)
        return cell
    }
    
    func refresh() {
        assemblyManager.save()
        tableView.reloadData()
        if activeFactor != nil {
            tableView.selectRow(at: IndexPath(row: Int(factors.index(of: activeFactor!)!), section: 0), animated: true, scrollPosition: .none)
        }
    }
    
    @IBAction func toggleEditing(sender: UIBarButtonItem) {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            sender.title = "Edit"
        } else {
            tableView.setEditing(true, animated: true)
            sender.title = "Done"
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let title = "Delete \(factors[indexPath.row].speciesEntity!.name!)?"
            let ac = UIAlertController(title: title, message: "", preferredStyle: .actionSheet)
            ac.popoverPresentationController?.sourceView = tableView
            ac.popoverPresentationController?.sourceRect = tableView.rectForRow(at: indexPath)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            ac.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
                let factorToDelete = self.factors[indexPath.row]
                if factorToDelete == self.activeFactor {
                    self.activeFactor = nil
                }
                self.assemblyManager.delete(entity: factorToDelete)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            })
            ac.addAction(deleteAction)
            
            present(ac, animated: true, completion: nil)
        }
    }
    
}
