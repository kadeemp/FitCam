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
