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

class AppDelegate:NSObject,ObservableObject, UIApplicationDelegate, WCSessionDelegate {
    //MARK:- FileManager
    
    @available(iOS 16.0, *)
    func initializeVideoDirectory() {
        let videoPath = "WorkoutVideos"
        do {
            var documentDirectory = try FileManager.default.url(for: .documentDirectory , in: .userDomainMask, appropriateFor: nil, create: false)
            documentDirectory.append(path: videoPath)
//            print("directory \(documentDirectory.path) \n")
            let fileExists = FileManager.default.fileExists(atPath: documentDirectory.path)
            if !fileExists {
                try FileManager.default.createDirectory(atPath: documentDirectory.path, withIntermediateDirectories: true)
                print("Directory Created")
            } else {
                let contents = try FileManager.default.contentsOfDirectory(atPath:documentDirectory.path)
                print("contents \(contents)")
            }
        }
        catch {
            print(error,"\n")
            print("Error creating documents directory")
        }
    
    }
    
    
    var realm:Realm!
    
    @available(iOS 16.0, *)
    func initializeRealm() {
       
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)
        
        let datapath = docURL?.appending(path: "FitCam-db.realm")
            
            var config =  Realm.Configuration(fileURL: datapath ,schemaVersion: 1, deleteRealmIfMigrationNeeded: true)
        DispatchQueue.main.async {
            do {
                try self.realm = Realm(configuration: config)
                print("realm fileurl:  \(self.realm.configuration.fileURL) ")
                let workouts = self.realm.objects(SavedWorkout.self)
                print("list of workouts: \n \(workouts)")
            } catch {
                print("failed to setup configuration. Error: \(error)")
            }

        }
              
        
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    func saveNewWorkout(_ workout:SavedWorkout) {
        if realm != nil {
            do {
                DispatchQueue.main.async {
                    try! self.realm.write {
                        self.realm.add(workout)
                        print("workout saved! ")
                    }
                }

            }
            
             }
    }

    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        print("messageData received \n Data:\(messageData))")
                do {
                    let receivedWorkout = try JSONDecoder().decode(SavedWorkout.self, from: messageData)
                    print("\n Decoded data: \n \(receivedWorkout)")
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
