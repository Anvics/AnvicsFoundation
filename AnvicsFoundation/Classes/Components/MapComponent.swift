//
//  MapComponent.swift
//  BellisBox
//
//  Created by Nikita Arkhipov on 10.06.2020.
//  Copyright © 2020 Anvics. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit
import FastArchitecture
//import YandexMapKit
import MapKit

class MapViewData: Equatable{
    let hash: Int
    var zoom: Double?
    var centerToPerson: Bool?
    
    init(hash: Int, zoom: Double? = nil, centerToPerson: Bool? = nil) {
        self.hash = hash
        self.zoom = zoom
        self.centerToPerson = centerToPerson
    }
}

func ==(lhs: MapViewData, rhs: MapViewData) -> Bool{
    return lhs.hash == rhs.hash
}

class MapViewComponent: UIView, FastComponent{
    let map = MKMapView()
    public var event: SafeSignal<Void> { return SafeSignal(just: ()) }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        map.frame = bounds
        if map.superview != nil { return }
        addSubview(map)
        map.clearsContextBeforeDrawing = true
        map.showsUserLocation = true
    }
    
    public func update(data: MapViewData) {
        resolve(data.zoom) { self.zoomMap(by: $0) }
        resolve(data.centerToPerson) { if $0 { self.centerOnUser() } }
    }
    
    func zoomMap(by delta: Double) {
        var region: MKCoordinateRegion = map.region
        var span: MKCoordinateSpan = map.region.span
        span.latitudeDelta *= delta
        span.longitudeDelta *= delta
        region.span = span
        map.setRegion(region, animated: true)
    }
    
    func centerOnUser(){
        map.showsUserLocation = true
        guard let location = map.userLocation.location?.coordinate else { return }
        map.setCenter(location, animated: true)
    }
}

//protocol MapComponentAnnotation: MKAnnotation, Equatable { }
//
//class MapComponentConnector<Annotation: MapComponentAnnotation, View: MKAnnotationView, Action>: NSObject, FastListConnectorType, MKMapViewDelegate{
//    typealias AnnotationProducer = (Annotation) -> MKAnnotationView?
//    var reducer: Subject<Action, Never>?
//
//    var items: [Annotation] = []
//
//    let mapView: MapViewComponent
//    var cellPressed: CellPressedListener?
//    var shouldIgnoreDuplicates: Bool { true }
//
//    init(_ mapView: MapViewComponent){
//        self.mapView = mapView
//        super.init()
//        if #available(iOS 11.0, *){
//            mapView.map.register(View.self, forAnnotationViewWithReuseIdentifier: "\(View.self)")
//        }
//        mapView.map.delegate = self
//    }
//
//    func update(with: [Annotation]) {
//        var removeAnnotations: [Annotation] = []
//        for a in items{
//            if !with.contains(a) { removeAnnotations.append(a) }
//        }
//        var appendAnnotations: [Annotation] = []
//        for a in with{
//            if !items.contains(a) { appendAnnotations.append(a) }
//        }
//        items = with
//        mapView.map.removeAnnotations(removeAnnotations)
//        mapView.map.addAnnotations(appendAnnotations)
//        let cords = with.map { $0.coordinate }
//        mapView.map.zoom(to: cords, meter: 100, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
//    }
//
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        guard let annotation = annotation as? Annotation else { return nil }
//
//        var view: MKAnnotationView
//        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: "\(View.self)") as? View {
//            dequeuedView.annotation = annotation
//            view = dequeuedView
//        } else {
//            view = View(annotation: annotation, reuseIdentifier: "\(View.self)")
//            view.annotation = annotation
//        }
//        return view
//    }
//
//    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView){
//        guard let a = view.annotation as? Annotation, let i = items.firstIndex(of: a) else { return }
//        cellPressed?(i)
//    }
//}
