//
//  Event.swift
//  ForFetch
//
//  Created by nabi jung on 6/25/21.
//

import Foundation
import ObjectMapper

class Event: Mappable {
    
    var id: Int?
    var title: String?
    var city = String()
    var state = String()
    var datetime: String?
    var imageURL = String()
    var isFavorite = Bool()
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id            <- map["id"]
        title         <- map["title"]
        datetime      <- map["datetime_utc"]
        city          <- map["city"]
        state         <- map["state"]
    }
    
    
}
