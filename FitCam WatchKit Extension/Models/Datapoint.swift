//
//  Datapoint.swift
//  FitCam
//
//  Created by Kadeem Palacios on 8/31/22.
//

import Foundation
import RealmSwift

class Datapoint: Object {
    
    @Persisted  @objc dynamic var type:String
    @Persisted  @objc dynamic var time = Date().formatted(date: .omitted, time: .standard)
    @Persisted  @objc dynamic var id:Int = 0
    @Persisted  @objc dynamic var datapoint:String = ""
    var parentCategory = LinkingObjects(fromType: SavedWorkout.self, property: "datapoints")
    
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
