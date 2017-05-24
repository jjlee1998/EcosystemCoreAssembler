//
//  GameViewController.swift
//  EcoloFinal
//
//  Created by Alex Cao on 4/3/17.
//  Copyright © 2017 Alex Cao. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

protocol EcosystemSceneDelegate: SKSceneDelegate {
    func introduceFactor(species: SpeciesEntity, level: Double)
    func evolveEcosystem()
    func changeSunlightLevel(to value: CGFloat)
    func changeRainfallLevel(to value: CGFloat)
    func changeTemperatureLevel(to value: CGFloat)
    func getSunlight() -> Factor?
    func getRainfall() -> Factor?
    func getTemperature() -> Factor?
}

class EcosystemViewController: UIViewController, EcosystemSceneDelegate {
    
    var level: Level!
    var ecosystemModel: Ecosystem {return level.ecosystem}
    var gameScene: EcosystemScene!
    
    
    func introduceFactor(species: SpeciesEntity, level: Double) {
        ecosystemModel.addFactor(species: species, level: level)
    }
    
    func evolveEcosystem() {
        ecosystemModel.evolveEcosystem()
        gameScene.render(factors: ecosystemModel.factors)
    }
    
    func changeSunlightLevel(to value: CGFloat) {
        if let sunlight: Factor = ecosystemModel.getSunlight() {
            sunlight.level = Double(value)
        }
    }
    
    func changeRainfallLevel(to value: CGFloat) {
        if let rainfall: Factor = ecosystemModel.getRainfall() {
            rainfall.level = Double(value)
        }
    }
    
    func changeTemperatureLevel(to value: CGFloat) {
        if let temperature: Factor = ecosystemModel.getTemperature() {
            temperature.level = Double(value)
        }
    }
    
    func getSunlight() -> Factor? {
        return ecosystemModel.getSunlight()
    }
    func getRainfall() -> Factor? {
        return ecosystemModel.getRainfall()
    }
    func getTemperature() -> Factor? {
        return ecosystemModel.getTemperature()
    }
    
    override func viewDidLoad() {
        
        print("Level Loaded: \(level.levelTitle)")
        
        super.viewDidLoad()
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.  Also, get the SKScene from the loaded GKScene
        if let scene = GKScene(fileNamed: "GameScene"), let sceneNode = scene.rootNode as! GameScene? {
            
            // Because gameScene and sceneNode are reference types, they refer to the same object. This is intentional.
            sceneNode.delegate = self
            gameScene = sceneNode
            
            // Copy gameplay related content over to the scene
            //sceneNode.entities = scene.entities
            //sceneNode.graphs = scene.graphs
            
            // Set the scale mode to scale to fit the window
            sceneNode.scaleMode = .aspectFill
            
            // Present the scene
            if let view = self.view as! SKView? {
                view.presentScene(sceneNode)
                
                view.ignoresSiblingOrder = true
                
                view.showsFPS = true
                view.showsNodeCount = true
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
