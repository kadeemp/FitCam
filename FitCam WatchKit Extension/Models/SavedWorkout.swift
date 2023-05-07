//
//  SavedWorkout.swift
//  FitCam WatchKit Extension
//
//  Created by Kadeem Palacios on 8/31/22.
//


import Foundation
import RealmSwift

class SavedWorkout: Object, Encodable{
    @Persisted @objc dynamic var workoutType = ""
    @Persisted @objc dynamic var date:String = Date().formatted(date: .abbreviated, time: .standard)
    @Persisted var dataPoints = List<Datapoint>()
    @Persisted var videoURL = ""
    
    enum CodingKeys: CodingKey {
        case workoutType
        case date
        case dataPoints
        case videoURL
    }
    override init() {
        super.init()
        self.workoutType = workoutType
        self.date = date
        self.dataPoints = dataPoints
        self.videoURL = videoURL
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(workoutType, forKey: .workoutType)
        try container.encode(date, forKey: .date)
        try container.encode(dataPoints, forKey: .dataPoints)
        try container.encode(videoURL, forKey: .videoURL)
    }
    

}

