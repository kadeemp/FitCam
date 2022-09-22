//
//  Datapoint.swift
//  FitCam
//
//  Created by Kadeem Palacios on 9/21/22.
//
import Foundation
import RealmSwift

class Datapoint: Object, Decodable{
    
    @Persisted  @objc dynamic var type:String
    @Persisted  @objc dynamic var time = Date().formatted(date: .omitted, time: .standard)
    @Persisted  @objc dynamic var id:Int = 0
    @Persisted  @objc dynamic var datapoint:String = ""
    var parentCategory = LinkingObjects(fromType: SavedWorkout.self, property: "datapoints")
    
    enum CodingKeys: String, CodingKey {
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
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.type = try container.decode(String.self, forKey: .type)
        self.time = try container.decode(String.self, forKey: .time)
        self.id = try container.decode(Int.self, forKey: .id )
        self.datapoint = try container.decode(String.self, forKey: .datapoint)
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
