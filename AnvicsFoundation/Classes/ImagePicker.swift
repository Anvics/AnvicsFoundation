//
//  ImagePicker.swift
//  BellisBox
//
//  Created by Nikita Arkhipov on 29.05.2020.
//  Copyright © 2020 Anvics. All rights reserved.
//

import UIKit

public class ImagePickerManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var picker = UIImagePickerController()

    var viewController: UIViewController?
    var pickImageCallback : ((UIImage) -> ())?
    
    public override init(){
        super.init()
    }
    
    public func pickImage(_ viewController: UIViewController, _ callback: @escaping ((UIImage) -> ())) {
        pickImageCallback = callback
        let alert = UIAlertController(title: "Выберите фото", message: nil, preferredStyle: .actionSheet)
        self.viewController = viewController
        
        let cameraAction = UIAlertAction(title: "Сделать фото", style: .default){ _ in
            self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Выбрать из галереи", style: .default){ _ in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){ _ in }

        // Add the actions
        picker.delegate = self
        alert.addAction(gallaryAction)
        alert.addAction(cameraAction)
        alert.addAction(cancelAction)
//        alert.popoverPresentationController?.sourceView = self.viewController!.view
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func openCamera(){
        if(UIImagePickerController.isSourceTypeAvailable(.camera)){
            picker.sourceType = .camera
            self.viewController!.present(picker, animated: true, completion: nil)
        } else {
            let alertWarning = UIAlertController(title: "Отсутствует доступ к камере")
            alertWarning.addAction(title: "OK")
            viewController?.present(alertWarning, animated: true, completion: nil)
        }
    }
    
    func openGallery(){
        picker.sourceType = .photoLibrary
        self.viewController!.present(picker, animated: true, completion: nil)
    }
        
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        pickImageCallback?(image)
    }
}
