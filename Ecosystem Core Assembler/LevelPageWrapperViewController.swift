//
//  LevelPageWrapperViewController.swift
//  Ecosystem Core Assembler
//
//  Created by Jonathan J. Lee on 5/21/17.
//  Copyright © 2017 Jonathan J. Lee. All rights reserved.
//

import UIKit

class LevelPageWrapperViewController: UIViewController {
    
    @IBOutlet var levelBarTitle: UINavigationItem!
    var activeLevel: LevelEntity?
    var pageVC: LevelPageViewController!
    
    override func viewDidLoad() {
        refreshTitle()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedLevelPageVC", let pageViewController = segue.destination as? LevelPageViewController {
            pageVC = pageViewController
            pageVC.activeLevel = activeLevel
        }
    }
    
    func refreshTitle() {
        if activeLevel != nil {
            levelBarTitle.title = (activeLevel?.title ?? "Level X")
        }
    }
    
    @IBAction func scrollRight() {
        pageVC.moveRight()
    }
    
    @IBAction func scrollLeft() {
        pageVC.moveLeft()
    }
    
}
