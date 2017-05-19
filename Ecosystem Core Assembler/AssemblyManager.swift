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
    
    /*
    @discardableResult func readIn(entity: InteractionEntity) -> Bool {
        guard let species1Name = entity.species?.name else {
            print("Did not read in interaction because it does not have a target species.\n")
            return false
        }
        guard let conjugate = entity.conjugateInteractionEntity else {
            print("Did not read in interaction for \(species1Name) because it does not have a conjugate.\n")
            return false
        }
        guard let species2Name = conjugate.species?.name else {
            print("Did not read in interaction for \(species1Name) because its conjugate does not have a target species.\n")
            return false
        }
        guard species[species1Name] != nil && species[species2Name] != nil else {
            print("Did not read in interaction between \(species1Name) and \(species2Name) because one or both of these species does not exist.")
            return false
        }
        
        interactions[species1Name]![species2Name] = entity
        interactions[species2Name]![species1Name] = conjugate
        return true
    }*/
    
    @discardableResult func createBlankEcosystemEntity() -> EcosystemEntity {
        let newEcosystemEntity = EcosystemEntity(context: context, directorate: directorateEntity, name: "New Ecosystem", eulerIntervals: 100, extinctionThreshold: 1e-3, imagePath: "/imagePath/")
        newEcosystemEntity.name! += " \(newEcosystemEntity.hashValue)"
        save()
        return newEcosystemEntity
    }
    
    @discardableResult func createBlankSpeciesEntity() -> SpeciesEntity {
        let newSpeciesEntity = SpeciesEntity(context: context, directorate: directorateEntity, name: "New Species", type: .Consumer, movement: .Static, standardPopulationSize: 4, renderLogBase: 2.0, isPackHunter: false, imagePath: "/imagePath/")
        newSpeciesEntity.name! += " \(newSpeciesEntity.hashValue)"
        save()
        return newSpeciesEntity
    }
    
    /*
    
    @discardableResult func createNewFactor(ecosystem: EcosystemEntity, species: SpeciesEntity, level: Double) -> FactorEntity {
        let newFactorEntity = FactorEntity(context: context, directorate: directorateEntity, ecosystem: ecosystem, species: species, level: level)
        appDelegate.saveContext()
        return newFactorEntity
    }
    
    @discardableResult func createNewInteraction(species1: SpeciesEntity, species2: SpeciesEntity, coeff1: Double, coeff2: Double) -> (InteractionEntity, InteractionEntity)? {
        let newInteractionEntity = InteractionEntity(context: context, directorate: directorateEntity, species1: species1, species2: species2, coeff1: coeff1, coeff2: coeff2)
        guard readIn(entity: newInteractionEntity) else {
            return nil
        }
        appDelegate.saveContext()
        return (newInteractionEntity, newInteractionEntity.conjugateInteractionEntity!)
    }*/
    
    
    
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


