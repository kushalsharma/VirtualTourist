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
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: (stack?.context)!, sectionNameKeyPath: nil, cacheName: nil)
        do { return try stack!.context.fetch(fetchRequest) as! [ImageData]
        } catch {
            print("There was an error fetching the list of pins.")
            return [ImageData]()
        }
    }
}
