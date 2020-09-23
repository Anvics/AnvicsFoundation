//
//  VideoPlayerComponent.swift
//  BellisBox
//
//  Created by Nikita Arkhipov on 29.05.2020.
//  Copyright © 2020 Anvics. All rights reserved.
//

import UIKit
import ReactiveKit
import FastArchitecture
import Bond
import AVFoundation
import AVKit
import Kingfisher
import Animatics

class VideoPlayerData: Equatable, FastDataCreatable{
    let videoURL: URL?
    let placeHolderImage: String?
    let isPlaying: Bool?
    
    required public init(data: Bool?){
        self.videoURL = nil
        self.placeHolderImage = nil
        self.isPlaying = data
    }
    
    init(videoURL: URL? = nil, placeHolderImage: String? = nil, isPlaying: Bool? = nil) {
        self.videoURL = videoURL
        self.placeHolderImage = placeHolderImage
        self.isPlaying = isPlaying
    }
}

func ==(lhs: VideoPlayerData, rhs: VideoPlayerData) -> Bool{
    return lhs.isPlaying == rhs.isPlaying && lhs.placeHolderImage == rhs.placeHolderImage && lhs.videoURL == rhs.videoURL
}

class VideoPlayerComponent: UIView, FastComponent {

    var event: SafeSignal<Void> { SafeSignal(just: ()) }
    
    static var placeholderImage: UIImage? = nil
    
    private var player: AVQueuePlayer!
    private var videoLooper: AVPlayerLooper!
    private var playerLayer: AVPlayerLayer!
    private var currentURL: URL?
    private let imageView = UIImageView()
    private let videoPlayerContaiverView = UIView()
    
    private var isSetuped = false
    private var observer: Any?
    private var previousTimeValue: Int64 = 0
    
    let isPlaying = Property(false)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
        imageView.frame = bounds
        imageView.backgroundColor = .white
        videoPlayerContaiverView.frame = bounds
        if !isSetuped { setup() }
    }
    
    private func setup(){
        isSetuped = true
        layer.masksToBounds = true
        videoPlayerContaiverView.backgroundColor = .clear
        addSubview(videoPlayerContaiverView)
        addSubview(imageView)

        isPlaying.bind(to: imageView.reactive.isHidden)
    }

    func update(data: VideoPlayerData) {
        resolve(data.videoURL) { update(url: $0) }

        resolve(data.placeHolderImage?.url) { imageView.kf.setImage(with: $0, placeholder: UIImage()) }
        resolve(data.isPlaying) {
            $0 ? player?.play() : player?.pause()
            if !$0 { isPlaying.value = false }
        }
    }
    
    private func updateImage(url: String){
        if let u = url.url, !url.isEmpty {
            imageView.contentMode = .scaleAspectFill
            imageView.image = nil
            imageView.kf.setImage(with: u)
        }else{
            imageView.contentMode = .center
            imageView.image = VideoPlayerComponent.placeholderImage
        }
    }
        
    private func update(url: URL){
        if currentURL == url { return }
        reactive.bag.dispose()
        
        currentURL = url
        videoPlayerContaiverView.layer.removeAllSubLayers()
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        
        if let obs = observer, let player = player { player.removeTimeObserver(obs) }
        isPlaying.value = false
        previousTimeValue = 0

        player = AVQueuePlayer(playerItem: playerItem)
        player.pause()

        observer = player.addPeriodicTimeObserver(forInterval: CMTime(value: 2, timescale: 4), queue: DispatchQueue.main) { [weak self] time in
            guard let s = self else { return }
            s.isPlaying.value = time.value > 0 && time.value != s.previousTimeValue
            s.previousTimeValue = time.value
        }
        
        videoLooper = AVPlayerLooper(player: player, templateItem: playerItem)
        
        playerLayer?.removeFromSuperlayer()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = bounds //bounds of the view in which AVPlayer should be displayed
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.backgroundColor = UIColor.clear.cgColor
        videoPlayerContaiverView.layer.addSublayer(playerLayer)
    }
}

class VideoPlayerControlsComponent: UIView, FastComponent {
    
    var event: SafeSignal<Void> { SafeSignal(just: ()) }
    
    static var placeholderImage: UIImage? = nil
    
    private var currentURL: URL?
    private let imageView = UIImageView()
//    private let videoPlayerContaiverView = UIView()
    
    private var isSetuped = false
    private var observer: Any?
    private var previousTimeValue: Int64 = 0
    
    let playerController = AVPlayerViewController()
    var player: AVPlayer?

    let isReady = Property(false)
//    let isPlaying = Property(false)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerController.view.frame = bounds
        imageView.frame = bounds
        imageView.backgroundColor = .white
//        imageView.alpha = 0.5
//        videoPlayerContaiverView.frame = bounds
        if !isSetuped { setup() }
    }
    
    private func setup(){
        func animator(isHidden: Bool) -> AnimaticsReady{
            AlphaAnimator(isHidden ? 0 : 1).duration(0.5).to(imageView)
        }
        
        isSetuped = true
//        layer.masksToBounds = true
        playerController.showsPlaybackControls = true

//        videoPlayerContaiverView.backgroundColor = .clear
        addSubview(playerController.view)
        
        addSubview(imageView)
        

//        isReady.debounce(for: 0.35, queue: .main).filter { $0 }.bind(to: imageView.reactive.isHidden)
//        isReady.filter { !$0 }.bind(to: imageView.reactive.isHidden)
        isReady.debounce(for: 0.3, queue: .main).when(value: true).animate(animator(isHidden: true))
        isReady.when(value: false).animate(animator(isHidden: false))
    }

    func update(data: VideoPlayerData) {
        resolve(data.videoURL) { update(url: $0) }

        resolve(data.placeHolderImage?.url) { imageView.kf.setImage(with: $0, placeholder: UIImage()) }
        resolve(data.isPlaying) {
            $0 ? player?.play() : player?.pause()
            if !$0 { isReady.value = false }
        }
    }
    
    private func updateImage(url: String){
        if let u = url.url, !url.isEmpty {
            imageView.contentMode = .scaleAspectFill
            imageView.image = nil
            imageView.kf.setImage(with: u)
        }else{
            imageView.contentMode = .center
            imageView.image = VideoPlayerComponent.placeholderImage
        }
    }
        
    private func update(url: URL){
        if currentURL == url { return }
        reactive.bag.dispose()
        player = AVPlayer(url: url)
        playerController.player = player
        isReady.value = false
        player!.reactive.keyPath(\.timeControlStatus).map { $0 == .playing }.when(value: true).replaceElements(with: true).bind(to: isReady).dispose(in: reactive.bag)
//        player!.reactive.keyPath(\.status).map { $0 == .readyToPlay }.bind(to: isReady).dispose(in: reactive.bag)

    }
}
