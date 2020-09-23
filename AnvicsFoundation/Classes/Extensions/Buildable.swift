//
//  Buildable.swift
//  BellisBox
//
//  Created by Nikita Arkhipov on 10.06.2020.
//  Copyright © 2020 Anvics. All rights reserved.
//

import Foundation

public protocol Buildable{ }

public extension Buildable{
    func build(_ builder: (Self) -> Void) -> Self{
        builder(self)
        return self
    }
}

extension NSObject: Buildable{ }
