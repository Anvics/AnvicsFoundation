//
//  ConstraintComponent.swift
//  Foodbook
//
//  Created by Nikita Arkhipov on 06.03.2020.
//  Copyright © 2020 Anvics. All rights reserved.
//

import UIKit
import FastArchitecture
import ReactiveKit
import Bond

public class ConstraintData: Equatable, FastDataCreatable{
    let value: CGFloat?
    
    required public init(data: CGFloat?){
       value = data
    }
}

public func ==(lhs: ConstraintData, rhs: ConstraintData) -> Bool{
    return lhs.value == rhs.value
}

extension NSLayoutConstraint: FastComponent{
    public var event: SafeSignal<Void> { SafeSignal(just: ()) }
    
    public func update(data: ConstraintData){
        if let v = data.value { constant = v }
    }
}
