//
//  SpeciesManagerViewController.swift
//  Ecosystem Core Assembler
//
//  Created by Jonathan J. Lee on 5/17/17.
//  Copyright © 2017 Jonathan J. Lee. All rights reserved.
//

import UIKit
import CoreData

class SpeciesTableViewController: InteractionPrimaryTableViewController {
    
    override func viewDidLoad() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        assemblyManager = appDelegate.assemblyManager
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SpeciesCell")
    }
    
    @IBAction func newSpecies(sender: Any) {
        // Note: the createBlankSpeciesEntity automatically adds the new SpeciesEntity to the assemblyManager's ecosystem array, so we can access it without doing any other work.
        activeSpecies = assemblyManager.createBlankSpeciesEntity()
        refresh()
        updateDetailViewController()
    }
    
    override func updateDetailViewController() {
        performSegue(withIdentifier: "displaySpeciesDetailSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "displaySpeciesDetailSegue" {
            if let detailVC = segue.destination as? SpeciesDetailViewController {
                detailVC.speciesTableViewController = self
                detailVC.activeSpecies = activeSpecies
            }
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
        print("Toggling editing")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nextSpecies = species[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpeciesCell", for: indexPath)
        cell.textLabel?.text = nextSpecies.name
        return cell
    }

    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let title = "Delete \(species[indexPath.row].name!)?"
            let message = "This species' factors will be removed from all ecosystems, and its interactions with other species will be erased."
            let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            ac.popoverPresentationController?.sourceView = tableView
            ac.popoverPresentationController?.sourceRect = tableView.rectForRow(at: indexPath)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            ac.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
                let speciesToDelete = self.species[indexPath.row]
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
