//
//  UIExtensions.swift
//  Hora
//
//  Created by Nikita Arkhipov on 17/06/2019.
//  Copyright © 2019 Hora. All rights reserved.
//

import UIKit

public extension UIImageView {
    override open func awakeFromNib() {
        super.awakeFromNib()
        tintColorDidChange()
    }
}

public extension CALayer{
    func removeAllSubLayers(){
        for l in sublayers ?? []{
            l.removeFromSuperlayer()
        }
    }
}

public extension Array where Element: UIView{
    func order(){
        for el in self{
            el.superview?.bringSubviewToFront(el)
        }
    }
}

public extension UIView{
    @IBInspectable var cornerRadius2: CGFloat {
        get { layer.cornerRadius }
        set { layer.cornerRadius = abs(CGFloat(Int(newValue * 100)) / 100) }
    }
    
    var rootView: UIView{ return superview?.rootView ?? self }

    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }

    var absolutePosition: CGPoint{
        return frame.origin + superview?.absolutePosition
    }
    
    func isVisible(inContainer: UIScrollView) -> Bool{
        let screenY = absolutePosition.y - inContainer.contentOffset.y - inContainer.absolutePosition.y
        return 0 <= screenY && screenY + frame.height < inContainer.frame.height
    }
    
    var screenPosition: CGPoint{
        return frame.origin - (self as? UIScrollView)?.contentOffset + superview?.screenPosition
    }
    
    func order(views: UIView...){
        for v in views{
            bringSubviewToFront(v)
        }
    }

    var absoluteContentOffset: CGPoint{
        return ((self as? UIScrollView)?.contentOffset ?? CGPoint.zero) + superview?.absoluteContentOffset
    }
    
    func removeAllSubviews(){
        for sub in subviews{
            sub.removeFromSuperview()
        }
    }
}

public extension URLSession{
    static func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}


public extension UIImage{
    static func imageFrom(url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            let image = UIImage(data: data)
            DispatchQueue.main.async() {
                completion(image)
            }
        }
    }
}

public extension UIScrollView {
    
    var offsetFrame: CGRect {
        return CGRect(x: -contentInset.left, y: -contentInset.top,
                      width: max(0, contentSize.width - bounds.width + contentInset.right + contentInset.left),
                      height: max(0, contentSize.height - bounds.height + contentInset.bottom + contentInset.top))
    }

    func absoluteLocation(for point: CGPoint) -> CGPoint {
        return point - contentOffset
    }

    func scrollTo(edge: UIRectEdge, animated: Bool) {
        let target: CGPoint
        switch edge {
        case UIRectEdge.top:
            target = CGPoint(x: contentOffset.x, y: offsetFrame.minY)
        case UIRectEdge.bottom:
            target = CGPoint(x: contentOffset.x, y: offsetFrame.maxY)
        case UIRectEdge.left:
            target = CGPoint(x: offsetFrame.minX, y: contentOffset.y)
        case UIRectEdge.right:
            target = CGPoint(x: offsetFrame.maxX, y: contentOffset.y)
        default:
            return
        }
        setContentOffset(target, animated: animated)
    }
}


public extension CGFloat{
    static var screenWidth: CGFloat { UIScreen.main.bounds.width }
    static var screenHeight: CGFloat { UIScreen.main.bounds.height }
}

public extension UIAlertController{
    func add(_ title: String, style: UIAlertAction.Style = .default, handler: EmptyBlock? = nil){
        addAction(UIAlertAction(title: title, style: style, handler: { _ in handler?() }))
    }
    
    func addCancel(){
        addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
    }
}

public extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

public extension UIButton {
    private func image(withColor color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }

    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        self.setBackgroundImage(image(withColor: color), for: state)
    }
}
