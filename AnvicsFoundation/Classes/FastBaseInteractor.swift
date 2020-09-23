//
//  ActionInteractor.swift
//  BellisBox
//
//  Created by Nikita Arkhipov on 18.06.2020.
//  Copyright © 2020 Anvics. All rights reserved.
//

import Foundation
import Magics

public class FastBaseInteractor: NSObject, MagicsInteractor{
    public typealias ModifyBlock = (inout URLRequest) -> Void
    public typealias CompletionBlock = (MagicsJSON, MagicsAPI) -> Void
    
    public static var defaultAPI = MagicsAPI()
    
    public let relativeURL: String
    public let api: MagicsAPI
    public let method: MagicsMethod
    let modify: ModifyBlock?
    let complete: CompletionBlock?

    public init(_ url: String, api: MagicsAPI = FastBaseInteractor.defaultAPI, method: MagicsMethod = .get, modify: ModifyBlock? = nil, complete: CompletionBlock? = nil) {
        self.relativeURL = url
        self.api = api
        self.method = method
        self.modify = modify
        self.complete = complete
    }
    
    public convenience init(_ url: String, api: MagicsAPI = FastBaseInteractor.defaultAPI, method: MagicsMethod = .get, json: [String: Any] = [:], complete: CompletionBlock? = nil) {
        precondition(json.isEmpty || method != .get, "Trying to set json \(json) with \(method) for \(url)")
        self.init(url, api: api, method: method, modify: {
            if !json.isEmpty { $0.setJSONBody(with: json, shouldPrintJSON: true) }
        }, complete: complete)
    }
        
    public func modify(request: URLRequest) -> URLRequest {
        var r = request
        print("performing \(method.rawValue.uppercased()) '\(relativeURL)'")
        modify?(&r)
        return r
    }
    
    public func process(key: String?, json: MagicsJSON, api: MagicsAPI) {
        complete?(json, api)
    }
}

public class FastArrayInteractor<Model: MagicsModel>: FastBaseInteractor{
    public typealias DataBlock = ([Model], MagicsJSON) -> Void
    
    public init(_ url: String, api: MagicsAPI = FastBaseInteractor.defaultAPI, method: MagicsMethod = .get, jsonPath: String, modify: ModifyBlock? = nil, complete: @escaping DataBlock) {
        super.init(url, api: api, method: method, modify: modify, complete: { json, api in
            guard let js = json[jsonPath] else { complete([], json); return }
            complete(api.arrayFrom(json: js), json)
        })
    }
    
    public convenience init(_ url: String, api: MagicsAPI = FastBaseInteractor.defaultAPI, method: MagicsMethod = .get, jsonPath: String, json: [String: Any] = [:], complete: @escaping DataBlock) {
        self.init(url, api: api, method: method, jsonPath: jsonPath, modify: { $0.setJSONBody(with: json) }, complete: complete)
    }
}
