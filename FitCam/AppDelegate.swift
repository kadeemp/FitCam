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
    func initializeDirectory() {
        let videoPath = "WorkoutVideos"
        do {
            var documentDirectory = try FileManager.default.url(for: .documentDirectory , in: .userDomainMask, appropriateFor: nil, create: false)
            documentDirectory.append(path: videoPath)
            print("directory \(documentDirectory.path) \n")
            let fileExists = FileManager.default.fileExists(atPath: documentDirectory.path)
            if !fileExists {
                try FileManager.default.createDirectory(atPath: documentDirectory.path, withIntermediateDirectories: true)
                print("Directory Created")
            } else {
                print("Files exists. no directory created")
                let contents = try FileManager.default.contentsOfDirectory(atPath:documentDirectory.path)
                print("contents \(contents)")
            }
        }
        catch {
            print(error,"\n")
            print("Error creating documents directory")
        }
        
        
        
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
                guard let request = message["request"] as? String else {
        
                    replyHandler([:])
                    return
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
            initializeDirectory()
        } else {
            // Fallback on earlier versions
        }
        return true
    }
}
