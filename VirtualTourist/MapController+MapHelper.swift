//
//  MapController+MapDeligate.swift
//  VirtualTourist
//
//  Created by Kushal Sharma on 05/02/17.
//  Copyright © 2017 Kushal. All rights reserved.
//

import Foundation
import MapKit
import CoreData

extension MapController {
    func handleLongPress(_ getstureRecognizer : UIGestureRecognizer) {
        if getstureRecognizer.state != .began { return }
        let touchPoint = getstureRecognizer.location(in: self.mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = touchMapCoordinate

        // Find out the location name based on the coordinates
        let coordinates = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(coordinates, completionHandler: { (placemark, error) -> Void in
            if error != nil {
                print("Error: \(error!.localizedDescription)")
                return
            }
            if placemark!.count > 0 {
                let pm = placemark![0] as CLPlacemark
                if (pm.locality != nil) && (pm.country != nil) {
                    // Assigning the city and country to the annotation's title
                    annotation.title = "\(pm.locality!), \(pm.country!)"
                } else {
                    annotation.title = "Unknown"
                }
                
                // add annotation to core data and store Lat / Long in core data
                if let entity = NSEntityDescription.entity(forEntityName: "Pin", in: (self.stack?.context)!) {
                    let pin = Pin(entity: entity, insertInto: self.stack?.context)
                    pin.latitude = annotation.coordinate.latitude
                    pin.longitude = annotation.coordinate.longitude
                    pin.title = annotation.title
                    do {
                        try self.stack?.saveContext()
                    } catch {
                        print("Error saving context")
                    }
                    FlickrClient.getPhotoResponse(pin: pin, pageNo: "1", photoResponseListener: self)
                    self.resetMapPins()
                }
            } else {
                print("Error with placemark")
            }
        })
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let lat = view.annotation?.coordinate.latitude
            let lon = view.annotation?.coordinate.longitude
            currentPin = getCurrentPin(lat: lat!, lon: lon!)
            performSegue(withIdentifier: "showPhotos", sender: self)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func getCurrentPin(lat: Double, lon: Double) -> Pin {
        for pin in pinList! {
            if (pin.latitude == lat && pin.longitude == lon) {
                return pin
            }
        }
        return Pin()
    }
}
