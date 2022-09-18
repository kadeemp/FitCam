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
    
    @State var isWorkoutSelected:Bool?
    
//    @Binding var isWorkoutSelected:Bool?
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                VStack {
                    ContentView()
                }.sheet(isPresented:  $isWorkoutSelected) {
                    
                }

            }
//            .sheet(isPresented:
//
//                        appDelegate2.$isWorkoutSelected) {
//                Text("Video")
//            }
                        .environmentObject(self.appDelegate2)
        }
    }
}
