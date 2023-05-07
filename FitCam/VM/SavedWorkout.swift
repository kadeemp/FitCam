//
//  SavedWorkout.swift
//  FitCam
//
//  Created by Kadeem Palacios on 9/21/22.
//

import Foundation
import RealmSwift

class SavedWorkout: Object, Decodable {
    @Persisted @objc dynamic var workoutType = ""
    @Persisted @objc dynamic var date:String = Date().formatted(date: .abbreviated, time: .standard)
    @Persisted var dataPoints = List<Datapoint>()
    @Persisted var videoURL = ""
    
    enum CodingKeys:String,CodingKey {
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
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.workoutType = try container.decode(String.self, forKey: .workoutType)
        self.date = try container.decode(String.self, forKey: .date)
        self.dataPoints = try container.decode(List<Datapoint>.self, forKey: .dataPoints)
        self.videoURL = try container.decode(String.self, forKey: .videoURL)
        
    }
}
