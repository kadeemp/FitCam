//
//  RealmManager.swift
//  FitCam
//
//  Created by Kadeem Palacios on 5/3/23.
//

import Foundation
import RealmSwift

@available(iOS 16.0, *)
class RealmManager {
    static let shared = RealmManager()
    private init() { }
    
    private lazy var realm: Realm = {
        do {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory = paths[0]
            let docURL = URL(string: documentsDirectory)
            
            let datapath = docURL?.appending(path: "FitCam-db.realm")
            print("datapath \(datapath)")
            
            let config =  Realm.Configuration(fileURL: datapath ,schemaVersion: 1, deleteRealmIfMigrationNeeded: true)
            return try Realm(configuration: config)
        } catch {
            fatalError("Failed to create Realm instance: \(error)")
        }
    }()
    
    func getRealm() -> Realm {
        return realm
    }
    // Add properties and methods for managing the Realm instance here.
}
