//
//  RealmWrapper.swift
//  FitCam
//
//  Created by Kadeem Palacios on 5/3/23.
//

import RealmSwift
import SwiftUI

@available(iOS 16.0, *)
final class RealmWrapper: ObservableObject {
    @Published var workouts: Results<SavedWorkout>?

    var realm: Realm!
    
    func deleteWorkout(_ workout: SavedWorkout) {
        guard let realm = realm else {
            return
        }

        do {
            try realm.write {
                realm.delete(workout)
            }
        } catch {
            print("Failed to delete workout: \(error)")
        }
    }

    init() {
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)

        let datapath = docURL?.appending(path: "FitCam-db.realm")

        var config =  Realm.Configuration(fileURL: datapath ,schemaVersion: 1, deleteRealmIfMigrationNeeded: true)
        
        do {
            self.realm =  RealmManager.shared.getRealm()

//            print("realm fileurl:  \(self.realm.configuration.fileURL) ")
            workouts = self.realm.objects(SavedWorkout.self)
            print("list of workouts: \n \(workouts)")
            if let workouts = workouts {
                for workout in workouts {
                    print(workout)
                }
            }

        } catch {
            fatalError("failed to setup configuration. Error: \(error)")
        }
    }
}

