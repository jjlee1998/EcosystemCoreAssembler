//
//  Level.swift
//  EcoloFinal
//
//  Created by Jonathan J. Lee on 5/23/17.
//  Copyright © 2017 Alex Cao. All rights reserved.
//

import UIKit
import CoreData

class LevelSelectionViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var appDelegate: AppDelegate!
    var assemblyManager: AssemblyManager!
    var levels: [LevelEntity] {
        return assemblyManager.levels.sorted(by: {$0.levelNumber < $1.levelNumber})
    }
    var pages: [UIViewController]!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        assemblyManager = appDelegate.assemblyManager!
        print("\(levels.count) Levels Detected.")
        pages = levels.map({createDisplayFor(level: $0)})
            .filter({$0 != nil})
            .map({$0!})
        print("\(pages.count) Pages Created")
        guard !pages.isEmpty else {
            return
        }
        setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.index(of: viewController) else {
            return nil
        }
        let nextIndex = currentIndex + 1
        return (nextIndex < pages.count) ? pages[nextIndex] : nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.index(of: viewController) else {
            return nil
        }
        let previousIndex = currentIndex - 1
        return (previousIndex >= 0) ? pages[previousIndex] : nil
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func createDisplayFor(level: LevelEntity) -> LevelDisplayViewController? {
        if let displayVC = storyboard?.instantiateViewController(withIdentifier: "LevelDisplayViewController") as? LevelDisplayViewController {
            displayVC.level = level
            return displayVC
        } else {
            return nil
        }
    }
    
}
