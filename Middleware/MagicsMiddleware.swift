//
//  MagicsMiddleware.swift
//  BellisBox
//
//  Created by Nikita Arkhipov on 16.06.2020.
//  Copyright © 2020 Anvics. All rights reserved.
//

import Foundation
import Magics
import FastArchitecture
import SVProgressHUD

public class MagicsMiddleware: FastMiddleware{
    
    public typealias AuthRedirectBlock = (FastRouter) -> Void
    public typealias ErrorRedirectBlock = (FastRouter, MagicsError) -> Void
    
    public static var authRedirect: AuthRedirectBlock?
    public static var errorRedirect: ErrorRedirectBlock?
    
    public static let MagicsShowAlert: ErrorRedirectBlock = { r, e in
        let alert = UIAlertController(title: "Ошибка", message: e.message, preferredStyle: .alert)
        alert.add("OK")
        r.route(to: alert)
    }
    
    let interactor: MagicsInteractor
    let showLoading: Bool
    let errorProcess: ErrorRedirectBlock?
    let delay: TimeInterval
    
    public init(interactor: MagicsInteractor, showLoading: Bool = true, errorProcess: ErrorRedirectBlock? = nil, delay: TimeInterval = 0.2) {
        self.interactor = interactor
        self.showLoading = showLoading
        self.errorProcess = errorProcess
        self.delay = delay
    }
    
    public func process(router: FastRouter, complete: @escaping EmptyClosure) {
        if showLoading { SVProgressHUD.show() }
        GCD_After(delay){
            self.interactor.interact { error in
                if self.showLoading { SVProgressHUD.dismiss() }
                guard let error = error else { complete(); return }
                if self.interactor.api.isTokenError(error) { MagicsMiddleware.authRedirect?(router) }
                else {
                    (self.errorProcess ?? MagicsMiddleware.errorRedirect)?(router, error)   
                }
            }
        }
    }
}

public extension MagicsInteractor{
    typealias ErrorRedirectBlock = (FastRouter, MagicsError) -> Void
    
    var middleware: [FastMiddleware]{ [MagicsMiddleware(interactor: self)] }
    
    func toMiddleware(showLoading: Bool = true, delay: TimeInterval = 0.2, errorProcess: ErrorRedirectBlock? = nil) -> [FastMiddleware]{
        return [MagicsMiddleware(interactor: self, showLoading: showLoading, errorProcess: errorProcess, delay: delay)]
    }
}


