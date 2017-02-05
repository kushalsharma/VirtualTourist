//
//  MapController+FetchedResults.swift
//  VirtualTourist
//
//  Created by Kushal Sharma on 05/02/17.
//  Copyright © 2017 Kushal. All rights reserved.
//

import Foundation
import CoreData

extension MapController: NSFetchedResultsControllerDelegate {
    func pinFetchRequest() -> [Pin] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true), NSSortDescriptor(key: "longitude", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: (stack?.context)!, sectionNameKeyPath: nil, cacheName: nil)
        do {
            return try stack!.context.fetch(fetchRequest) as! [Pin]
        } catch {
            print("There was an error fetching the list of pins.")
            return [Pin]()
        }
    }
}
