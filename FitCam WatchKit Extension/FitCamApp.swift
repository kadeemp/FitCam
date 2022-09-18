//
//  FitCamApp.swift
//  FitCam WatchKit Extension
//
//  Created by Kadeem Palacios on 8/27/22.
//

import SwiftUI
import WatchKit

@main
struct FitCamApp: App {
    
    @StateObject var workoutManager = WorkoutManager()
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var delegate
    
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                StartView()
            }
            .sheet(isPresented: $workoutManager.showingSummaryView) {
                SummaryView()
            }
            .environmentObject(workoutManager)
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
