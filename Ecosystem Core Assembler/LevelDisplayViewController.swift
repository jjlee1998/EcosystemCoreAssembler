//
//  LevelDisplayViewController.swift
//  Ecosystem Core Assembler
//
//  Created by Jonathan J. Lee on 5/23/17.
//  Copyright © 2017 Jonathan J. Lee. All rights reserved.
//

import UIKit

class LevelDisplayViewController: UIViewController {
    
    var level: LevelEntity?
    
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var levelNumberLabel: UILabel!
    @IBOutlet var levelTitleLabel: UILabel!
    @IBOutlet var levelSubtitleLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        guard level != nil else {
            return
        }
        if let imagePath = level?.ecosystemEntity?.imagePath {
            backgroundImageView.image = UIImage(named: imagePath)
        }
        levelNumberLabel.text = "Level " + String(level!.levelNumber)
        levelTitleLabel.text = level!.title!.uppercased()
        levelSubtitleLabel.text = level!.subtitle
    }
    
    @IBAction func launchLevel(sender: Any) {
        performSegue(withIdentifier: "LaunchLevelSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LaunchLevelSegue", let ecosystemVC = segue.destination as? EcosystemViewController, level != nil {
            ecosystemVC.level = Level(level: level!)
        }
    }
    
}
