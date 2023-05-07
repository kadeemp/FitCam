//
//  Datapoint.swift
//  FitCam
//
//  Created by Kadeem Palacios on 8/31/22.
//

import Foundation
import RealmSwift

class Datapoint: Object, Encodable {
    
    @Persisted  @objc dynamic var type:String
    @Persisted  @objc dynamic var time = Date().formatted(date: .omitted, time: .standard)
    @Persisted  @objc dynamic var id:Int = 0
    @Persisted  @objc dynamic var datapoint:String = ""
    var parentCategory = LinkingObjects(fromType: SavedWorkout.self, property: "datapoints")
    
    
    enum CodingKeys:CodingKey {
        case type
        case time
        case id
        case datapoint
    }
    
    override init() {
        super.init()
        self.type = type
        self.time = time
        self.id = id
        self.datapoint = datapoint
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.type, forKey: .type)
        try container.encode(self.time, forKey: .time)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.datapoint, forKey: .datapoint)
    }
//    init(type:String,
//         time:String,
//         id:Int,
//         datapoint:String) {
//        self.type = type
//        self.time = time
//        self.id = id
//        self.datapoint = datapoint
//    }
}
