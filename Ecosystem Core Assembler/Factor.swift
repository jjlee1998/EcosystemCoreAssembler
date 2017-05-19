//
//  Created by Jonathan J. Lee on 2/28/17.
//  Copyright © 2017 Jonathan J. Lee. All rights reserved.
//

import Foundation
import CoreData

enum SpeciesType: String {
    case Producer
    case Consumer
    case Resource
}

enum MovementType: String {
    case Aerial
    case Terrestrial
    case Static
}

class Factor: CustomStringConvertible, Hashable {
    
    let cdFactor: FactorEntity
    var cdSpecies: SpeciesEntity {return cdFactor.speciesEntity!}
    
    var level: Double
    private var delta = 0.0
    var delegate: FactorDelegate
    
    var name: String {return cdSpecies.name!}
    var type: SpeciesType {return SpeciesType(rawValue: cdSpecies.type!)!}
    var movement: MovementType {return MovementType(rawValue: cdSpecies.movement!)!}
    var standardPopulationSize: Int {return Int(cdSpecies.standardPopulationSize)}
    var renderLogBase: Double {return cdSpecies.renderLogBase}
    var isPackHunter: Bool {return cdSpecies.isPackHunter}
    var imagePath: String {return cdSpecies.imagePath!}
    var hashValue: Int {return cdSpecies.hashValue}
    
    static func ==(f1: Factor, f2: Factor) -> Bool {return f1.hashValue == f2.hashValue}
    
    var description: String {
        return "\(name): lvl \(level))"
    }
    
    init(entity: FactorEntity, delegate: FactorDelegate) {
        self.cdFactor = entity
        self.level = cdFactor.level
        self.delegate = delegate
    }
    
    func exportToFactorEntity() {
        cdFactor.level = self.level
    }
    
    func calculateDelta() {
        switch type {
            case .Producer: lvProducer()
            case .Consumer: lvConsumer()
            default: break
        }
    }
    
    func addDeltaToLevel() {
        level += delta / Double(delegate.eulerIntervals)
        if level < delegate.extinctionThreshold {
            level = 0
        }
    }
    
    private func lvProducer() {
        delta = 0.0
        var carryingCapacityReduction = 0.0
        var naturalChangeRate = 0.0
        if let interactions = delegate.factors[self] {
            for (affectingFactor, effectCoefficient) in interactions {
                if affectingFactor.type == .Resource {
                    carryingCapacityReduction += effectCoefficient * self.level * affectingFactor.level
                } else if affectingFactor == self {
                    naturalChangeRate = effectCoefficient
                } else {
                    delta += effectCoefficient * self.level * affectingFactor.level
                }
            }
            delta += naturalChangeRate * self.level * (1 - carryingCapacityReduction)
        }
    }
    
    private func lvConsumer() {
        delta = 0.0
        if let interactions = delegate.factors[self] {
            for (affectingFactor, effectCoefficient) in interactions {
                delta += effectCoefficient * self.level * affectingFactor.level
            }
        }
    }
}
