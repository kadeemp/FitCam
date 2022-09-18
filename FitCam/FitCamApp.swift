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
                    ContentView(isWorkoutSelected: $isWorkoutSelected)
                }
            }.onReceive(NotificationCenter.default.publisher(for: Notification.Name("StartCamera")), perform: { output  in
                self.isWorkoutSelected = true
            })
//            .sheet(isPresented:
//
//                        appDelegate2.$isWorkoutSelected) {
//                Text("Video")
//            }
                        .environmentObject(self.appDelegate2)
        }
    }
}
