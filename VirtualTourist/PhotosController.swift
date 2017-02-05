//
//  PhotosController.swift
//  VirtualTourist
//
//  Created by Kushal Sharma on 05/02/17.
//  Copyright © 2017 Kushal. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PhotosController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var stack: CoreDataStack? = nil
   
    var pin: Pin? = nil
    var images: [ImageData]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stack = appDelegate.stack
        collectionView.delegate = self
        collectionView.dataSource = self
        images = imagesFetchRequest(pin: pin!)
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (images?.count)!
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath as IndexPath) as! PhotoCell
        cell.photoImageView.image = nil
        cell.photoImageView.downloadedFrom(url: URL(string: images![indexPath.item].url!)!)
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
