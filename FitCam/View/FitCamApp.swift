//
//  FitCamApp.swift
//  FitCam
//
//  Created by Kadeem Palacios on 8/27/22.
//

import SwiftUI

@main
struct FitCamApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate2
    
 
    @State var isWorkoutSelected:Bool = false
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                HStack {
                    if #available(iOS 16.0, *) {
                        ContentView(isWorkoutSelected: $isWorkoutSelected)
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
            
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("StartCamera")), perform: { output  in
                self.isWorkoutSelected = true
            })
                        .environmentObject(self.appDelegate2)
        }
    }
}
