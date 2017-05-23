//
//  EcosystemManagerViewController.swift
//  Ecosystem Core Assembler
//
//  Created by Jonathan J. Lee on 5/17/17.
//  Copyright © 2017 Jonathan J. Lee. All rights reserved.
//

import UIKit
import CoreData

class EcosystemTableViewController: UITableViewController {
    
    var appDelegate: AppDelegate!
    var assemblyManager: AssemblyManager!
    var ecosystems: [EcosystemEntity] {return assemblyManager.ecosystems}
    var activeEcosystem: EcosystemEntity? {
        didSet{updateDetailViewController()}
    }
    
    override func viewDidLoad() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        assemblyManager = appDelegate.assemblyManager
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "EcosystemCell")
    }
    
    @IBAction func newEcosystem(sender: Any) {
        // Note: the createBlankEcosystemEntity automatically adds the new EcosystemEntity to the assemblyManager's ecosystem array, so we can access it without doing any other work.
        activeEcosystem = assemblyManager.createBlankEcosystemEntity()
        refresh()
        updateDetailViewController()
    }
    
    func updateDetailViewController() {
        performSegue(withIdentifier: "displayEcosystemDetailSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "displayEcosystemDetailSegue" {
            if let detailVC = segue.destination as? EcosystemDetailViewController {
                detailVC.ecosystemTableViewController = self
                detailVC.activeEcosystem = activeEcosystem
            }
        }
    }
    
    func refresh() {
        assemblyManager.save()
        self.tableView.reloadData()
        if activeEcosystem != nil {
            tableView.selectRow(at: IndexPath(row: Int(ecosystems.index(of: activeEcosystem!)!), section: 0), animated: true, scrollPosition: .none)
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {return 1}
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ecosystems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ecosystem = ecosystems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "EcosystemCell", for: indexPath)
        cell.textLabel?.text = ecosystem.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        activeEcosystem = ecosystems[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let title = "Delete \(ecosystems[indexPath.row].name!)?"
            let message = "All factors in this ecosystem will be erased, but species and interactions will remain untouched."
            let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            ac.popoverPresentationController?.sourceView = tableView
            ac.popoverPresentationController?.sourceRect = tableView.rectForRow(at: indexPath)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            ac.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
                let ecosystemToDelete = self.ecosystems[indexPath.row]
                if ecosystemToDelete == self.activeEcosystem {
                    self.activeEcosystem = nil
                    self.updateDetailViewController()
                }
                self.assemblyManager.delete(entity: ecosystemToDelete)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            })
            ac.addAction(deleteAction)
            
            present(ac, animated: true, completion: nil)
        }
    }
    
}
