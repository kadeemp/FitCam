//
//  AppDelegate.swift
//  FitCam
//
//  Created by Kadeem Palacios on 9/10/22.
//

import Foundation
import UIKit
import WatchConnectivity
import RealmSwift
import SwiftUI

@available(iOS 16.0, *)
class AppDelegate:NSObject,ObservableObject, UIApplicationDelegate, WCSessionDelegate {
    //MARK:- Instance Vars
    
    var realm:Realm!
    static let shared = AppDelegate()
    //MARK:- Init
    
   
    func initializeVideoDirectory() {
        let videoPath = "WorkoutVideos"
        do {
            var documentDirectory = try FileManager.default.url(for: .documentDirectory , in: .userDomainMask, appropriateFor: nil, create: false)
            documentDirectory.append(path: videoPath)
            print("directory \(documentDirectory) \n path \(documentDirectory.path)")
            let fileExists = FileManager.default.fileExists(atPath: documentDirectory.path)
            if !fileExists {
                try FileManager.default.createDirectory(atPath: documentDirectory.path, withIntermediateDirectories: true)
                print("Directory Created")
            } else {
                let contents = try FileManager.default.contentsOfDirectory(atPath:documentDirectory.path)
                print("contents of doc directory \(contents)")
            }
        }
        catch {
            print(error,"\n")
            print("Error creating documents directory")
        }
    }

    func initializeRealm() {
       
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)
        
        let datapath = docURL?.appending(path: "FitCam-db.realm")
            
            var config =  Realm.Configuration(fileURL: datapath ,schemaVersion: 1, deleteRealmIfMigrationNeeded: true)
        DispatchQueue.main.async {
            do {
                try self.realm = Realm(configuration: config)
//                print("realm fileurl:  \(self.realm.configuration.fileURL) ")
//                print("list of workouts: \n \(workouts)")
            } catch {
                print("failed to setup configuration. Error: \(error)")
            }
        }
    }
    
    //MARK:- Database Nuke Options
    func nukeRealm() {
        
            DispatchQueue.main.async {
                do {
                    let workouts = self.realm.objects(SavedWorkout.self)
                    try self.realm.write({
                        self.realm.deleteAll()
                    })
                    print("Realm successfully nuked")
                }
                catch {
                    print("Error nuking Realm")
                }
            }
    }
   
    func nukeDirectory() {
        let videoPath = "WorkoutVideos"
        do {
            var documentDirectory = try FileManager.default.url(for: .documentDirectory , in: .userDomainMask, appropriateFor: nil, create: false)
            documentDirectory.append(path: videoPath)
//            print("directory \(documentDirectory.path) \n")
            let fileExists = FileManager.default.fileExists(atPath: documentDirectory.path)
        
            if fileExists {
                let contents = try FileManager.default.contentsOfDirectory(atPath:documentDirectory.path)
                for file in contents {
                    print("\(documentDirectory.path) / \(file)")
                    try FileManager.default.removeItem(atPath: documentDirectory.path + "/" + file)
                }
                print("contents \(contents)")
            }
            
        }
        catch {
            print("Error Deleting documents directory")
            print(error,"\n")
        }
    }
    
    
    func deleteWorkout(_ workout:SavedWorkout) {
        do {
            DispatchQueue.main.async {
                try! self.realm.write {
                    self.realm.delete(workout)
                    print("workout deleted!")
                }
            }
        }
    }
    func saveNewWorkout(_ workout:SavedWorkout) {
       
            do {
                DispatchQueue.main.async {
                    try! self.realm.write {
                        self.realm.add(workout)
                        print("workout saved!")
                    }
                }
            }
    }

    func getWorkouts(closure:@escaping ((Results<SavedWorkout>?) -> Void )) {
        getRealm { thisRealm in
            let workouts = thisRealm.objects(SavedWorkout.self)
            closure(workouts)
        }
                   
    }
    
    func getRealm(closure:@escaping ((Realm) -> Void )) {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)
        
        let datapath = docURL?.appending(path: "FitCam-db.realm")
            
           let config = Realm.Configuration(fileURL: datapath ,schemaVersion: 1, deleteRealmIfMigrationNeeded: true)
        DispatchQueue.main.async {
            do {
                try self.realm = Realm(configuration: config)
                //                print("realm fileurl:  \(self.realm.configuration.fileURL) ")
                closure(self.realm)
                //                print("list of workouts: \n \(workouts)")
            } catch {
                print("failed to setup configuration. Error: \(error)")
            }
        }
    }
    
    //MARK:- Watchkit Delegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }


    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
                do {
                    let receivedWorkout = try JSONDecoder().decode(SavedWorkout.self, from: messageData)
                    print("Decoded data: \n \(receivedWorkout)")
                    saveNewWorkout(receivedWorkout)
                }
                catch {
                    print("error decoding message: \(error)")
                }
    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
                guard let request = message["request"] as? String else {
        
                    replyHandler([:])
                    return
                }
        var update:SavedWorkout?
        if let update = message["update"] as? SavedWorkout  {

            print("saved workout data \(update)")
        }
        
        let notify = NotificationCenter.default
        
                switch request {
                case "test":
                    replyHandler(["test":"Success"])
                case "workoutSelected":
                    replyHandler(["workoutSelected":"Success"])
                    notify.post(name: NSNotification.Name(rawValue: "StartCamera"), object: nil)
                case "workoutStarted":
                    replyHandler(["workoutStarted":"Success"])
                    notify.post(name: NSNotification.Name(rawValue: "StartRecording"), object: nil)
                case "workoutStopped":
                    replyHandler(["workoutStopped":"Success"])
                    notify.post(name: NSNotification.Name(rawValue: "StopRecording"), object: nil)
                default:
                    replyHandler([:])
                }
    }

    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        if #available(iOS 16.0, *) {
            initializeRealm()
            initializeVideoDirectory()

                   } else {
            // Fallback on earlier versions
        }
        return true
    }
}
