//
//  Datapoint.swift
//  FitCam
//
//  Created by Kadeem Palacios on 8/31/22.
//

import Foundation
import CoreData

class Datapoint2:Encodable {
    var type: String
    var time: String
    var id: Int
    var datapoint: String
    
    enum CodingKeys: String, CodingKey {
        case type
        case time
        case id
        case datapoint
    }
    
    init(type: String, time: String, id: Int, datapoint: String) {
        self.type = type
        self.time = time
        self.id = id
        self.datapoint = datapoint
    }
    
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
    
            try container.encode(type, forKey: .type)
            try container.encode(time, forKey: .time)
            try container.encode(id, forKey: .id)
            try container.encode(datapoint, forKey: .datapoint)
        }
}
//
//class Datapoint2: NSManagedObject, Encodable {
//    
//    @NSManaged var type: String
//    @NSManaged var time: Date
//    @NSManaged var id: Int
//    @NSManaged var datapoint: String
////    @NSManaged var parentCategory: SavedWorkout?
//    
//    enum CodingKeys: String, CodingKey {
//        case type
//        case time
//        case id
//        case datapoint
//    }
//    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        
//        try container.encode(type, forKey: .type)
//        try container.encode(time, forKey: .time)
//        try container.encode(id, forKey: .id)
//        try container.encode(datapoint, forKey: .datapoint)
//    }
//}
