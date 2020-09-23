//
//  ReactiveExtensions.swift
//  Cazila
//
//  Created by Nikita Arkhipov on 13/11/2018.
//  Copyright © 2018 Nikita Arkhipov. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond
import Kingfisher

public extension ReactiveExtensions where Base: UIRefreshControl  {
    var isAnimating: Bond<Bool> {
        return bond {
            if $1 { $0.beginRefreshing() }
            else { $0.endRefreshing() }
        }
    }
}

public extension ReactiveExtensions where Base: NSLayoutConstraint  {
    var constant: Bond<CGFloat> {
        return bond { $0.constant = $1 }
    }
}

public extension ReactiveExtensions where Base: UIImageView  {
    var imageURL: Bond<String> {
        return bond {
            if let url = URL(string: $1), $1 != "" { $0.kf.setImage(with: url) }
            else { $0.image = nil }
        }
    }
}


public extension ReactiveExtensions where Base: UIView {
    var isFirstResponder: Bond<Bool> {
        return bond { view, isFirst in
            _ = isFirst ? view.becomeFirstResponder() : view.resignFirstResponder()
        }
    }
    
    var resignFirstResponder: Bond<Void> {
        return bond { view, _ in
            view.resignFirstResponder()
        }
    }
}

public extension ReactiveExtensions where Base: UIViewController {
    var resignFirstResponder: Bond<Void> {
        return bond { view, _ in
            view.resignFirstResponder()
        }
    }
}

public extension ReactiveExtensions where Base: UIView {
    var borderWidth: Bond<CGFloat> {
        return bond { $0.layer.borderWidth = $1 }
    }
}

public extension ReactiveExtensions where Base: UIButton {
    var textColor: Bond<UIColor?> {
        return bond { $0.setTitleColor($1, for: .normal) }
    }
}

public extension SignalProtocol where Self.Element : Equatable {
    func when(value: Self.Element) -> ReactiveKit.Signal<Void, Self.Error>{
        return filter { $0 == value }.eraseType()
    }
}

public extension ReactiveExtensions where Base: UITextView{
    var textAndLayout: Bond<String?> {
        return bond { textView, text in
            textView.text = ""
            textView.insertText(text ?? "")
            textView.rootView.layoutIfNeeded()
        }
    }
}

public extension SignalProtocol where Self.Element : ReactiveKit.OptionalProtocol {
    func isNil() -> Signal<Bool, Self.Error>{
        return map { $0._unbox == nil }
    }
}

public protocol BooleanType {
    var value: Bool { get }
}

extension Bool: BooleanType{
    public var value: Bool { return self }
}

public extension SignalProtocol where Self.Element: BooleanType{
    func inverse() -> Signal<Bool, Self.Error>{
        return map { !$0.value }
    }
}
