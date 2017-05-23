//
//  SecondarySpeciesCell.swift
//  Ecosystem Core Assembler
//
//  Created by Jonathan J. Lee on 5/19/17.
//  Copyright © 2017 Jonathan J. Lee. All rights reserved.
//

import UIKit

class SecondarySpeciesCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var effectLabel: UILabel!
    
    var interaction: InteractionEntity? {
        didSet {
            self.backgroundColor = cellColor()
            self.nameLabel.backgroundColor = UIColor.clear
            self.effectLabel.backgroundColor = UIColor.clear
            self.effectLabel.text = effectText()
        }
    }
    
    func cellColor() -> UIColor {
        guard let realInteraction = interaction else {
            return UIColor.white
        }
        switch realInteraction {
        case _ where realInteraction.coefficient > 0:
            return UIColor.green
        case _ where realInteraction.coefficient < 0:
            return UIColor.red
        default: //i.e., equals 0
            return UIColor.gray
        }
    }
    
    func effectText() -> String? {
        guard let realInteraction = interaction else {
            return nil
        }
        switch realInteraction {
        case _ where realInteraction.species == realInteraction.conjugateInteractionEntity?.species:
            return (realInteraction.coefficient > 0) ? "Natural Growth Rate" : "Natural Dieoff Rate"
        case _ where realInteraction.coefficient > 0 && realInteraction.conjugateInteractionEntity!.coefficient < 0:
            return "Positive Effect – Predation"
        case _ where realInteraction.coefficient < 0 && realInteraction.conjugateInteractionEntity!.coefficient > 0:
            return "Negative Effect – Predation"
        case _ where realInteraction.coefficient > 0 && realInteraction.conjugateInteractionEntity!.coefficient == 0:
            return "Positive Effect - Commensalism"
        case _ where realInteraction.coefficient == 0 && realInteraction.conjugateInteractionEntity!.coefficient > 0:
            return "Neutral Effect – Commensalism"
        case _ where realInteraction.coefficient < 0 && realInteraction.conjugateInteractionEntity!.coefficient == 0:
            return "Negative Effect – Amensalism"
        case _ where realInteraction.coefficient == 0 && realInteraction.conjugateInteractionEntity!.coefficient < 0:
            return "Neutral Effect – Amensalism"
        case _ where realInteraction.coefficient < 0 && realInteraction.conjugateInteractionEntity!.coefficient < 0:
            return "Negative Effect – Competition"
        case _ where realInteraction.coefficient > 0 && realInteraction.conjugateInteractionEntity!.coefficient > 0:
            return "Positive Effect – Mutualism"
        default:
            return nil
        }
    }
}
