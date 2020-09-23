//
//  KeyboardMovingController.swift
//  Hora
//
//  Created by Nikita Arkhipov on 17/06/2019.
//  Copyright © 2019 Hora. All rights reserved.
//

import UIKit

open class KeyboardMovingController: UIViewController{
    private var kMinimumTetxfieldY: CGFloat{
        return 140
    }
    
    private var defaultY: CGFloat!
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private var movingView: UIView{
        return view.superview ?? view
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            guard let textfield = view.firstResponder() as? UITextField, textfield.visibleOffset != -1 else { return }
            let y = textfield.absolutePosition.y
            let th = textfield.frame.size.height
            let kh = keyboardSize.height
            let sh = UIScreen.main.bounds.size.height
            let of = textfield.visibleOffset
            let ny = min(y, sh - kh - of - th)
            let cy = textfield.absoluteContentOffset.y
            if defaultY == nil { defaultY = movingView.frame.origin.y }
//            print(ny - y)
            let my = movingView.frame.origin.y
            let d = ny - y + cy
            movingView.frame.origin.y = defaultY + (my - defaultY) + d
            //            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let y = defaultY, movingView.frame.origin.y != y {
            movingView.frame.origin.y = y
        }
    }
    
    
}

//extension

public extension UITextField {
    
    private struct AssociatedKeys {
        static var visibleOffset = "UITextField.VisibleOffset"
    }
    
    @IBInspectable var visibleOffset: CGFloat {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.visibleOffset) as? CGFloat) ?? -1
        }
        set (offset) {
            objc_setAssociatedObject(self, &AssociatedKeys.visibleOffset, offset, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
