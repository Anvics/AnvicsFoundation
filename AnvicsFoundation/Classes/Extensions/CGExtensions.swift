//
//  CGExtensions.swift
//  Alcopoly
//
//  Created by Nikita Arkhipov on 06/05/2019.
//  Copyright © 2019 Nikita Arkhipov. All rights reserved.
//

import UIKit

public func /(left: CGFloat, right: Int) -> CGFloat{
    return left / CGFloat(right)
}

public func +(left: CGFloat, right: Int) -> CGFloat{
    return left + CGFloat(right)
}

public func -(left: CGFloat, right: Int) -> CGFloat{
    return left - CGFloat(right)
}

public enum CGPosition{
    case topLeft, topCenter, topRight
    case middleLeft, center, middleRight
    case bottomLeft, bottomCenter, bottomRight
    
    fileprivate var xMultiplicator: CGFloat{
        switch self {
        case .topLeft, .middleLeft, .bottomLeft: return 0
        case .topCenter, .center, .bottomCenter: return 0.5
        case .topRight, .middleRight, .bottomRight: return 1
        }
    }
    
    fileprivate var yMultiplicator: CGFloat{
        switch self {
        case .topLeft, .topCenter, .topRight: return 0
        case .middleLeft, .center, .middleRight: return 0.5
        case .bottomLeft, .bottomCenter, .bottomRight: return 1
        }
    }

}

public extension CGRect{
    func positionedIn(rect: CGRect, at: CGPosition) -> CGRect{
        let dw = rect.width - width
        let dh = rect.height - height
        return CGRect(x: rect.origin.x + dw * at.xMultiplicator,
                      y: rect.origin.y + dh * at.yMultiplicator,
                      width: width,
                      height: height)
    }
    
    var x: CGFloat{ origin.x }

    var y: CGFloat{ origin.y }

    var width: CGFloat{ size.width }

    var height: CGFloat{ size.height }
    
    func boundedBy(rect: CGRect) -> CGRect{
        var r = self
        r.origin.x = max(r.x, rect.x)
        r.origin.y = max(r.y, rect.y)
        if r.x + r.width > rect.width { r.origin.x = rect.width - r.width }
        if r.y + r.height > rect.height { r.origin.y = rect.height - r.height }
        return r
    }
    
    func contains(y: CGFloat) -> Bool{
        self.y >= y && y <= (self.y + height)
    }
    
    mutating func positionIn(rect: CGRect, at: CGPosition){
        self = positionedIn(rect: rect, at: at)
    }
}

public func *(left: CGSize, right: CGFloat) -> CGSize{
    return CGSize(width: left.width * right, height: left.height * right)
}

public func *(left: CGRect, right: CGFloat) -> CGRect{
    return CGRect(x: left.x * right, y: left.y * right, width: left.width * right, height: left.height * right)
}

public func /(left: CGRect, right: CGFloat) -> CGRect{
    return CGRect(x: left.x / right, y: left.y / right, width: left.width / right, height: left.height / right)
}

public func /(left: CGPoint, right: CGFloat) -> CGPoint{
    return CGPoint(x: left.x / right, y: left.y / right)
}

public func /(left: CGSize, right: CGFloat) -> CGSize{
    return CGSize(width: left.width / right, height: left.height / right)
}

public func -(left: CGPoint, right: CGPoint?) -> CGPoint{
    if let right = right { return CGPoint(x: left.x - right.x, y: left.y - right.y) }
    return left
}

public func +(left: CGPoint, right: CGPoint?) -> CGPoint{
    if let right = right { return CGPoint(x: left.x + right.x, y: left.y + right.y) }
    return left
}
