//
//  LevelPageViewController.swift
//  Ecosystem Core Assembler
//
//  Created by Jonathan J. Lee on 5/21/17.
//  Copyright © 2017 Jonathan J. Lee. All rights reserved.
//

import UIKit

class LevelPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    var activeLevel: LevelEntity?
    
    var pages = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        if let textVC = storyboard?.instantiateViewController(withIdentifier: "LevelTextViewController") as? LevelTextViewController, let domainVC = storyboard?.instantiateViewController(withIdentifier: "LevelDomainViewController") as? LevelDomainViewController, let splitVC = storyboard?.instantiateViewController(withIdentifier: "LevelWinConditionViewController") as? UISplitViewController, let navVC = splitVC.viewControllers.first as? UINavigationController, let winVC = navVC.topViewController as? LevelWinConditionTableViewController {
            print("Pages Created")
            textVC.activeLevel = activeLevel
            domainVC.activeLevel = activeLevel
            winVC.activeLevel = activeLevel
            pages = [textVC, domainVC, splitVC]
            setViewControllers([textVC], direction: .forward, animated: true, completion: nil)
            for view in self.view.subviews {
                if let scrollView = view as? UIScrollView {
                    scrollView.isScrollEnabled = false
                }
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.index(of: viewController)!
        let previousIndex = currentIndex - 1
        return (previousIndex >= 0) ? pages[previousIndex] : nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.index(of: viewController)!
        let nextIndex = currentIndex + 1
        return (nextIndex <= 2) ? pages[nextIndex] : nil
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func moveRight() {
        if let currentVC = self.viewControllers?[0], let nextVC = pageViewController(self, viewControllerAfter: currentVC) {
            setViewControllers([nextVC], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func moveLeft() {
        if let currentVC = self.viewControllers?[0], let nextVC = pageViewController(self, viewControllerBefore: currentVC) {
            setViewControllers([nextVC], direction: .reverse, animated: true, completion: nil)
        }
    }
}
