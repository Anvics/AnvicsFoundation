//
//  PhotoUploadMiddleware.swift
//  BellisBox
//
//  Created by Nikita Arkhipov on 09.07.2020.
//  Copyright © 2020 Anvics. All rights reserved.
//

import UIKit
import FastArchitecture
import SVProgressHUD
import Magics

public class PhotoUploadMiddleware: FastMiddleware{    
    let api: MagicsAPI
    let relativeURL: String
    let image: UIImage
    let fileName: String
    
    init(api: MagicsAPI, relativeURL: String, image: UIImage, fileName: String = "photo") {
        self.api = api
        self.relativeURL = relativeURL
        self.image = image
        self.fileName = fileName
    }
    
    public func process(router: FastRouter, complete: @escaping EmptyClosure) {
        SVProgressHUD.show()
        let url = URL(string: api.baseURL + relativeURL)

        let boundary = UUID().uuidString

        let session = URLSession.shared

        var urlRequest = URLRequest(url: url!)
        urlRequest = api.modify(request: urlRequest, interactor: EmptyInteractor())
        
        urlRequest.httpMethod = "POST"

        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
        // And the boundary is also set here
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()

        // Add the image data to the raw http request data
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(fileName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append((image.scaled(toWidth: 200) ?? image).pngData()!)

        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        // Send a POST request to the URL, with the data we created earlier
        session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
            GCD_Main {
                SVProgressHUD.dismiss()
                complete()
            }
        }).resume()
    }
}

private class EmptyInteractor: NSObject, MagicsInteractor{
    var relativeURL: String { "" }
    var api: MagicsAPI { MagicsAPI() }
}
