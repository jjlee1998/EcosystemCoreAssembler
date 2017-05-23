//
//  AssemblyManager.swift
//  Ecosystem Core Assembler
//
//  Created by Jonathan J. Lee on 5/16/17.
//  Copyright © 2017 Jonathan J. Lee. All rights reserved.
//

import Foundation
import CoreData

extension EcosystemEntity {
    convenience init(context: NSManagedObjectContext, directorate: DirectorateEntity, name: String, eulerIntervals: Int, extinctionThreshold: Double, imagePath: String) {
        self.init(context: context)
        self.directorateEntity = directorate
        self.name = name
        self.eulerIntervals = Int64(eulerIntervals)
        self.extinctionThreshold = extinctionThreshold
        self.imagePath = imagePath
    }
}

extension InteractionEntity {
    convenience init(context: NSManagedObjectContext, directorate: DirectorateEntity, species1: SpeciesEntity, species2: SpeciesEntity, coeff1: Double, coeff2: Double) {
        let conjugate = InteractionEntity(context: context)
        conjugate.directorateEntity = directorate
        conjugate.species = species2
        conjugate.coefficient = coeff2
        self.init(context: context)
        self.directorateEntity = directorate
        self.species = species1
        self.coefficient = coeff1
        self.conjugateInteractionEntity = conjugate
    }
    
    convenience init(context: NSManagedObjectContext, directorate: DirectorateEntity, species: SpeciesEntity, naturalChangeConstant: Double) {
        self.init(context: context)
        self.directorateEntity = directorate
        self.species = species
        self.coefficient = naturalChangeConstant
        self.conjugateInteractionEntity = self
    }
}

extension SpeciesEntity {
    convenience init(context: NSManagedObjectContext, directorate: DirectorateEntity, name: String, type: SpeciesType, movement: MovementType, standardPopulationSize: Int, renderLogBase: Double, isPackHunter: Bool, imagePath: String) {
        self.init(context: context)
        self.directorateEntity = directorate
        self.name = name
        self.type = type.rawValue
        self.movement = movement.rawValue
        self.standardPopulationSize = Int64(standardPopulationSize)
        self.renderLogBase = renderLogBase
        self.isPackHunter = isPackHunter
        self.imagePath = imagePath
    }
}

extension FactorEntity {
    convenience init(context: NSManagedObjectContext, directorate: DirectorateEntity, ecosystem: EcosystemEntity, species: SpeciesEntity, level: Double) {
        self.init(context: context)
        self.directorateEntity = directorate
        self.ecosystemEntity = ecosystem
        self.speciesEntity = species
    }
}

class AssemblyManager {
    
    var appDelegate: AppDelegate!
    var context: NSManagedObjectContext!
    var directorateEntity: DirectorateEntity!
    
    var imageNames: [String]! {
        if let path = Bundle.main.path(forResource: "files", ofType: "plist"), let data = NSDictionary(contentsOfFile: path) as? [String: String] {
            return Array(data.keys).sorted(by: {$0 < $1})
        } else {
            return [String]()
        }
    }
    
    var ecosystems: [EcosystemEntity] {
        if let ecosystemEntities = directorateEntity.ecosystemEntities as? Set<EcosystemEntity> {
            return Array(ecosystemEntities).sorted(by: {$0.name! < $1.name!})
        } else {
            return [EcosystemEntity]()
        }
    }
    
    var species: [SpeciesEntity] {
        if let speciesEntities = directorateEntity.speciesEntities as? Set<SpeciesEntity> {
            return Array(speciesEntities).sorted(by: {$0.name! < $1.name!})
        } else {
            return [SpeciesEntity]()
        }
    }
    
    var interactions: [InteractionEntity] {
        if let interactionEntities = directorateEntity.interactionEntities as? Set<InteractionEntity> {
            return Array(interactionEntities)
        } else {
            return [InteractionEntity]()
        }
    }
    
    var levels: [LevelEntity] {
        if let levelEntities = directorateEntity.levelEntities as? Set<LevelEntity> {
            return Array(levelEntities)
        } else {
            return [LevelEntity]()
        }
    }
    
    var maxLevelNumber: Int64 {
        var max: Int64 = 0
        for level in levels {
            if level.levelNumber > max {
                max = level.levelNumber
            }
        }
        return max
    }
    
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
        context = appDelegate.persistentContainer.viewContext
        
        let directorateFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DirectorateEntity")
        let directorateEntities = try? context.fetch(directorateFetchRequest)
        if directorateEntities != nil, directorateEntities!.first != nil {
            print("Detected preexisting DirectorateEntity.\n")
            directorateEntity = directorateEntities!.first as! DirectorateEntity
        } else {
            print("Did not detect preexisting DirectorateEntity. New DirectorateEntity created.\n")
            directorateEntity = DirectorateEntity(context: context)
            save()
        }
    }
    
    func save() {
        appDelegate.saveContext()
    }
    
    func delete(entity: NSManagedObject) {
        context.delete(entity)
        appDelegate.saveContext()
    }
    
    @discardableResult func createBlankEcosystemEntity() -> EcosystemEntity {
        let newEcosystemEntity = EcosystemEntity(context: context, directorate: directorateEntity, name: "New Ecosystem", eulerIntervals: 100, extinctionThreshold: 1e-3, imagePath: "/imagePath/")
        newEcosystemEntity.name! += " \(newEcosystemEntity.hashValue)"
        save()
        return newEcosystemEntity
    }
    
    @discardableResult func createBlankSpeciesEntity() -> SpeciesEntity {
        let newSpeciesEntity = SpeciesEntity(context: context, directorate: directorateEntity, name: "New Species", type: .Resource, movement: .Static, standardPopulationSize: 4, renderLogBase: 2.0, isPackHunter: false, imagePath: "")
        newSpeciesEntity.name! += " \(newSpeciesEntity.hashValue)"
        save()
        return newSpeciesEntity
    }
    
    @discardableResult func createBlankInteractionEntityPair(species1: SpeciesEntity, species2: SpeciesEntity, coeff1: Double, coeff2: Double) -> (InteractionEntity, InteractionEntity)? {
        guard !interactions.contains(where: {($0.species! == species1 && $0.conjugateInteractionEntity?.species! == species2) || ($0.species! == species2 && $0.conjugateInteractionEntity?.species! == species1)}) else {
            return nil
        }
        let newInteractionEntity = InteractionEntity(context: context, directorate: directorateEntity, species1: species1, species2: species2, coeff1: coeff1, coeff2: coeff2)
        save()
        return (newInteractionEntity, newInteractionEntity.conjugateInteractionEntity!)
    }
    
    @discardableResult func createBlankSelfInteraction(species: SpeciesEntity, naturalChangeConstant: Double) -> InteractionEntity? {
        guard !interactions.contains(where: {$0.species! == species && $0 == $0.conjugateInteractionEntity}) else {
            return nil
        }
        let newInteractionEntity = InteractionEntity(context: context, directorate: directorateEntity, species: species, naturalChangeConstant: naturalChangeConstant)
        save()
        return newInteractionEntity
    }
    
    @discardableResult func createFactor(ecosystem: EcosystemEntity, species: SpeciesEntity, level: Double) -> FactorEntity {
        let newFactorEntity = FactorEntity(context: context, directorate: directorateEntity, ecosystem: ecosystem, species: species, level: level)
        save()
        return newFactorEntity
    }
    
    @discardableResult func createBlankLevel() -> LevelEntity {
        let newLevelEntity = LevelEntity(context: context)
        newLevelEntity.directorateEntity = directorateEntity
        newLevelEntity.levelNumber = maxLevelNumber + 1
        newLevelEntity.title = "New Level \(newLevelEntity.hashValue)"
        save()
        return newLevelEntity
    }
    
    func createWinCondition(factor: FactorEntity, level: LevelEntity, greaterThan: Bool, threshold: Double) -> WinConditionEntity {
        let newConditionEntity = WinConditionEntity(context: context)
        newConditionEntity.factorEntity = factor
        newConditionEntity.levelEntity = level
        newConditionEntity.greaterThan = greaterThan
        newConditionEntity.threshold = threshold
        save()
        return newConditionEntity
    }
    
    func printEntityDiagnostics() {
        print("Entity Diagnostics:\n")
        for entityDescription in appDelegate.persistentContainer.managedObjectModel.entities {
            let globalFetchRequest = NSFetchRequest<NSFetchRequestResult>()
            globalFetchRequest.entity = entityDescription
            do {
                let entities = try context.fetch(globalFetchRequest)
                //print("Found \(entities.count) entities of type \(entityDescription)")
                for eachEntity in entities {
                    print("\(eachEntity) \n")
                }
            } catch {
                print("!!!!!!! Could not print \(entityDescription) entities !!!!!!!")
            }
        }
    }
}


