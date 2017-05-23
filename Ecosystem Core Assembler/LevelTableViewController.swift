//
//  LevelTableViewController.swift
//  Ecosystem Core Assembler
//
//  Created by Jonathan J. Lee on 5/21/17.
//  Copyright © 2017 Jonathan J. Lee. All rights reserved.
//

import UIKit
import CoreData

class LevelTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var appDelegate: AppDelegate!
    var assemblyManager: AssemblyManager!
    var activeLevel: LevelEntity? {
        didSet {
            if activeLevel != nil {
                performSegue(withIdentifier: "showLevelPageSegue", sender: self)
            }
        }
    }
    
    var levels: [LevelEntity] {
        return assemblyManager.levels.sorted(by: {$0.levelNumber < $1.levelNumber})
    }
    
    @IBAction func newLevel() {
        assemblyManager.createBlankLevel()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        assemblyManager = appDelegate.assemblyManager
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return levels.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        activeLevel = levels[indexPath.row]
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLevelPageSegue", let wrapperVC = segue.destination as? LevelPageWrapperViewController {
            wrapperVC.activeLevel = activeLevel
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LevelCell", for: indexPath)
        let level = levels[indexPath.row]
        cell.textLabel?.text = "\(level.levelNumber) – \(level.title ?? "<Unnamed Level>")"
        cell.detailTextLabel?.text = "\(level.subtitle ?? "")"
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var reorderedLevels = levels
        let levelToMove = reorderedLevels.remove(at: sourceIndexPath.row)
        reorderedLevels.insert(levelToMove, at: destinationIndexPath.row)
        recalculateLevelNumbers(levelsToCheck: reorderedLevels)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let title = "Delete Level \(levels[indexPath.row].levelNumber) - \(levels[indexPath.row].title ?? "<Unnamed Level>")?"
            let message = "This cannot be undone."
            let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            ac.popoverPresentationController?.sourceView = tableView
            ac.popoverPresentationController?.sourceRect = tableView.rectForRow(at: indexPath)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            ac.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
                let levelToDelete = self.levels[indexPath.row]
                self.assemblyManager.delete(entity: levelToDelete)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                self.recalculateLevelNumbers(levelsToCheck: self.levels)
                tableView.reloadData()
            })
            ac.addAction(deleteAction)
            
            present(ac, animated: true, completion: nil)
        }
    }
    
    func recalculateLevelNumbers(levelsToCheck: [LevelEntity]) {
        if !levelsToCheck.isEmpty {
            for levelNumber in 1...levelsToCheck.count {
                levelsToCheck[levelNumber - 1].levelNumber = Int64(levelNumber)
            }
        }
    }
    
    @IBAction func unwindToLevelTableVC(segue: UIStoryboardSegue) {
        print("Unwinding to levelVC!")
    }
    
}
