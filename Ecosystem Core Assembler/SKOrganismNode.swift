//
//  SKOrganismNode.swift
//  EcoloFinal
//
//  Created by Alex Cao on 5/1/17.
//  Copyright © 2017 Alex Cao. All rights reserved.
//

import SpriteKit
import GameplayKit

enum SpriteStatus {
    case Dying
    case MarkedForDeath
    case Hunting
    case Standby
    case Introducing
    case Killed //Added new case to distinguish handling for death between .MarkedForDeath SKOrganismNode that gets killed by predator vs. one that is told to die before it can get killed by predator
}

class SKOrganismNode: SKSpriteNode {
    
    let factor: Factor
    //let sprite: SKSpriteNode
    var direction = Int()
    //var action: SKAction?
    //let scene: SKScene
    var spriteStatus: SpriteStatus
    var target: SKOrganismNode?
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func randomInt (min: Int , max: Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    func randomPoint(inDomain name: String) -> CGPoint? {
        guard let domain = scene!.childNode(withName: name) else {
            return nil
        }
        return CGPoint(x: random(min: domain.position.x - domain.frame.size.width/2, max: domain.position.x + domain.frame.size.width/2), y: random(min: domain.position.y - domain.frame.size.height/2, max: domain.position.y + domain.frame.size.height/2))
    }
    
    required init(factor: Factor) {
        self.factor = factor

        self.spriteStatus = .Standby
        let texture = SKTexture(imageNamed: factor.cdSpecies.imagePath!)
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func shortestDistanceBetweenPoints(_ p1: CGPoint, _ p2: CGPoint) -> Float {
        return hypotf(Float(p1.x - p2.x), Float(p1.y - p2.y))
    }
    
    func wander() {
        
        var destination: CGPoint
        
        switch factor.movement {
        
        case .Aerial:
            let destination = randomPoint(inDomain: "Sky")
        
            faceRightDirection(destination: destination!)
            
            let moveAction = SKAction.move(to: destination!, duration: TimeInterval(random(min: 2, max: 4)))
            
            self.run(SKAction.sequence([moveAction])) {self.wander()}
        
        case .Terrestrial:
            let pointToGo = randomPoint(inDomain: "Ground")
            let distance = shortestDistanceBetweenPoints(self.position, pointToGo!)
            
            if distance < 300 {
                destination = self.position
            } else {
                destination = pointToGo!
            }
            
            self.zPosition = destination.y * -1 / 100
            faceRightDirection(destination: destination)
            
            let moveAction = SKAction.move(to: destination, duration: TimeInterval(random(min: 2, max: 4)))
            let delayAction = SKAction.wait(forDuration: TimeInterval(randomInt(min: 1, max: 5)))
            
            self.run(SKAction.sequence([moveAction, delayAction])) {self.wander()}
        
        case .Static:
            break
        
        }
        
    }
    
    func standby() {
        
        spriteStatus = .Standby
        self.removeAllActions()
        self.wander()
        
    }
    
    
    //When sprite animations begin becoming a thing, we can use SKAction.group to move and animate sprite at the same time (SKAction.group, SKAction.sequence, SKAction.repeating are all very cool)
    
    //helps manage movement stuff (sets action, switches direction)
    
    func faceRightDirection(destination: CGPoint) {
        
        if self.position.x < destination.x {
            if direction != 1 {
                direction = 1
                self.xScale = self.xScale * -1
            }
            
        } else if self.position.x > destination.x {
            if direction != -1 {
                direction = -1
                self.xScale = self.xScale * -1
            }
        }
        
    }
    
    //How can we link the scene to the sprites within the NSOrganismSprite class?
    func introduce() {
        
        spriteStatus = .Introducing
        
        switch factor.movement {
        case .Aerial:
            self.position = randomPoint(inDomain: "Sky")!
        case .Terrestrial:
            self.position = randomPoint(inDomain: "Ground")!
        case .Static:
            self.position = randomPoint(inDomain: "Ground")!
        }
        
        let randomSide = Int(arc4random_uniform(2))
        if randomSide > 0 {
            self.position.x = scene!.size.width/2 + 100
            direction = -1
            
        } else {
            self.position.x = scene!.size.width/2 * -1 - 100
            direction = 1
            self.xScale = self.xScale * -1
        }
        
        var destination: CGPoint
        
        switch factor.movement {
        case .Aerial:
            destination = randomPoint(inDomain: "Sky")!
        case .Terrestrial:
            destination = randomPoint(inDomain: "Ground")!
        case .Static:
            destination = randomPoint(inDomain: "Ground")!
        }
        
        faceRightDirection(destination: destination)
        
        if factor.movement != .Static {
            self.run(SKAction.move(to: destination, duration: 3), completion: {self.standby()})
        } else {
            self.alpha = 0.0
            self.position = destination
            self.run(SKAction.fadeIn(withDuration: 1), completion: {self.standby()})
        }
    }
    
    func markForDeath() {
        
        switch spriteStatus {
            
        case .Standby, .Introducing:
            spriteStatus = .MarkedForDeath
            self.removeAllActions()
            
        case .Hunting:
            self.removeAllActions()
            spriteStatus = .MarkedForDeath
            target?.die()
            
        //case .Introducing: die()
            
        case .Dying: break
            
        case .Killed: break
            
        case .MarkedForDeath: break
            
        }
    }
    
    let killedAnimation = SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 0.25)
    let disintegrate = SKAction.fadeOut(withDuration: 1)
    let delete = SKAction.removeFromParent() //How to completely delete the SKOrganismNode object?
    
    
    func die() {
        
        let erase = SKAction.run({(self.scene as! GameScene).removeOrganismNode(node: self)})
        
        switch spriteStatus {
            
        case .Standby, .Introducing:
            spriteStatus = .Dying
            
            self.removeAllActions()
            self.run(SKAction.sequence([disintegrate, erase, delete]))
            
        /*case .Introducing:
            spriteStatus = .Dying
            let exit = action!.reversed()
            direction *= -1
            sprite.xScale = sprite.xScale * -1
            action = SKAction.sequence([exit, delete])
            
            sprite.removeAllActions()
            sprite.run(action!)*/
            
        case .Hunting:
            spriteStatus = .Dying
            target?.die()
            self.removeAllActions()
            self.run(SKAction.sequence([disintegrate, erase, delete]))
            
        case .MarkedForDeath:
            spriteStatus = .Dying
            self.removeAllActions()
            self.run(SKAction.sequence([disintegrate, erase, delete]))
            
        case .Killed:
            spriteStatus = .Dying
            self.removeAllActions()
            self.run(SKAction.sequence([killedAnimation, disintegrate, erase, delete]))
            
        case .Dying: break
        }
        
    }
    
    func getKilled() {
        if spriteStatus == .MarkedForDeath {
            spriteStatus = .Killed
            die()
        } else {
            print("cannot kill SKOrganism node that isn't marked for death")
        }
    }
    
    
    func hunt(prey: SKOrganismNode) {
        print("TARGET REQUESTED \(factor.name) \(self.hashValue) targeting \(prey.factor.name) \(prey.hashValue)")
        spriteStatus = .Hunting
        target = prey
        print("TARGET ACQUIRED \(factor.name) \(self.hashValue) targeting \(target?.factor.name) \(target?.hashValue)")
        let targetPosition = prey.position
        
        faceRightDirection(destination: targetPosition)
        let markPrey = SKAction.run({prey.markForDeath()})
        let attack = SKAction.move(to: targetPosition, duration: 3)
        let kill = SKAction.run({prey.getKilled()})
        let removeTarget = SKAction.run({self.target = nil})
        self.removeAllActions()
        self.run(SKAction.sequence([markPrey, attack, kill, removeTarget]), completion: {self.standby()})
        
    }
    
    //Comment comment comment
    
    
}
