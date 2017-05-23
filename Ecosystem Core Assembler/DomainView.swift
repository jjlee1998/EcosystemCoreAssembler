//
//  DomainView.swift
//  Ecosystem Core Assembler
//
//  Created by Jonathan J. Lee on 5/22/17.
//  Copyright © 2017 Jonathan J. Lee. All rights reserved.
//

import UIKit

protocol DomainViewDelegate {
    func saveSun(relativePoint: RelativePoint)
    func saveTemperature(_ temp: Bool)
    func saveRain(_ precip: Bool)
    func saveAir(relativeRect: RelativeRect?)
    func saveEarth(relativeRect: RelativeRect?)
    func saveWater(relativeRect: RelativeRect?)
}

extension CGRect {
    var center: CGPoint {
        get {return CGPoint(x: origin.x + (width / 2), y: origin.y + (height / 2))}
        set {self.origin = CGPoint(x: newValue.x - (width / 2), y: newValue.y - (height / 2))}
    }
    var corners: [CGPoint] {
        var result = [CGPoint]()
        result.append(origin)
        result.append(CGPoint(x: origin.x, y: origin.y + height))
        result.append(CGPoint(x: origin.x + width, y: origin.y))
        result.append(CGPoint(x: origin.x + width, y: origin.y + height))
        return result
    }
    init(center: CGPoint, size: CGSize) {
        self.init(origin: CGPoint(x: center.x - (size.width / 2), y: center.y - (size.height / 2)), size: size)
    }
}

class DomainView: UIView {
    
    var image: UIImage? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    var delegate: DomainViewDelegate!
    
    var sunPoint: CGPoint? {didSet {setNeedsDisplay()}}
    var rain: Bool? {didSet {setNeedsDisplay()}}
    var temperature: Bool? {didSet {setNeedsDisplay()}}
    
    var domains = [String: CGRect]()
    var airRect: CGRect? {
        get {
            return domains["airRect"]
        }
        set {
            domains["airRect"] = newValue
            setNeedsDisplay()
        }
    }
    var earthRect: CGRect? {
        get {
            return domains["earthRect"]
        }
        set {
            domains["earthRect"] = newValue
            setNeedsDisplay()
        }
    }
    var waterRect: CGRect? {
        get {
            return domains["waterRect"]
        }
        set {
            domains["waterRect"] = newValue
            setNeedsDisplay()
        }
    }
    
    var movingSun = false
    var movingRectName: String?
    var resizingRectName: String?
    
    var imageRect: CGRect? {
        guard let unchangedImageSize = image?.size else {
            return nil
        }
        let finalWidth = self.bounds.width * 0.9
        let finalHeight = finalWidth / unchangedImageSize.width * unchangedImageSize.height
        return CGRect(center: center, size: CGSize(width: finalWidth, height: finalHeight))
    }
    
    override func draw(_ rect: CGRect) {
        drawImage()
        if sunPoint != nil {
            UIColor.yellow.setFill()
            let sunPath = UIBezierPath(ovalIn: CGRect(center: sunPoint!, size: CGSize(width: 20.0, height: 20.0)))
            sunPath.fill()
        }
        if rain != nil, rain!, let borderRect = imageRect {
            UIColor.blue.setStroke()
            let rainBorder = UIBezierPath(rect: borderRect)
            rainBorder.lineWidth = 10.0
            rainBorder.stroke()
        }
        if temperature != nil, temperature!, let borderRect = imageRect {
            UIColor.orange.setStroke()
            let tempBorder = UIBezierPath(rect: borderRect)
            tempBorder.lineWidth = 5.0
            tempBorder.stroke()
        }
        if airRect != nil {
            UIColor.red.setFill()
            let airPath = UIBezierPath(rect: airRect!)
            airPath.fill(with: .normal, alpha: 0.15)
            let airCenter = UIBezierPath(ovalIn: CGRect(center: airRect!.center, size: CGSize(width: 20.0, height: 20.0)))
            airCenter.fill()
            for point in airRect!.corners {
                let circle = UIBezierPath(ovalIn: CGRect(center: point, size: CGSize(width: 20.0, height: 20.0)))
                circle.fill()
            }
        }
        if earthRect != nil {
            UIColor.green.setFill()
            let earthPath = UIBezierPath(rect: earthRect!)
            earthPath.fill(with: .normal, alpha: 0.15)
            let earthCenter = UIBezierPath(ovalIn: CGRect(center: earthRect!.center, size: CGSize(width: 20.0, height: 20.0)))
            earthCenter.fill()
            for point in earthRect!.corners {
                let circle = UIBezierPath(ovalIn: CGRect(center: point, size: CGSize(width: 20.0, height: 20.0)))
                circle.fill()
            }
        }
        if waterRect != nil {
            UIColor.blue.setFill()
            let waterPath = UIBezierPath(rect: waterRect!)
            waterPath.fill(with: .normal, alpha: 0.15)
            let waterCenter = UIBezierPath(ovalIn: CGRect(center: waterRect!.center, size: CGSize(width: 20.0, height: 20.0)))
            waterCenter.fill()
            for point in waterRect!.corners {
                let circle = UIBezierPath(ovalIn: CGRect(center: point, size: CGSize(width: 20.0, height: 20.0)))
                circle.fill()
            }
        }
    }
    
    func drawImage() {
        if imageRect != nil {
            image?.draw(in: imageRect!)
        }
    }
    
    func enableSun(_ sunExists: Bool) {
        sunPoint = sunExists ? center : nil
        save()
    }
    
    func enableTemperature(_ tempExists: Bool) {
        temperature = tempExists
        save()
    }
    
    func enableRain(_ rainExists: Bool) {
        rain = rainExists
        save()
    }
    
    func enableAir(_ airExists: Bool) {
        if imageRect != nil && airExists {
            airRect = imageRect!
        } else {
            airRect = nil
        }
        save()
    }
    
    func enableEarth(_ earthExists: Bool) {
        if imageRect != nil && earthExists {
            earthRect = imageRect!
        } else {
            earthRect = nil
        }
        save()
    }
    
    func enableWater(_ waterExists: Bool) {
        if imageRect != nil && waterExists {
            waterRect = imageRect!
        } else {
            waterRect = nil
        }
        save()
    }
    
    func createRectFromRelativeRect(relativeRect: RelativeRect) -> CGRect? {
        guard let origin = createPointFromRelativePoint(relativePoint: relativeRect.origin) else {
            return nil
        }
        let width = CGFloat(relativeRect.xProportion) * imageRect!.width
        let height = CGFloat(relativeRect.yProportion) * imageRect!.height
        return CGRect(origin: origin, size: CGSize(width: width, height: height))
    }
    
    func createPointFromRelativePoint(relativePoint: RelativePoint) -> CGPoint? {
        guard imageRect != nil else {
            return nil
        }
        return CGPoint(x: imageRect!.origin.x + (CGFloat(relativePoint.xProportion) * imageRect!.width), y: imageRect!.origin.y + (CGFloat(relativePoint.yProportion) * imageRect!.height))
    }
    
    func createRelativeRectFromRect(rect: CGRect) -> RelativeRect? {
        guard let origin = createRelativePointFromPoint(point: rect.origin) else {
            return nil
        }
        let x = Double(rect.width / imageRect!.width)
        let y = Double(rect.height / imageRect!.height)
        return RelativeRect(origin: origin, xProportion: x, yProportion: y)
    }
    
    func createRelativePointFromPoint(point: CGPoint) -> RelativePoint? {
        guard imageRect != nil else {
            return nil
        }
        let x = Double((point.x - imageRect!.origin.x) / imageRect!.width)
        let y = Double((point.y - imageRect!.origin.y) / imageRect!.height)
        return RelativePoint(xProportion: x, yProportion: y)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        var minimumDistance: CGFloat?
        if sunPoint != nil {
            let distance = distanceBetweenPoints(point1: sunPoint!, point2: location)
            if distance < 50 && ((minimumDistance != nil && distance < minimumDistance!) || minimumDistance == nil) {
                minimumDistance = distance
                movingSun = true
                movingRectName = nil
                resizingRectName = nil
            }
        }
        for (key, domainRect) in domains {
            var distance = distanceBetweenPoints(point1: domainRect.center, point2: location)
            if distance < 50 && ((minimumDistance != nil && distance < minimumDistance!) || minimumDistance == nil) {
                minimumDistance = distance
                movingSun = false
                movingRectName = key
                resizingRectName = nil
            }
            for corner in domainRect.corners {
                distance = distanceBetweenPoints(point1: corner, point2: location)
                if distance < 50 && ((minimumDistance != nil && distance < minimumDistance!) || minimumDistance == nil) {
                    minimumDistance = distance
                    movingSun = false
                    movingRectName = nil
                    resizingRectName = key
                }
            }
        }
    }
    
    func distanceBetweenPoints(point1: CGPoint, point2: CGPoint) -> CGFloat {
        let xDist = point2.x - point1.x
        let yDist = point2.y - point1.y
        return sqrt(xDist * xDist + yDist * yDist)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        if movingSun && sunPoint != nil {
            sunPoint = location
            setNeedsDisplay()
        } else if movingRectName != nil {
            domains[movingRectName!]!.center = location
            self.setNeedsDisplay()
        } else if resizingRectName != nil {
            let center = domains[resizingRectName!]!.center
            let size = CGSize(width: (2.0 * abs(domains[resizingRectName!]!.center.x - location.x)), height: (2.0 * abs(domains[resizingRectName!]!.center.y - location.y)))
            domains[resizingRectName!]!.size = size
            domains[resizingRectName!]!.center = center
            self.setNeedsDisplay()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        movingSun = false
        movingRectName = nil
        resizingRectName = nil
        save()
    }
    
    func save() {
        if sunPoint != nil, let relativePoint = createRelativePointFromPoint(point: sunPoint!) {
            delegate.saveSun(relativePoint: relativePoint)
        }
        if rain != nil {
            delegate.saveRain(rain!)
        }
        if temperature != nil {
            delegate.saveTemperature(temperature!)
        }
        print("Detected Air Rect: \(airRect != nil)")
        if airRect != nil {
            let relativeRect = createRelativeRectFromRect(rect: airRect!)
            delegate.saveAir(relativeRect: relativeRect)
        } else {
            delegate.saveAir(relativeRect: nil)
        }
        if earthRect != nil, let relativeRect = createRelativeRectFromRect(rect: earthRect!) {
            delegate.saveEarth(relativeRect: relativeRect)
        } else {
            delegate.saveEarth(relativeRect: nil)
        }
        if waterRect != nil, let relativeRect = createRelativeRectFromRect(rect: waterRect!) {
            delegate.saveWater(relativeRect: relativeRect)
        } else {
            delegate.saveWater(relativeRect: nil)
        }
    }
}
