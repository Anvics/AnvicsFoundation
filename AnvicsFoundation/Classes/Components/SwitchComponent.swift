//
//  SwitchComponent.swift
//  Foodbook
//
//  Created by Nikita Arkhipov on 28/02/2020.
//  Copyright © 2020 Anvics. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond
import FastArchitecture

public class SwitchData: Equatable, FastDataCreatable{
    let isOn: Bool?
    
    let isEnabled: Bool?
    let alpha: CGFloat?
    let isHidden: Bool?
    
    required public init(data: Bool?){
        self.isOn = data
        self.isEnabled = nil
        self.alpha = nil
        self.isHidden = nil
    }

    init(isOn: Bool? = nil, isEnabled: Bool? = nil, alpha: CGFloat? = nil, isHidden: Bool? = nil) {
        self.isOn = isOn
        self.isEnabled = isEnabled
        self.alpha = alpha
        self.isHidden = isHidden
    }
}

public func ==(lhs: SwitchData, rhs: SwitchData) -> Bool{
    return lhs.isOn == rhs.isOn &&
        lhs.isEnabled == rhs.isEnabled &&
        lhs.alpha == rhs.alpha &&
        lhs.isHidden == rhs.isHidden
}

extension UISwitch: FastComponent{
    public var event: SafeSignal<Bool> { reactive.isOn.toSignal() }
    
    public func update(data: SwitchData) {
        resolve(data.isOn) { isOn = $0 }
        resolve(data.isEnabled) { isEnabled = $0 }
        resolve(data.alpha) { alpha = $0 }
        resolve(data.isHidden) { isHidden = $0 }
    }
}

