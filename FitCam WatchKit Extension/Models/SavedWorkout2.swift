//
//  SavedWorkout.swift
//  FitCam WatchKit Extension
//
//  Created by Kadeem Palacios on 8/31/22.
//


import Foundation
import CoreData

class SavedWorkout2:Encodable {
    var workoutType: String
    var date: String
    var dataPoints: [Datapoint2]
    var videoURL: String
    
        enum CodingKeys: String, CodingKey {
            case workoutType
            case date
            case dataPoints
            case videoURL
        }
    
    init(workoutType: String, date: String, dataPoints: [Datapoint2], videoURL: String) {
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

//class SavedWorkout2: NSManagedObject, Encodable {
//    
//    @NSManaged var workoutType: String
//    @NSManaged var date: String
//    @NSManaged var dataPoints: [Datapoint]
//    @NSManaged var videoURL: String
//    
//    enum CodingKeys: String, CodingKey {
//        case workoutType
//        case date
//        case dataPoints
//        case videoURL
//    }
//    
//    @NSManaged var context: NSManagedObjectContext? // Added context property
//    
//    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
//        super.init(entity: entity, insertInto: context)
//        self.context = context // Assign the provided context to the context property
//    }
//    
//    required convenience init(from decoder: Decoder) throws {
//        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else {
//            fatalError("Missing context information in decoder's user info.")
//        }
//        
//        guard let entity = NSEntityDescription.entity(forEntityName: "SavedWorkout", in: context) else {
//            fatalError("Failed to create entity description for SavedWorkout.")
//        }
//        
//        self.init(entity: entity, insertInto: context)
//        self.context = context // Assign the provided context to the context property
//        
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        workoutType = try container.decode(String.self, forKey: .workoutType)
//        date = try container.decode(String.self, forKey: .date)
//        dataPoints = try container.decode([Datapoint].self, forKey: .dataPoints)
//        videoURL = try container.decode(String.self, forKey: .videoURL)
//    }
//    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(workoutType, forKey: .workoutType)
//        try container.encode(date, forKey: .date)
//        try container.encode(dataPoints, forKey: .dataPoints)
//        try container.encode(videoURL, forKey: .videoURL)
//    }
//}
