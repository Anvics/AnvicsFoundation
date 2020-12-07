//
//  UISearchBarComponent.swift
//  Foodbook
//
//  Created by Nikita Arkhipov on 04.12.2020.
//  Copyright © 2020 Anvics. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit
import FastArchitecture

extension UISearchBar: FastComponent{
    public var event: SafeSignal<String> { reactive.text.dropFirst(1).ignoreNils() }
    
    public func update(data: ViewData) {
        super.baseUpdate(data: data)
    }
}
