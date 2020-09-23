//
//  FastExtensions.swift
//  AnvicsFoundation
//
//  Created by Nikita Arkhipov on 23.09.2020.
//

import Foundation
import UIKit
import FastArchitecture
import SVProgressHUD
import Photos

extension FastActor{
    public func share(items: Any...){
        let a = UIActivityViewController(activityItems: items, applicationActivities: nil)
        route(to: a)
    }
    
    public func downloadFileAt(url: URL, showLoader: Bool = true, completion: @escaping (URL?) -> Void){
        if showLoader { SVProgressHUD.show() }
        let session = URLSession(configuration: .default)
        let task = session.downloadTask(with: url) { url2, _, error in
            print("Downloaded:")
            SVProgressHUD.dismiss()
            if var url2 = url2{
                let fileExtension = String(url.absoluteString.split(separator: ".").last!)
                
                let newurl = url2.absoluteString.removingSuffix("tmp") + fileExtension
                print("\(url2) \n->\n\(newurl)")
                url2.setTemporaryResourceValue(newurl, forKey: .nameKey)
                completion(newurl.url)
            }else{
                completion(nil)
            }
            
        }
        task.resume()
    }
    
    public func saveToGallery(remoteUrl: URL?){
        guard let url = remoteUrl else { return }
        SVProgressHUD.show()
        GCD_Background {
            if let urlData = NSData(contentsOf: url) {
                let galleryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                let filePath="\(galleryPath)/nameX.mp4"
                GCD_Main {
                    urlData.write(toFile: filePath, atomically: true)
                    SVProgressHUD.dismiss()
                    self.saveToGallery(localUrl: filePath)
                }
            }
        }
    }
    
    public func saveToGallery(localUrl: String){
        if PHPhotoLibrary.authorizationStatus() != .notDetermined && PHPhotoLibrary.authorizationStatus() != .authorized {
            SVProgressHUD.showError(withStatus: "Пожалуйста разрешите приложению доступ к галереи в настройках")
            return
        }
        if PHPhotoLibrary.authorizationStatus() != .authorized{
            PHPhotoLibrary.requestAuthorization { status in
                if status != .authorized { self.showLibrarySaveStatus(success: false) }
                else { self.saveToGallery(localUrl: localUrl) }
            }
            return
        }
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: localUrl))
        }) {
            success, error in
            self.showLibrarySaveStatus(success: success)
        }
    }
    
    private func showLibrarySaveStatus(success: Bool){
        if success {
            SVProgressHUD.showSuccess(withStatus: "Сохранено")
        } else {
            SVProgressHUD.showError(withStatus: "Не удалось сохранить")
        }
    }
}
