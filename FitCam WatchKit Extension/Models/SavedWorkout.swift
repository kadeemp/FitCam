//
//  SavedWorkout.swift
//  FitCam WatchKit Extension
//
//  Created by Kadeem Palacios on 8/31/22.
//


import Foundation
import RealmSwift

class SavedWorkout: Object {
    @Persisted @objc dynamic var workoutType = ""
    @Persisted @objc dynamic var date:String = Date().formatted(date: .abbreviated, time: .standard)
    @Persisted var dataPoints = List<Datapoint>()
    @Persisted var videoURL = ""
    
}

