//
//  TextfieldComponent.swift
//  BellisBox
//
//  Created by Nikita Arkhipov on 01.06.2020.
//  Copyright © 2020 Anvics. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit
import FastArchitecture

public class TextfieldData: FastDataCreatable, Equatable{
    let text: String?
    
    required public init(data: String?){
        text = data
    }
    
    public static func == (lhs: TextfieldData, rhs: TextfieldData) -> Bool {
        lhs.text == rhs.text
    }
}

extension UITextField: FastComponent{
    public var event: SafeSignal<String> { reactive.text.dropFirst(1).ignoreNils() }
    
    public func update(data: TextfieldData) {
        resolve(data.text) {
            if self.text == $0 { return }
            self.text = $0
            _ = self.event.append($0)
        }
    }
}

