//
//  ExtensionDelegate.swift
//  FitCam WatchKit Extension
//
//  Created by Kadeem Palacios on 9/10/22.
//

import WatchKit
import WatchConnectivity
import RealmSwift

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Activation didnt complete with error \(error)")
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        if let outURLUpdate = applicationContext["OutputURLUpdate"] as? String {
            print("OutputURL Received! \(outURLUpdate)")
            //TODO:= Post notification with URL as the object.
            let notify = NotificationCenter.default
            notify.post(Notification(name: Notification.Name("updateVideoURL"), object: outURLUpdate ))
        } else {
            print(applicationContext,2)
        }
    }
    
    func applicationDidFinishLaunching() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            
            
        }
    }
    
    
}
