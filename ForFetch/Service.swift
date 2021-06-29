//
//  Service.swift
//  ForFetch
//
//  Created by nabi jung on 6/25/21.
//

import Foundation
import Alamofire
import ObjectMapper

class Service: NSObject {
    
    static let sharedInstance = Service()
    
    let url = "https://api.seatgeek.com/2/events"
    
    var queryParameters: [String: Any] = [
        "client_id": "MjIzNTAzMTd8MTYyNDU5ODg0Ny4zNDIzMzQ3",
        "client_secret": "087eccc34ce1618182a5aa00dd4030472ea3451e9dd0009e660370a35af85dc8",
        "page": 1,
      ]
    
    func callAPI(query: String, completion: @escaping(Bool, [Event])->Void){
        
        let queryString = query.replacingOccurrences(of: " ", with: "+")
        
        if query != "" {
            queryParameters["q"] = queryString
        }
        
        var events = [Event]()
        
        AF.request(url, parameters: queryParameters).responseJSON { response in
            if response.error == nil {
                let jsondata = response.value as? [String:Any]
                let eventsArray = jsondata?["events"] as! [[String : Any]]
                for i in eventsArray.indices {
                    if let event = Event.init(JSON: eventsArray[i]) {
                        let performersData = eventsArray[i]["performers"] as? [[String:Any]]
                        if let image = performersData?[0]["image"] as? String {
                            event.imageURL = image
                        }
                        
                        if let venueData = eventsArray[i]["venue"] as? [String:Any] {
                            event.mapping(map: Map.init(mappingType: .fromJSON, JSON: venueData))
                        }
                        
                        events.append(event)
                    }
                }
                completion(false, events)
            } else {
                completion(true, [])
            }
        }
    }
}
