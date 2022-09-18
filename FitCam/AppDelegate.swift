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
    
   
    
    override init() {
        isWorkoutSelected = false
    }
    @Published var isWorkoutSelected:Bool {
        didSet {
            if isWorkoutSelected == true {
                print("workout Selected")
            }
        }
    }
    
    @EnvironmentObject var cameraManager:CameraManager
    
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
                switch request {
                case "test":
                    replyHandler(["test":"Success"])
                case "workoutSelected":
                    replyHandler(["workoutSelected":"Success"])
                    isWorkoutSelected = true
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
        return true
    }
}
