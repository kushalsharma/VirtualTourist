//
//  PhotosController+FetchedResults.swift
//  VirtualTourist
//
//  Created by Kushal Sharma on 05/02/17.
//  Copyright © 2017 Kushal. All rights reserved.
//

import Foundation
import CoreData

extension PhotosController: NSFetchedResultsControllerDelegate  {
    func imagesFetchRequest(pin: Pin) -> [ImageData] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ImageData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "url", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: (stack?.context)!, sectionNameKeyPath: nil, cacheName: nil)
        do {
            let imageList = try stack!.context.fetch(fetchRequest) as! [ImageData]
            var filteredImageList: [ImageData] = Array()
            for image in imageList {
                if (image.lat == pin.latitude && image.lon == pin.longitude) {
                    filteredImageList.append(image)
                }
            }
            return filteredImageList
        } catch {
            print("There was an error fetching the list of pins.")
            return [ImageData]()
        }
    }
}
