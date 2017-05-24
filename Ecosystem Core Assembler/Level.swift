//
//  Level.swift
//  Ecosystem Core Assembler
//
//  Created by Jonathan J. Lee on 5/23/17.
//  Copyright © 2017 Jonathan J. Lee. All rights reserved.
//

import Foundation
import CoreData

class Level {
    
    let cdLevel: LevelEntity
    var ecosystem: Ecosystem
    var levelTitle: String {return cdLevel.title!}
    var levelSubtitle: String {return cdLevel.subtitle!}
    var levelNumber: Int {return Int(cdLevel.levelNumber)}
    var introText: String {return cdLevel.introText!}
    var outroText: String {return cdLevel.outroText!}
    var sunLocation: RelativePoint? {return cdLevel.sunLocation as? RelativePoint}
    var temperature: Bool {return cdLevel.temperature}
    var rain: Bool {return cdLevel.rain}
    var airDomain: RelativeRect? {return cdLevel.air as? RelativeRect}
    var earthDomain: RelativeRect? {return cdLevel.earth as? RelativeRect}
    var waterDomain: RelativeRect? {return cdLevel.water as? RelativeRect}
    var winConditions: [WinConditionEntity]? {
        if let conditionSet = cdLevel.winConditionEntities as? Set<WinConditionEntity> {
            return Array(conditionSet)
        } else {
            return nil
        }
    }
    
    init(level: LevelEntity) {
        self.cdLevel = level
        self.ecosystem = Ecosystem(entity: level.ecosystemEntity!)
    }
    
}
