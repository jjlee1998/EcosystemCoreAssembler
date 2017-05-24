//
//  TitleViewController.swift
//  EcoloFinal
//
//  Created by Alex Cao on 5/23/17.
//  Copyright © 2017 Alex Cao. All rights reserved.
//

import UIKit

class TitleViewController: UIViewController {
    
    @IBOutlet var gameTitle: UILabel!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var settingsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gameTitle.alpha = 0.0
        self.playButton.alpha = 0.0
        self.settingsButton.alpha = 0.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .transitionCrossDissolve, animations: {
            self.gameTitle.alpha = 1.0
        }, completion: {
            finished in

            if finished {
                UIView.animate(withDuration: 1.0, delay: 0.0, options: .transitionCrossDissolve, animations: {
                    self.playButton.alpha = 1.0
                }, completion: nil)
                UIView.animate(withDuration: 1.0, delay: 0.0, options: .transitionCrossDissolve, animations: {
                    self.settingsButton.alpha = 1.0
                }, completion: nil)
            }
        })
    }
    
    @IBAction func unwindToTitleScreen(segue: UIStoryboardSegue) {
        print("Unwind to Title Screen!")
    }
    
}
