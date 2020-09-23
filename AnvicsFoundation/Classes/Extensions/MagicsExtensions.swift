//
//  MagicsExtensions.swift
//  BellisBox
//
//  Created by Nikita Arkhipov on 19.06.2020.
//  Copyright © 2020 Anvics. All rights reserved.
//

import Foundation
import Magics

public extension MagicsAPI{
    func object<T: MagicsModel>(json: MagicsJSON?) -> T?{
        guard let json = json else { return nil }
        return objectFrom(json: json)
    }
}
