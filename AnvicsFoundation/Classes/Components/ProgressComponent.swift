//
//  ProgressComponent.swift
//  Foodbook
//
//  Created by Nikita Arkhipov on 28/02/2020.
//  Copyright © 2020 Anvics. All rights reserved.
//

import UIKit
import ReactiveKit
import FastArchitecture
import Bond
import Animatics

public class ProgressComponentData: Equatable, FastDataCreatable{
    let progress: CGFloat
    
    public init(progress: CGFloat) {
        self.progress = progress
    }
    
    required public init(data: CGFloat?){
        self.progress = data ?? 0
    }
}

public func ==(lhs: ProgressComponentData, rhs: ProgressComponentData) -> Bool{
    return lhs.progress == rhs.progress
}

public class ProgressComponent: UIView, FastComponent{
//    public typealias Data = ProgressComponentData
    public static var emptyColor = UIColor.white
    public static var fillColor = UIColor.green
    private let progressView = UIView()
    private let progressImage = UIImageView()
    public var event: SafeSignal<Void> { SafeSignal(just: ()) }

    public var progress: CGFloat = 0{
        didSet{ redraw() }
    }
    
    @IBInspectable public var emptyColor: UIColor? = nil{
        didSet { updateProgressColors() }
    }

    @IBInspectable public var fillColor: UIColor? = nil{
        didSet { updateProgressColors() }
    }
    
    @IBInspectable public var icon: UIImage? = nil{
        didSet{ updateIcon() }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if progressView.superview == nil{ setup() }
        progressView.frame = bounds
        redraw()
    }
    
    private func setup(){
        addSubview(progressView)
        addSubview(progressImage)
        updateProgressColors()
    }
    
    private func updateProgressColors(){
        backgroundColor = emptyColor ?? ProgressComponent.emptyColor
        progressView.backgroundColor = fillColor ?? ProgressComponent.fillColor
    }
    
    private func updateIcon(){
        clipsToBounds = false
        layer.masksToBounds = false
        progressImage.image = icon
        progressImage.frame.size = icon?.size ?? CGSize.zero
        redraw()
    }

    private func redraw(){
        let x = bounds.size.width * progress
        progressView.frame.size.width = x
        progressImage.center = CGPoint(x: x, y: 3 + bounds.size.height / 2)
    }

    public func update(data: ProgressComponentData) {
        progress = data.progress
    }
}

