//
//  MessagingController.swift
//  BellisBox
//
//  Created by Nikita Arkhipov on 29.05.2020.
//  Copyright © 2020 Anvics. All rights reserved.
//

import UIKit

open class MessagingController: UIViewController {
    
    var contentScrollView: UIScrollView { fatalError() }

    var textInputHeightConstraint: NSLayoutConstraint { fatalError() }

    var bottomConstraint: NSLayoutConstraint { fatalError() }

    var textInput: UITextView { fatalError() }
    
    var textfieldPlaceholderText = "Введите сообщение"
    var textfieldPlaceholderColor = UIColor(hexString: "9e9e9e")
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        textInput.textContainerInset = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        textInput.delegate = self
        bindTextfieldNotification()
        textViewDidEndEditing(textInput)
    }
    
    private func bindTextfieldNotification(){
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            var iPhoneXInset: CGFloat = 0
            if #available(iOS 11.0, *) {
                iPhoneXInset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            }
            print("bottomConstraint \(bottomConstraint.constant) ->")
            if endFrameY >= UIScreen.main.bounds.size.height {
                bottomConstraint.constant = 0
            } else {
                if let h = endFrame?.size.height { bottomConstraint.constant = h - iPhoneXInset }
                else { bottomConstraint.constant = 0.0 }
            }
            print("\(bottomConstraint.constant)")
            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: animationCurve,
                           animations: {
                            //                                self.collectionView.contentOffset.y += -self.bottomConstraint.constant
                            self.view.layoutIfNeeded()
                            self.contentScrollView.scrollTo(edge: .bottom, animated: false)
            },
                           completion: nil)
        }
    }
    
}

extension MessagingController: UITextViewDelegate{
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView.text == textfieldPlaceholderText){
            textView.text = ""
            textView.textColor = .black
        }
        textView.becomeFirstResponder() //Optional
    }
    
    public func updateTextViewHeight(){
        textInputHeightConstraint.constant = max(textInput.contentSize.height, 32)
    }
    
    public func textViewDidChange(_ textView: UITextView){
        updateTextViewHeight()
        view.layoutIfNeeded()
        //we would like to correct offset only if textview is fully visible
        if textView.frame.size.height == textView.contentSize.height { textView.setContentOffset(CGPoint.zero, animated: true) }
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.text == "") {
            textView.text = textfieldPlaceholderText
            textView.textColor = textfieldPlaceholderColor
        }
        textView.resignFirstResponder()
    }
}
