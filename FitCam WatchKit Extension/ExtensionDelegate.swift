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
    
    func applicationDidFinishLaunching() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            
            
        }
    }
    
    
}
