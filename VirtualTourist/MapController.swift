//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Kushal Sharma on 04/02/17.
//  Copyright © 2017 Kushal. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var stack: CoreDataStack?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var currentPin: Pin?
    var pinList: [Pin]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stack = appDelegate.stack
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(MapController.handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressRecogniser)
        mapView.delegate = self
        resetMapPins()
    }
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        didSet { fetchedResultsController?.delegate = self }
    }
    
    init(fetchedResultsController fc: NSFetchedResultsController<NSFetchRequestResult>) {
        fetchedResultsController = fc
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhotos" {
            let photosController: PhotosController = segue.destination as! PhotosController
            photosController.pin = currentPin
        }
    }
    
    func resetMapPins(){
        pinList?.removeAll()
        pinList = pinFetchRequest()
        for pin in pinList! {
            let annotation = MKPointAnnotation()
            annotation.coordinate.latitude = pin.latitude
            annotation.coordinate.longitude = pin.longitude
            annotation.title = pin.title
            mapView.addAnnotation(annotation)
        }
    }
}

