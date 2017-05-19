//
//  SpeciesManagerViewController.swift
//  Ecosystem Core Assembler
//
//  Created by Jonathan J. Lee on 5/17/17.
//  Copyright © 2017 Jonathan J. Lee. All rights reserved.
//

import UIKit
import CoreData

class SpeciesTableViewController: UITableViewController {
    
    var appDelegate: AppDelegate!
    var assemblyManager: AssemblyManager!
    var activeSpecies: SpeciesEntity?
    
    override func viewDidLoad() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        assemblyManager = appDelegate.assemblyManager
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SpeciesCell")
    }
    
    @IBAction func toggleEditing(sender: UIBarButtonItem) {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            sender.title = "Edit"
        } else {
            tableView.setEditing(true, animated: true)
            sender.title = "Done"
        }
        print("Toggling editing")
    }
    
    @IBAction func newSpecies(sender: Any) {
        activeSpecies = assemblyManager.createBlankSpeciesEntity()
        refresh()
        updateDetailViewController()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {return 1}
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assemblyManager.species.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let species = assemblyManager.species[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpeciesCell", for: indexPath)
        cell.textLabel?.text = species.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected \(assemblyManager.species[indexPath.row].name ?? "<unknown species>")")
        activeSpecies = assemblyManager.species[indexPath.row]
        updateDetailViewController()
    }
    
    func updateDetailViewController() {
        performSegue(withIdentifier: "displaySpeciesDetailSegue", sender: self)
        print("Attempting to update detail view controller")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "displaySpeciesDetailSegue" {
            if let detailVC = segue.destination as? SpeciesDetailViewController {
                detailVC.speciesTableViewController = self
                detailVC.activeSpecies = activeSpecies
            }
        }
    }
    
    func refresh() {
        assemblyManager.save()
        self.tableView.reloadData()
        tableView.selectRow(at: IndexPath(row: Int(assemblyManager.species.index(of: activeSpecies!)!), section: 0), animated: true, scrollPosition: .none)
        print("Refresh!")
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let title = "Delete \(assemblyManager.species[indexPath.row].name!)?"
            let message = "This species' factors will be removed from all ecosystems, and its interactions with other species will be erased."
            let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            ac.popoverPresentationController?.sourceView = tableView
            ac.popoverPresentationController?.sourceRect = tableView.rectForRow(at: indexPath)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            ac.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
                let speciesToDelete = self.assemblyManager.species[indexPath.row]
                if speciesToDelete == self.activeSpecies {
                    self.activeSpecies = nil
                    self.updateDetailViewController()
                }
                self.assemblyManager.delete(entity: speciesToDelete)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            })
            ac.addAction(deleteAction)
            
            present(ac, animated: true, completion: nil)
        }
    }
    
}
