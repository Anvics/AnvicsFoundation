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

class ProgressComponentData: Equatable, FastDataCreatable{
    let progress: CGFloat
    
    init(progress: CGFloat) {
        self.progress = progress
    }
    
    required public init(data: CGFloat?){
        self.progress = data ?? 0
    }
}

func ==(lhs: ProgressComponentData, rhs: ProgressComponentData) -> Bool{
    return lhs.progress == rhs.progress
}

class ProgressComponent: UIView, FastComponent{
//    public typealias Data = ProgressComponentData
    static var emptyColor = UIColor.white
    static var fillColor = UIColor.green
    private let progressView = UIView()
    private let progressImage = UIImageView()
    var event: SafeSignal<Void> { SafeSignal(just: ()) }

    var progress: CGFloat = 0{
        didSet{ redraw() }
    }
    
    @IBInspectable var icon: UIImage? = nil{
        didSet{ updateIcon() }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if progressView.superview == nil{ setup() }
        progressView.frame = bounds
        redraw()
    }
    
    private func setup(){
        backgroundColor = ProgressComponent.emptyColor
        progressView.backgroundColor = ProgressComponent.fillColor
        addSubview(progressView)
        addSubview(progressImage)
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

    func update(data: ProgressComponentData) {
        progress = data.progress
    }
}

