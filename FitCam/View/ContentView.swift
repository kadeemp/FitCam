//
//  ContentView.swift
//  FitCam
//
//  Created by Kadeem Palacios on 8/27/22.
//

import SwiftUI
import AVFoundation
import AVKit

@available(iOS 16.0, *)
struct ContentView: View {
    
    @Environment(\.presentationMode) var presentationMode

    @Binding var isWorkoutSelected:Bool
    var cameraViewVC = CameraViewVC()
    
    var body: some View {
        
        VStack {
            Text("Select a workout on the watch app to start the camera")
                .padding()
            AVMoviePlayer(url: URL(string: "file:///var/mobile/Containers/Data/Application/018F8BD4-4FCC-40AE-BC2B-AD7414C07E56/Documents/WorkoutVideos/C43AAD9E-F227-4B8F-A1D1-68331FE657E1.mp4")!)
         
        }.fullScreenCover(isPresented: $isWorkoutSelected, content: {
            ZStack {
                cameraViewVC.onReceive(NotificationCenter.default.publisher(for: Notification.Name("StartRecording")), perform: { output  in
                    print("Recording started")
                    cameraViewVC.startRecording()
                 }).onReceive(NotificationCenter.default.publisher(for: Notification.Name("StopRecording")), perform: { output  in
                     print("Recording stopped")
                     cameraViewVC.stopRecording()
                  })
                Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("X")
            }
            }
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        if #available(iOS 16.0, *) {
            ContentView(isWorkoutSelected: .constant(false))
        } else {
            // Fallback on earlier versions
        }
    }
}
