//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Kushal Sharma on 04/02/17.
//  Copyright © 2017 Kushal. All rights reserved.
//

import Foundation

class FlickrClient {
    static func getPhotoResponse(pin: Pin, pageNo: String, photoResponseListener: PhotoResponseListener) {
        let request = NSMutableURLRequest(url: URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=661ef4740d9a403b8c15cf0599970d01&lat=\(pin.latitude)&lon=\(pin.longitude)&per_page=20&format=json&nojsoncallback=1&extras=url_q,url_o&page=\(pageNo)")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error…
                DispatchQueue.main.async {
                    photoResponseListener.onError()
                }
                return
            }
            let response = response as! HTTPURLResponse
            let statusCode: Int = response.statusCode
            if statusCode >= 200 && statusCode <= 299 {
                let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                let photoResponse: PhotoResponse?
                do {
                    photoResponse = try PhotoResponse.init(jsonValue: json)
                    DispatchQueue.main.async {
                        photoResponseListener.onSuccess(photoResponse: photoResponse!, pin: pin)
                    }
                } catch {
                    photoResponse = nil
                    DispatchQueue.main.async {
                        photoResponseListener.onError()
                    }
                }
            }
        }
        task.resume()
    }
}

protocol PhotoResponseListener {
    func onSuccess(photoResponse: PhotoResponse, pin: Pin)
    
    func onError()
}
