//
//  GradientView.swift
//  Toyota
//
//  Created by Nikita Arkhipov on 21.03.17.
//  Copyright © 2017 Anvics. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond

@IBDesignable
public class GradientView: UIView {

    @IBInspectable public var startColor: UIColor = UIColor.gray{
        didSet { colors.value.0 = startColor; redraw() }
    }

    @IBInspectable public var endColor: UIColor = UIColor.gray{
        didSet { colors.value.1 = endColor; redraw() }
    }
    
    public let colors = Property<(UIColor, UIColor)>((.white, .white))
    
    private let gradientLayer = CAGradientLayer()
    
    private func redraw(){
        gradientLayer.frame = bounds

        gradientLayer.colors = [colors.value.0.cgColor, colors.value.1.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        if gradientLayer.superlayer == nil {
            layer.addSublayer(gradientLayer)
            _ = colors.dropFirst(1).observeNext { [unowned self] _ in self.redraw() }
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        redraw()
    }
}
