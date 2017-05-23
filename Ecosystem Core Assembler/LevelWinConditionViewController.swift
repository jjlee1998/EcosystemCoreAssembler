//
//  LevelWinConditionViewController.swift
//  Ecosystem Core Assembler
//
//  Created by Jonathan J. Lee on 5/21/17.
//  Copyright © 2017 Jonathan J. Lee. All rights reserved.
//

import UIKit

class LevelWinConditionTableViewController: UITableViewController {
    
    var appDelegate: AppDelegate!
    var assemblyManager: AssemblyManager!
    var activeLevel: LevelEntity?
    var activeCondition: WinConditionEntity? {
        didSet {
            performSegue(withIdentifier: "ShowConditionDetailSegue", sender: self)
            refresh()
        }
    }
    
    var winConditions: [WinConditionEntity] {
        guard let conditionSet = activeLevel?.winConditionEntities as? Set<WinConditionEntity> else {
            return [WinConditionEntity]()
        }
        return Array(conditionSet).sorted(by: {$0.factorEntity!.speciesEntity!.name! < $1.factorEntity!.speciesEntity!.name!})
    }
    
    var ecosystem: EcosystemEntity? {
        return activeLevel?.ecosystemEntity
    }
    
    var factors: [FactorEntity] {
        guard let factorSet = ecosystem?.factorEntities as? Set<FactorEntity> else {
            return [FactorEntity]()
        }
        return Array(factorSet).sorted(by: {$0.speciesEntity!.name! < $1.speciesEntity!.name!})
    }
    
    var usedFactors: [FactorEntity] {
        return winConditions.map({$0.factorEntity!})
    }
    
    var availableFactors: [FactorEntity] {
        return factors.filter({!usedFactors.contains($0)})
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        assemblyManager = appDelegate.assemblyManager
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return winConditions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WinConditionCell", for: indexPath) as! WinConditionCell
        let winCondition = winConditions[indexPath.row]
        cell.factorNameLabel.text = winCondition.factorEntity?.speciesEntity?.name
        cell.comparisonLabel.text = (winCondition.greaterThan) ? ">=" : "<="
        cell.levelLabel.text = String(winCondition.threshold)
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        activeCondition = winConditions[indexPath.row]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowConditionDetailSegue" {
            if let detailVC = segue.destination as? LevelWinConditionDetailViewController {
                detailVC.winConditionTableVC = self
                detailVC.activeCondition = activeCondition
            }
        }
    }
    
    func refresh() {
        assemblyManager.save()
        tableView.reloadData()
        if activeCondition != nil {
            tableView.selectRow(at: IndexPath(row: Int(winConditions.index(of: activeCondition!)!), section: 0), animated: true, scrollPosition: .none)
        }
    }
    
    @IBAction func newWinCondition(sender: UIBarButtonItem) {
        guard !availableFactors.isEmpty else {
            let title = "No available factors."
            let message = "All existing factors have already been imported for win conditions."
            let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            ac.popoverPresentationController?.barButtonItem = sender
            present(ac, animated: true, completion: nil)
            return
        }
        guard activeLevel != nil else {
            print("Missing ecosystem to which to add a factor!")
            return
        }
        activeCondition = assemblyManager.createWinCondition(factor: availableFactors.first!, level: activeLevel!, greaterThan: true, threshold: 1.0)
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
            
            let title = "Delete Condition?"
            let ac = UIAlertController(title: title, message: "", preferredStyle: .actionSheet)
            ac.popoverPresentationController?.sourceView = tableView
            ac.popoverPresentationController?.sourceRect = tableView.rectForRow(at: indexPath)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            ac.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
                let conditionToDelete = self.winConditions[indexPath.row]
                if conditionToDelete == self.activeCondition {
                    self.activeCondition = nil
                }
                self.assemblyManager.delete(entity: conditionToDelete)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            })
            ac.addAction(deleteAction)
            
            present(ac, animated: true, completion: nil)
        }
    }
    
}
