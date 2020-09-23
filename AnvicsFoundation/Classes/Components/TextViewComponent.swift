//
//  TextViewComponent.swift
//  BellisBox
//
//  Created by Nikita Arkhipov on 01.06.2020.
//  Copyright © 2020 Anvics. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit
import FastArchitecture

extension UITextView: FastComponent{
    public var event: SafeSignal<String> { reactive.text.dropFirst(1).ignoreNils() }
    public func update(data: ViewData) {
        super.baseUpdate(data: data)
    }
}
