//
//  FitCamApp.swift
//  FitCam
//
//  Created by Kadeem Palacios on 8/27/22.
//

import SwiftUI

@available(iOS 16.0, *)
@main
struct FitCamApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate2
    let realmWrapper = RealmWrapper()
    @State var isWorkoutSelected: Bool = false
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView(isWorkoutSelected: $isWorkoutSelected)
                    .environmentObject(realmWrapper)
                    .onReceive(NotificationCenter.default.publisher(for: Notification.Name("StartCamera"))) { _ in
                        self.isWorkoutSelected = true
                    }
            }
            .onAppear {
                NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "StartRecording"), object: nil, queue: nil) { _ in
                    // Handle StartRecording notification if needed
                }
                
                NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "StopRecording"), object: nil, queue: nil) { _ in
                    // Handle StopRecording notification if needed
                }
            }
        }
    }
}


