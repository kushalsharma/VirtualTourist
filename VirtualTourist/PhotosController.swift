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

class PhotosController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PhotoResponseListener {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var getNewImagesButton: UIButton!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var stack: CoreDataStack? = nil
   
    var pin: Pin? = nil
    var images: [ImageData]?
    
    fileprivate var itemsPerRow: CGFloat = 3
    fileprivate let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let screenSize = UIScreen.main.bounds
        if Int(screenSize.width) > 500 {
            itemsPerRow = 6
        }
        stack = appDelegate.stack
        collectionView.delegate = self
        collectionView.dataSource = self
        
        reloadImagesFromStore()
        
        if images?.count == 0 {
            if pin?.pages != 0 {
                let pageNo: UInt32 = UInt32((pin?.pages)!) > 200 ? 200 : UInt32((pin?.pages)!)
                FlickrClient.getPhotoResponse(pin: pin!, pageNo: String(arc4random_uniform(pageNo) + 1), photoResponseListener: self)
            } else {
                getNewImagesButton.isEnabled = false
                getNewImagesButton.setTitle("Images not available", for: .normal)
            }
        }
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
        cell.photoImageView.backgroundColor = UIColor.lightGray
        cell.photoImageView.downloadedFrom(stack: stack!, imageData: (images?[indexPath.item])!)
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        stack?.context.delete((images?[indexPath.item])!)
        do {
            try stack?.saveContext()
        } catch {
            print("Error saving context")
        }
        reloadImagesFromStore()
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
    
    // MARK Flow layout callbacks
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) ->UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func reloadImagesFromStore() {
        images?.removeAll()
        images = imagesFetchRequest(pin: pin!)
        collectionView.reloadData()
    }
    
    @IBAction func getNewImagesClicked(_ sender: UIButton) {
        for image in images! {
            stack?.context.delete(image)
            do {
                try stack?.saveContext()
            } catch {
                print("Error saving context")
            }
        }
        let pageNo: UInt32 = UInt32((pin?.pages)!) > 200 ? 200 : UInt32((pin?.pages)!)
        FlickrClient.getPhotoResponse(pin: pin!, pageNo: String(arc4random_uniform(pageNo) + 1), photoResponseListener: self)
    }
    
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
        reloadImagesFromStore()
    }
    func onError() {
        // TODO show error
    }
}

// Image view extention

extension UIImageView {
    func downloadedFrom(stack: CoreDataStack, imageData: ImageData, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let imageBlob: Data = imageData.imageBlob as Data? else {
            let url = URL(string: imageData.url!)
            contentMode = mode
            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                    let data = data, error == nil,
                    let image = UIImage(data: data)
                    else { return }
                DispatchQueue.main.async() { () -> Void in
                    self.image = image
                    imageData.imageBlob = UIImagePNGRepresentation(image) as NSData?
                    do {
                        try stack.saveContext()
                    } catch {
                        print("Error saving context")
                    }
                }
                }.resume()
            return
        }
        self.image = UIImage(data: imageBlob as Data, scale: 1.0)
    }
}
