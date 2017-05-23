//
//  CodableItems.swift
//  Ecosystem Core Assembler
//
//  Created by Jonathan J. Lee on 5/22/17.
//  Copyright © 2017 Jonathan J. Lee. All rights reserved.
//

import UIKit

class RelativePoint: NSObject, NSCoding {
    
    var xProportion: Double
    var yProportion: Double
    
    init(xProportion: Double, yProportion: Double) {
        self.xProportion = xProportion
        self.yProportion = yProportion
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(xProportion, forKey: "xProportion")
        aCoder.encode(yProportion, forKey: "yProportion")
    }
    
    required init?(coder aDecoder: NSCoder) {
        xProportion = aDecoder.decodeDouble(forKey: "xProportion")
        yProportion = aDecoder.decodeDouble(forKey: "yProportion")
    }
    
}

class RelativeRect: NSObject, NSCoding {
    
    var origin: RelativePoint
    var xProportion: Double
    var yProportion: Double
    
    init(origin: RelativePoint, xProportion: Double, yProportion: Double) {
        self.origin = origin
        self.xProportion = xProportion
        self.yProportion = yProportion
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(origin, forKey: "origin")
        aCoder.encode(xProportion, forKey: "xProportion")
        aCoder.encode(yProportion, forKey: "yProportion")
    }
    
    required init?(coder aDecoder: NSCoder) {
        origin = aDecoder.decodeObject(forKey: "origin") as! RelativePoint
        xProportion = aDecoder.decodeDouble(forKey: "xProportion")
        yProportion = aDecoder.decodeDouble(forKey: "yProportion")
    }
    
}


