//
//  Photos.swift
//  VirtualTourist
//
//  Created by Kushal Sharma on 04/02/17.
//  Copyright © 2017 Kushal. All rights reserved.
//

import Foundation

struct PhotoResponse {
    struct Photos {
        struct PhotoItem {
            let farm: Int
            let heightO: String?
            let heightQ: String
            let id: String
            let isfamily: Int
            let isfriend: Int
            let ispublic: Int
            let owner: String
            let secret: String
            let server: String
            let title: String
            let urlO: String?
            let urlQ: String
            let widthO: String?
            let widthQ: String
        }
        let page: Int
        let pages: Int
        let perpage: Int
        let photo: [PhotoItem]
        let total: String
    }
    let photos: Photos
    let stat: String
    
}

enum JsonParsingError: Error {
    case unsupportedTypeError
}

extension Array {
    init(jsonValue: Any?, map: (Any) throws -> Element) throws {
        guard let items = jsonValue as? [Any] else {
            throw JsonParsingError.unsupportedTypeError
        }
        self = try items.map(map)
    }
}

extension Int {
    init(jsonValue: Any?) throws {
        if let number = jsonValue as? NSNumber {
            self = number.intValue
        } else if let number = jsonValue as? Int {
            self = number
        } else if let number = jsonValue as? Double {
            self = Int(number)
        } else if let number = jsonValue as? Float {
            self = Int(number)
        } else {
            throw JsonParsingError.unsupportedTypeError
        }
    }
}

extension Optional {
    init(jsonValue: Any?, map: (Any) throws -> Wrapped) throws {
        if let jsonValue = jsonValue, !(jsonValue is NSNull) {
            self = try map(jsonValue)
        } else {
            self = nil
        }
    }
}

extension String {
    init(jsonValue: Any?) throws {
        guard let string = jsonValue as? String else {
            throw JsonParsingError.unsupportedTypeError
        }
        self = string
    }
}

extension PhotoResponse {
    init(jsonValue: Any?) throws {
        guard let dict = jsonValue as? [String: Any] else {
            throw JsonParsingError.unsupportedTypeError
        }
        self.stat = try String(jsonValue: dict["stat"])
        self.photos = try PhotoResponse.Photos(jsonValue: dict["photos"])
    }
}

extension PhotoResponse.Photos {
    init(jsonValue: Any?) throws {
        guard let dict = jsonValue as? [String: Any] else {
            throw JsonParsingError.unsupportedTypeError
        }
        self.pages = try Int(jsonValue: dict["pages"])
        self.photo = try Array(jsonValue: dict["photo"]) { try PhotoResponse.Photos.PhotoItem(jsonValue: $0) }
        self.total = try String(jsonValue: dict["total"])
        self.page = try Int(jsonValue: dict["page"])
        self.perpage = try Int(jsonValue: dict["perpage"])
    }
}

extension PhotoResponse.Photos.PhotoItem {
    init(jsonValue: Any?) throws {
        guard let dict = jsonValue as? [String: Any] else {
            throw JsonParsingError.unsupportedTypeError
        }
        self.heightQ = try String(jsonValue: dict["height_q"])
        self.owner = try String(jsonValue: dict["owner"])
        self.heightO = try Optional(jsonValue: dict["height_o"]) { try String(jsonValue: $0) }
        self.secret = try String(jsonValue: dict["secret"])
        self.urlO = try Optional(jsonValue: dict["url_o"]) { try String(jsonValue: $0) }
        self.widthO = try Optional(jsonValue: dict["width_o"]) { try String(jsonValue: $0) }
        self.urlQ = try String(jsonValue: dict["url_q"])
        self.widthQ = try String(jsonValue: dict["width_q"])
        self.farm = try Int(jsonValue: dict["farm"])
        self.ispublic = try Int(jsonValue: dict["ispublic"])
        self.server = try String(jsonValue: dict["server"])
        self.isfriend = try Int(jsonValue: dict["isfriend"])
        self.isfamily = try Int(jsonValue: dict["isfamily"])
        self.id = try String(jsonValue: dict["id"])
        self.title = try String(jsonValue: dict["title"])
    }
}

func parsePhotoResponse(jsonValue: Any?) throws -> PhotoResponse {
    return try PhotoResponse(jsonValue: jsonValue)
}

