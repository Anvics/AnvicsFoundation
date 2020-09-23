//
//  LoadingSimulateMiddleware.swift
//  BellisBox
//
//  Created by Nikita Arkhipov on 29.05.2020.
//  Copyright © 2020 Anvics. All rights reserved.
//

import Foundation
import FastArchitecture
import SVProgressHUD

public class LoadingMiddleware: FastMiddleware{
    
    let delay: TimeInterval
    
    public init(delay: TimeInterval = 1) {
        self.delay = delay
    }
    
    public func process(router: FastRouter, complete: @escaping EmptyClosure){
        SVProgressHUD.show()
        GCD_After(delay) {
            SVProgressHUD.dismiss()
            complete()
        }
    }
}
