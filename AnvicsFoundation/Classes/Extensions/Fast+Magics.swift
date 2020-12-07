//
//  FastExtensions.swift
//  BellisBox
//
//  Created by Nikita Arkhipov on 11.06.2020.
//  Copyright © 2020 Anvics. All rights reserved.
//

import Foundation
import FastArchitecture
import Magics
import Photos
import SVProgressHUD
import ReactiveKit

public typealias FastJSON = [String: Any]

public extension FastActor{
    typealias ErrorCompletion = (MagicsError) -> Void
    typealias SuccessCompletion = (MagicsJSON, MagicsAPI) -> Void
        
    func interact(_ url: String, method: MagicsMethod = .get, json: FastJSON = [:], error: ErrorCompletion? = nil, complete: SuccessCompletion? = nil) -> [FastMiddleware]{
        var errorProcess: ((FastRouter, MagicsError) ->Void)?
        if let er = error { errorProcess = { _, err in er(err) } }
        return [MagicsMiddleware(interactor: FastBaseInteractor(url, method: method, json: json, complete: complete), errorProcess: errorProcess)]
    }
    
    func get(_ url: String, json: FastJSON = [:], error: ErrorCompletion? = nil, complete: SuccessCompletion? = nil) -> [FastMiddleware]{
        interact(url, method: .get, json: json, error: error, complete: complete)
    }
    
    func post(_ url: String, json: FastJSON = [:], error: ErrorCompletion? = nil, complete: SuccessCompletion? = nil) -> [FastMiddleware]{
        interact(url, method: .post, json: json, error: error, complete: complete)
    }
    
    func loadArray<Model: MagicsModel>(_ url: String, method: MagicsMethod = .get, jsonPath: String, showLoading: Bool = true, modify: @escaping (inout URLRequest) -> Void = { _ in }, complete: @escaping ([Model]) -> Void) -> [FastMiddleware]{
        FastArrayInteractor(url, method: method, jsonPath: jsonPath, modify: modify) { d, _ in
            complete(d)
        }.toMiddleware(showLoading: showLoading)
    }

    func loadArray<Model: MagicsModel>(_ url: String, method: MagicsMethod = .get, jsonPath: String, showLoading: Bool = true, modify: @escaping (inout URLRequest) -> Void = { _ in }, complete: @escaping ([Model], MagicsJSON) -> Void) -> [FastMiddleware]{
        FastArrayInteractor(url, method: method, jsonPath: jsonPath, modify: modify) { d, json in
            complete(d, json)
        }.toMiddleware(showLoading: showLoading)
    }
}

public extension FastActor where Action: FastDynamicAction{
    typealias DynamicCompletion = (inout Action.State, MagicsJSON, MagicsAPI) -> Void
    
    func interact(_ url: String, method: MagicsMethod = .get, json: FastJSON = [:], complete: @escaping DynamicCompletion) -> [FastMiddleware]{
        FastBaseInteractor(url, method: method, json: json, complete: { json, api in
            self.reduce(.dynamic(changeState: { s in complete(&s, json, api) }))
        }).middleware
    }

    func get(_ url: String, json: FastJSON = [:], complete: @escaping DynamicCompletion) -> [FastMiddleware]{
        interact(url, method: .get, json: json, complete: complete)
    }
    
    func post(_ url: String, json: FastJSON = [:], complete: @escaping DynamicCompletion) -> [FastMiddleware]{
        interact(url, method: .post, json: json, complete: complete)
    }
    
    func loadArray<Model: MagicsModel>(_ url: String, method: MagicsMethod = .get, jsonPath: String, showLoading: Bool = true, modify: @escaping (inout URLRequest) -> Void = { _ in }, complete: @escaping (inout Action.State, [Model]) -> Void) -> [FastMiddleware]{
        let i = FastArrayInteractor(url, method: method, jsonPath: jsonPath, modify: modify) { d, json in
            self.reduce(.dynamic(changeState: { s in complete(&s, d) }))
        }
        return [MagicsMiddleware(interactor: i, showLoading: showLoading)]
    }
}

