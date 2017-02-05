//
//  MapController+PhotoRequest.swift
//  VirtualTourist
//
//  Created by Kushal Sharma on 05/02/17.
//  Copyright © 2017 Kushal. All rights reserved.
//

import Foundation
import CoreData

extension MapController: PhotoResponseListener {
    func onSuccess(photoResponse: PhotoResponse, pin: Pin) {
        for photo in photoResponse.photos.photo {
            if let entity = NSEntityDescription.entity(forEntityName: "ImageData", in: (self.stack?.context)!) {
                let imageData = ImageData(entity: entity, insertInto: self.stack?.context)
                imageData.url = photo.urlQ
                imageData.lat = pin.latitude
                imageData.lon = pin.longitude
                imageData.pin = pin
            }
        }
        do {
            try self.stack?.saveContext()
        } catch {
            print("Error saving context")
        }
    }
    func onError() {
        // TODO show error
    }
}
