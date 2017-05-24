//
//  GameScene.swift
//  EcoloFinal
//
//  Created by Alex Cao on 4/3/17.
//  Copyright © 2017 Alex Cao. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol EcosystemScene {
    //init(delegate: EcosystemSceneDelegate)
    func render(factors: [Factor: [Factor: Double]])
    func introduceFactor(species: SpeciesEntity, level: Double)
}

extension Array {
    func randomMember() -> Element? {
        guard self.count > 0 else {return nil}
        return self[Int(arc4random_uniform(UInt32(self.count)))]
    }
}

class GameScene: SKScene, EcosystemScene {
    
    // NEW MVC STUFF:
    /*required init(delegate: EcosystemSceneDelegate) {
        super.init()
        self.delegate = delegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }*/
    
    let sky = SKSpriteNode(color: .clear, size: CGSize(width: 1300, height: 570))
    let ground = SKSpriteNode(color: .clear, size: CGSize(width: 1300, height: 160))
    
    let sunlightSliderThumb = SKSpriteNode(imageNamed: "SunlightSliderThumb")
    let sunlightSliderScale = SKSpriteNode(imageNamed: "SliderScale")
    let rainfallSliderThumb = SKSpriteNode(imageNamed: "RainfallSliderThumb")
    let rainfallSliderScale = SKSpriteNode(imageNamed: "SliderScale")
    let temperatureSliderThumb = SKSpriteNode(imageNamed: "TemperatureSliderThumb")
    let temperatureSliderScale = SKSpriteNode(imageNamed: "SliderScale")
    
    let dimPanel = SKSpriteNode(color: .black, size: CGSize(width: 2000, height: 2000))
    let brightPanel = SKSpriteNode(color: .white, size: CGSize(width: 2000, height: 2000))
    
    let coldPanel = SKSpriteNode(color: .cyan, size: CGSize(width: 2000, height: 2000))
    let warmPanel = SKSpriteNode(color: .red, size: CGSize(width: 2000, height: 2000))
    
    override func didMove(to view: SKView) {
        
        //Set up rainfall
        let path = Bundle.main.path(forResource: "Rain", ofType: "sks")
        let rainParticle = NSKeyedUnarchiver.unarchiveObject(withFile: path!) as! SKEmitterNode
        
        rainParticle.particleBirthRate = 0
        rainParticle.speed = 500
        rainParticle.position = CGPoint(x: self.size.width/2, y: self.size.height)
        rainParticle.name = "rainParticle"
        rainParticle.targetNode = self.scene
        
        self.addChild(rainParticle)
        
        //Set up domains
        sky.position = CGPoint(x: 0, y: 200)
        sky.name = "Sky"
        ground.position = CGPoint(x: 0, y: -400)
        ground.name = "Ground"
        addChild(sky)
        addChild(ground)
        
        //Set up sunlight
        dimPanel.alpha = 0.0
        dimPanel.zPosition = 1000
        brightPanel.alpha = 0.0
        brightPanel.zPosition = 1000
        addChild(dimPanel)
        addChild(brightPanel)
        
        //Set up temperature
        coldPanel.alpha = 0.0
        coldPanel.zPosition = 1000
        warmPanel.alpha = 0.0
        warmPanel.zPosition = 1000
        addChild(coldPanel)
        addChild(warmPanel)
        
        if let toolbox = childNode(withName: "ToolBox") {
            
            /*sunlightSliderThumb.size = CGSize(width: 17.694, height: 7.825)
            sunlightSliderScale.size = CGSize(width: 95, height: 1)
            let sunlightSlider = SKSliderNode(thumbSprite: sunlightSliderThumb, scaleSprite: sunlightSliderScale, thumbSpriteActive: nil, scaleSpriteActive: nil, method: changeSunlight)
            
            temperatureSliderThumb.size = CGSize(width: 17.694, height: 7.825)
            temperatureSliderScale.size = CGSize(width: 95, height: 1)
            let temperatureSlider = SKSliderNode(thumbSprite: temperatureSliderThumb, scaleSprite: temperatureSliderScale, thumbSpriteActive: nil, scaleSpriteActive: nil, method: changeTemperature)
            
            rainfallSliderThumb.size = CGSize(width: 17.694, height: 7.825)
            rainfallSliderScale.size = CGSize(width: 95, height: 1)
            let rainfallSlider = SKSliderNode(thumbSprite: rainfallSliderThumb, scaleSprite: rainfallSliderScale, thumbSpriteActive: nil, scaleSpriteActive: nil, method: changeRainfall)

            toolbox.isHidden = true
            
            sunlightSlider.name = "SunlightSlider"
            temperatureSlider.name = "TemperatureSlider"
            rainfallSlider.name = "RainfallSlider"
            
            sunlightSlider.position = CGPoint(x: 0, y: 28)
            temperatureSlider.position = CGPoint(x: 0, y: 19)
            rainfallSlider.position = CGPoint(x: 0, y: 10)
            
            toolbox.addChild(sunlightSlider)
            toolbox.addChild(temperatureSlider)
            toolbox.addChild(rainfallSlider)

            sunlightSlider.value = (CGFloat((delegate as! EcosystemSceneDelegate).getSunlight()!.level) / 20)
            temperatureSlider.value = (CGFloat((delegate as! EcosystemSceneDelegate).getTemperature()!.level) / 20)
            rainfallSlider.value = (CGFloat((delegate as! EcosystemSceneDelegate).getRainfall()!.level) / 20)
            
            changeSunlight()
            changeTemperature()
            changeRainfall()*/
            
        }
        
    }
    
    func introduceFactor(species: SpeciesEntity, level: Double) {
        (delegate as! EcosystemSceneDelegate).introduceFactor(species: species, level: level)
    }

    
    func evolveEcosystem() {
        (delegate as! EcosystemSceneDelegate).evolveEcosystem()
    }
    
    func render(factors: [Factor: [Factor: Double]]) {
        for (factor, _) in factors {
            
            if factor.type != .Resource {
            // If we haven't yet tried to render this factor, that means it's new and its framework needs to be introduced to the GameScene:
            if organismNodes[factor] == nil {
                organismNodes[factor] = []
            }
            
            // Determine how many sprites we need to add or subtract from each factor's population:
            let deltaFactors = desiredNumberOfSprites(factor: factor) - organismNodes[factor]!.count
            //print("\(organismNodes[factor]!.count) \(factor.name)s detected. \(desiredNumberOfSprites(factor: factor)) desired.  Adding \(deltaFactors).")
            
            // First scenario: we don't need to add or subtract anything, in which case we do nothing!
            
            // Second scenario: the population has increased in size, se we add in more individuals to match.
            // Note that the addOrganismNode function automatically sets all individuals to promenade(), so we don't need to do that here.
            if deltaFactors > 1 {
                for _ in 1 ... deltaFactors {
                    addOrganismNode(factor: factor)
                    //print("\(factor.name) added")
                }
                
                // Third scenario: the population has shrunk in size, so we use killOrganismNode an appropriate number of times.
            } else if deltaFactors < -1 {
                for _ in deltaFactors ... -1 {
                    killOrganismNode(factor: factor, relationships: factors[factor]!)
                }
            }
            }
        }
    }
    
    func killOrganismNode(factor: Factor, relationships: [Factor: Double]) {
        // Compile arrays nodes are available for animation:
        let availablePreyNodes = organismNodes[factor]!.filter({$0.spriteStatus == .Standby || $0.spriteStatus == .Introducing})
        let huntingPreyNodes = organismNodes[factor]!.filter({$0.spriteStatus == .Hunting})
        var availablePredatorNodes = [SKOrganismNode]()
        let predators = relationships.filter({$0.value < 0 && $0.key != factor}).map({$0.key})
        for predator in predators {
            if let predatorNodes = organismNodes[predator] {
                availablePredatorNodes.append(contentsOf: predatorNodes.filter({$0.spriteStatus == .Standby || $0.spriteStatus == .Introducing}))
            }
        }
        // Pattern: (Are there possible predators? Are there available prey nodes? Are there hunting prey nodes? Are there available predator nodes?)
        switch (!predators.isEmpty, !availablePreyNodes.isEmpty, !huntingPreyNodes.isEmpty, !availablePredatorNodes.isEmpty) {
        
        case (_, false, false, _): break // Prey unavailable (i.e., already dying)
        case (false, true, _, _): availablePreyNodes.randomMember()?.die() // Prey available, no predator
        case (false, false, true, _): huntingPreyNodes.randomMember()?.die() // Prey hunting, no predator
        case (true, true, _, true): // Predator and prey available
            if let pred = availablePredatorNodes.randomMember(), let prey = availablePreyNodes.randomMember() {
                prey.markForDeath()
                pred.hunt(prey: prey)
            }
        case (true, false, true, true): // Prey hunting, predator available
            if let pred = availablePredatorNodes.randomMember(), let prey = huntingPreyNodes.randomMember() {
                prey.markForDeath()
                pred.hunt(prey: prey)
            }
        case (true, true, _, false): availablePreyNodes.randomMember()?.die() //Prey available, predator unavailable
        case (true, false, true, false): huntingPreyNodes.randomMember()?.die()// Prey hunting, predator unavailable
        default: break
        }
    }
    
    func desiredNumberOfSprites(factor: Factor) -> Int {
        return factor.standardPopulationSize * Int(ceil(log(factor.level + 1) / log(factor.renderLogBase)))
    }
    
    /*
     THINGS TO DO
     
     
     */
    
    //dictionary storing all organism sprites
    var organismNodes = [Factor: Set<SKOrganismNode>]()
    
    //dictionary storing "direction" all sprites are facing
    var organismNodeDirections = [SKOrganismNode: Int]()
    
    //dictionary storing action queues for all sprites
    var organismNodeActions = [SKOrganismNode: [SKAction]]()
    
    
    @discardableResult func addOrganismNode(factor: Factor) -> Bool {
        guard organismNodes[factor] != nil else {return false}
        let newOrganismNode = SKOrganismNode(factor: factor)
        newOrganismNode.xScale = 0.2
        newOrganismNode.yScale = 0.2
        newOrganismNode.zPosition = 3
        organismNodes[factor]!.insert(newOrganismNode)
        organismNodeDirections[newOrganismNode] = -1
        self.addChild(newOrganismNode)
        newOrganismNode.introduce()
        return true
    }
    
    @discardableResult func removeOrganismNode(node: SKOrganismNode) -> Bool {
        return (organismNodes[node.factor]!.remove(node) != nil) ? true : false
    }
    
    //
    // Touches
    //
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            guard let playButton = childNode(withName: "PlayButton"), let toolbox = childNode(withName: "ToolBox"), let toolBoxButton = childNode(withName: "ToolBoxButton") else {
                print("1st checks didn't work")
                break
            }
            
            guard let mountainButton = toolbox.childNode(withName: "MountainButtonNode"), let addGreyWolfButton = toolbox.childNode(withName: "AddGreyWolfButtonNode"), let deleteGreyWolfButton = toolbox.childNode(withName: "DeleteGreyWolfButtonNode"), let addArcticHareButton = toolbox.childNode(withName: "AddArcticHareButtonNode"), let deleteArcticHareButton = toolbox.childNode(withName: "DeleteArcticHareButtonNode"), let addArcticWildflowerButton = toolbox.childNode(withName: "AddArcticWildflowerButton"), let deleteArcticWildflowerButton = toolbox.childNode(withName: "DeleteArcticWildflowerButton") else {
                print("2nd checks didn't work")
                break
            }
            
            for (_, nodes) in organismNodes {
                for node in nodes {
                    print("\(node.factor.name) \(node.hashValue): \(node.spriteStatus) \(node.target)")
                }
            }
            
            if playButton.contains(location) {
                evolveEcosystem()
                //self.isPaused = false
                print("Current Sprite Statuses:")
                
            } else if toolBoxButton.contains(location) {
                if toolbox.isHidden {
                    toolbox.isHidden = false
                } else {toolbox.isHidden = true}
            
                
            } else if toolbox.contains(location) && toolbox.isHidden == false {
                let toolboxLocation = touch.location(in: toolbox)
                
                if mountainButton.contains(toolboxLocation) {
                    toggleMountain()
                
                } else if addGreyWolfButton.contains(toolboxLocation) {
                    addOrganismFromName("Grey Wolf")
                
                } else if deleteGreyWolfButton.contains(toolboxLocation) {
                    deleteOrganismFromName("Grey Wolf")
            
                } else if addArcticHareButton.contains(toolboxLocation) {
                    addOrganismFromName("Arctic Hare")
                
                } else if deleteArcticHareButton.contains(toolboxLocation) {
                    deleteOrganismFromName("Arctic Hare")
                
                } else if addArcticWildflowerButton.contains(toolboxLocation) {
                    addOrganismFromName("Arctic Wildflower")
                
                } else if deleteArcticWildflowerButton.contains(toolboxLocation) {
                    deleteOrganismFromName("Arctic Wildflower")
                
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        changeSunlight()
        
        //self.isPaused = true
    }

    func changeSunlight() {
        if let toolbox = childNode(withName: "ToolBox"), let sunlightSlider = toolbox.childNode(withName: "SunlightSlider") as! SKSliderNode? {
        
            let alphaModifier = (sunlightSlider.value - 0.5) / 2
            if alphaModifier > 0 {
                brightPanel.alpha = alphaModifier
                dimPanel.alpha = 0.0
            } else if alphaModifier < 0 {
                brightPanel.alpha = 0.0
                dimPanel.alpha = alphaModifier * -1
            } else {
                brightPanel.alpha = 0.0
                dimPanel.alpha = 0.0
            }
        
            let sunlightValue = sunlightSlider.value * 20
            (delegate as! EcosystemSceneDelegate).changeSunlightLevel(to: sunlightValue)
            }
    }
    
    func changeRainfall() {
        if let rainclouds = childNode(withName: "RainCloudsNode"), let rainParticle = childNode(withName: "rainParticle") as! SKEmitterNode?, let toolbox = childNode(withName: "ToolBox"), let rainfallSlider = toolbox.childNode(withName: "RainfallSlider")  as! SKSliderNode? {
            
            rainclouds.alpha = rainfallSlider.value * 0.85
            
            rainParticle.particleBirthRate = rainfallSlider.value * 150
            rainParticle.speed = 500 + rainfallSlider.value * 1000
            
            let rainfallValue = rainfallSlider.value * 20
            (delegate as! EcosystemSceneDelegate).changeRainfallLevel(to: rainfallValue)
        }
    }
    
    func changeTemperature() {
        if let toolbox = childNode(withName: "ToolBox"), let temperatureSlider = toolbox.childNode(withName: "TemperatureSlider") as! SKSliderNode? {
            
            let alphaModifier = (temperatureSlider.value - 0.5) / 4
            if alphaModifier > 0 {
                warmPanel.alpha = alphaModifier
                coldPanel.alpha = 0.0
            } else if alphaModifier < 0 {
                warmPanel.alpha = 0.0
                coldPanel.alpha = alphaModifier * -1
            } else {
                warmPanel.alpha = 0.0
                coldPanel.alpha = 0.0
            }
            let temperatureValue = temperatureSlider.value * 20
            (delegate as! EcosystemSceneDelegate).changeTemperatureLevel(to: temperatureValue)
            
        }

    }
    
    func addOrganismFromName(_ name: String) {
        for (factor, _) in organismNodes {
            if factor.name == name {
                addOrganismNode(factor: factor)
            }
        }
    }
    
    func deleteOrganismFromName(_ name: String) {
        for (factor, _) in organismNodes {
            if factor.name == name {
                killOrganismNode(factor: factor, relationships: (delegate as! EcosystemViewController).ecosystemModel.factors[factor]!)
            }
        }
    }
    
    func toggleMountain() {
        if let mountain = childNode(withName: "MountainNode") {
        
        if mountain.alpha == 0 {
            let animate = SKAction(named: "fadeInMountain")
            mountain.run(animate!)
        } else if mountain.alpha == 1{
            let animate = SKAction(named: "fadeOutMountain")
            mountain.run(animate!)
        }
        }
    }
    
}

