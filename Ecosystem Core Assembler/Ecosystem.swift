//
//  Ecosystem.swift
//  Ecolo Model Testing
//
//  Created by Jonathan J. Lee on 4/26/17.
//  Copyright © 2017 Jonathan J. Lee. All rights reserved.
//

import Foundation
import CoreData

protocol FactorDelegate {
    var eulerIntervals: Int {get}
    var extinctionThreshold: Double {get}
    var factors: [Factor: [Factor: Double]] {get}
}

class Ecosystem: CustomStringConvertible, FactorDelegate {
    
    let cdEcosystem: EcosystemEntity
    var name: String {return cdEcosystem.name!}
    var eulerIntervals: Int {return Int(cdEcosystem.eulerIntervals)}
    var extinctionThreshold: Double {return cdEcosystem.extinctionThreshold}
    var imagePath: String {return cdEcosystem.imagePath!}
    var factors = [Factor: [Factor: Double]]()
    
    init(entity: EcosystemEntity) {
        self.cdEcosystem = entity
        let factorEntities = entity.factorEntities as! Set<FactorEntity>
        for factorEntity in factorEntities {
            self.load(factorEntity: factorEntity)
        }
    }
    
    func exportToEcosystemEntity() {
        for (factor, _) in factors {
            factor.exportToFactorEntity()
        }
    }
    
    func addFactor(species: SpeciesEntity, level: Double) {
        let newFactorEntity = FactorEntity(context: cdEcosystem.managedObjectContext!)
        newFactorEntity.speciesEntity = species
        newFactorEntity.level = level
        newFactorEntity.directorateEntity = species.directorateEntity
        cdEcosystem.addToFactorEntities(newFactorEntity)
        load(factorEntity: newFactorEntity)
    }
    
    func load(factorEntity: FactorEntity) {
        let newFactor: Factor = Factor(entity: factorEntity, delegate: self)
        let newFactorInteractionEntities = newFactor.cdSpecies.interactionEntities as! Set<InteractionEntity>
        factors[newFactor] = [:]
        for (existingFactor, _) in factors {
            for interactionEntity in newFactorInteractionEntities.filter({$0.conjugateInteractionEntity!.species! == existingFactor.cdSpecies}) {
                factors[newFactor]![existingFactor] = interactionEntity.coefficient
                factors[existingFactor]![newFactor] = interactionEntity.conjugateInteractionEntity!.coefficient
            }
        }
    }
    
    func evolveEcosystem() {
        for _ in 0 ..< eulerIntervals {
            for (factor, _) in factors {
                factor.calculateDelta()
            }
            for (factor, _) in factors {
                factor.addDeltaToLevel()
            }
        }
    }
    
    func getSunlight() -> Factor? {
        var sunlight: Factor? = nil
        for (factor, _) in factors {
            if factor.name == "Sunlight" {
                sunlight = factor
            }
        }
        return sunlight
    }
    
    func getRainfall() -> Factor? {
        var rainfall: Factor? = nil
        for (factor, _) in factors {
            if factor.name == "Rainfall" {
                rainfall = factor
            }
        }
        return rainfall
    }
    
    func getTemperature() -> Factor? {
        var temperature: Factor? = nil
        for (factor, _) in factors {
            if factor.name == "Temperature" {
                temperature = factor
            }
        }
        return temperature
    }
    
    var description: String {return name}
    var currentState: String {return factors.reduce("", {$0 + "\t \($1.0.name): \($1.0.level)"})}
    var diagnostics: String {
        var result = ""
        for (factor, interactions) in factors {
            result += "\(factor.name) – lvl \(factor.level):"
            for (affectingFactor, coefficient) in interactions {
                result += "\n\t\(coefficient) from \(affectingFactor.name)"
            }
            result += "\n"
        }
        return result
    }
}
