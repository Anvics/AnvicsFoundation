//
//  UserDefault.swift
//  Hora
//
//  Created by Nikita Arkhipov on 03.04.2020.
//  Copyright © 2020 Hora. All rights reserved.
//

import Foundation

@propertyWrapper public struct UserDefault<T> {
    public let key: String
    public let defaultValue: T
    
    private let kPrefix = "UserDefault."

    public init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    public var wrappedValue: T {
        get { UserDefaults.standard.object(forKey: kPrefix + key) as? T ?? defaultValue }
        set { UserDefaults.standard.set(newValue, forKey: kPrefix + key) }
    }
}
