//
//  SKSliderNode.swift
//  EcoloFinal
//
//  Created by Alex Cao on 5/19/17.
//  Copyright © 2017 Alex Cao. All rights reserved.
//

import Foundation
import SpriteKit

class SKSliderNode: SKNode {
    
    var size: CGSize = CGSize(width: 0, height: 0)
    var anchorPoint: CGPoint = CGPoint(x: 0.5, y: 0.5)
    var frameInParent: CGRect {
        get {
            return CGRect(origin: CGPoint(x: self.position.x - 0.5 * self.size.width, y: self.position.y - 0.5 * self.size.height), size: self.size)
        }
        set(newValue) {
            super.position = newValue.origin
            self.size = newValue.size
        }
    }
    
    var isEnabled: Bool = true
    var isActive: Bool = false
    var overlayThumb: Bool = false {
        didSet {
            calculateNewThumbRange()
        }
    }
    //Value of thumb on slider
    var value : CGFloat {
        get {
            let thumbDistance = thumbSprite.position.x + self.thumbRange.upperBound
            let thumbRange = self.thumbRange.upperBound - self.thumbRange.lowerBound
            let valueMultiplier = self.valueRange.upperBound - self.valueRange.lowerBound
            return (self.valueRange.lowerBound) + (thumbDistance / thumbRange * valueMultiplier)
        }
        set(newValue) {
            var val = newValue
            if newValue < self.valueRange.lowerBound {
                val = self.valueRange.lowerBound
            } else if newValue > self.valueRange.upperBound {
                val = self.valueRange.upperBound
            }
            let valueDistance = val - self.valueRange.lowerBound
            let thumbMultiplier = self.thumbRange.upperBound - self.thumbRange.lowerBound
            let valueRange = self.valueRange.upperBound - self.valueRange.lowerBound
            let newPositionX = (valueDistance * thumbMultiplier / valueRange) - self.thumbRange.upperBound
            thumbSprite.position = CGPoint(x: newPositionX, y: thumbSprite.position.y)
            if self.thumbSpriteActive != nil {
                self.thumbSpriteActive!.position = CGPoint(x: newPositionX, y: self.thumbSpriteActive!.position.y)
            }
        }
    }
    
    var valueRange = CGFloat(0.0)...CGFloat(1.0)
    var thumbRange = CGFloat(0.0)...CGFloat(1.0)
    var thumbOffset : CGFloat = 0.0 {
        didSet {
            self.thumbSprite.position = CGPoint(x: self.thumbSprite.position.x, y: CGFloat(self.thumbOffset))
            if self.thumbSpriteActive != nil {
                self.thumbSpriteActive!.position = CGPoint(x:self.thumbSpriteActive!.position.x, y: CGFloat(self.thumbOffset))
            }
        }
    }
    
    let scaleSprite: SKSpriteNode
    let thumbSprite: SKSpriteNode
    
    let scaleSpriteActive: SKSpriteNode?
    let thumbSpriteActive: SKSpriteNode?
    
    let method: () -> ()
    
    /*typealias SKSliderNodeCompletion = ((SKSliderNode, Float) -> ())
    var touchDown: SKSliderNodeCompletion?
    var touchMoved: SKSliderNodeCompletion?
    var touchUp: SKSliderNodeCompletion?
    var touchUpInside: SKSliderNodeCompletion?
    var touchCancelled: SKSliderNodeCompletion?
 */
    
    init(thumbSprite: SKSpriteNode, scaleSprite: SKSpriteNode, thumbSpriteActive: SKSpriteNode?, scaleSpriteActive: SKSpriteNode?, method: @escaping () -> ()) {
        self.thumbSprite = thumbSprite
        self.scaleSprite = scaleSprite
        self.thumbSpriteActive = thumbSpriteActive
        self.scaleSpriteActive = scaleSpriteActive
        
        self.method = method
        
        thumbSprite.zPosition = scaleSprite.zPosition + 1
        
        super.init()
        self.isUserInteractionEnabled = true
        self.addChild(self.scaleSprite)
        self.addChild(self.thumbSprite)
        
        if self.scaleSpriteActive != nil {
            scaleSpriteActive?.zPosition = scaleSprite.zPosition
            self.addChild(self.scaleSpriteActive!)
            self.scaleSpriteActive!.isHidden = true
        }
        
        if self.thumbSpriteActive != nil {
            thumbSpriteActive?.zPosition = thumbSprite.zPosition
            self.addChild(self.scaleSpriteActive!)
            self.thumbSpriteActive!.isHidden = true
        }
        
        calculateNewThumbRange()
        self.size = scaleSprite.size
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func moveThumbToValueAccordingToTouch(touch: UITouch) {
        let touchPosition = touch.location(in: self)
        var newPositionX = touchPosition.x
        if newPositionX < CGFloat(self.thumbRange.lowerBound) {
            newPositionX = CGFloat(self.thumbRange.lowerBound)
        }
        else if newPositionX > CGFloat(self.thumbRange.upperBound) {
            newPositionX = CGFloat(self.thumbRange.upperBound)
        }
        
        self.thumbSprite.position = CGPoint(x: newPositionX, y:self.thumbSprite.position.y)
        if self.thumbSpriteActive != nil {
            self.thumbSpriteActive!.position = CGPoint(x: newPositionX, y:self.thumbSpriteActive!.position.y)
        }
    }
    
    func calculateNewThumbRange() {
        self.thumbRange = (self.overlayThumb) ? ((-scaleSprite.size.width/2)...(scaleSprite.size.width/2)) : ((-(scaleSprite.size.width / 2 - thumbSprite.size.width / 2))...(scaleSprite.size.width / 2 - thumbSprite.size.width / 2))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isEnabled {
            isActive = true
            if self.scaleSpriteActive != nil {
                self.scaleSprite.isHidden = true
                self.scaleSpriteActive?.isHidden = false
            }
            if self.thumbSpriteActive != nil {
                self.thumbSprite.isHidden = true
                self.thumbSpriteActive!.isHidden = false
            }
            
            moveThumbToValueAccordingToTouch(touch: touches.first! as UITouch)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isEnabled {
            let touchPosition = (touches.first! as UITouch).location(in: self.parent!)
            if self.frameInParent.contains(touchPosition) {
                if self.scaleSpriteActive != nil {
                    self.scaleSprite.isHidden = true
                    self.scaleSpriteActive!.isHidden = false
                }
            } else {
                if self.scaleSpriteActive != nil {
                    self.scaleSprite.isHidden = false
                    self.scaleSpriteActive!.isHidden = true
                }
            }
            moveThumbToValueAccordingToTouch(touch: touches.first! as UITouch)
            method()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isEnabled {
            isActive = false
            if self.scaleSpriteActive != nil {
                self.scaleSprite.isHidden = false
                self.scaleSpriteActive!.isHidden = true
            }
            if self.thumbSpriteActive != nil {
                self.thumbSprite.isHidden = false
                self.thumbSpriteActive!.isHidden = true
            }
            method()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isEnabled {
            isActive = false
            if self.scaleSpriteActive != nil {
                self.scaleSprite.isHidden = false
                self.scaleSpriteActive!.isHidden = true
            }
            if self.thumbSpriteActive != nil {
                self.thumbSprite.isHidden = false
                self.thumbSpriteActive!.isHidden = true
            }
        }
    }
    
}
