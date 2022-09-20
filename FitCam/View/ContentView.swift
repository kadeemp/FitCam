//
//  ContentView.swift
//  FitCam
//
//  Created by Kadeem Palacios on 8/27/22.
//

import SwiftUI

@available(iOS 16.0, *)
struct ContentView: View {
    
    @Environment(\.presentationMode) var presentationMode

    @Binding var isWorkoutSelected:Bool
    var cameraViewVC = CameraViewVC()
    var body: some View {
        VStack {
            Text("Select a workout on the watch app to start the camera")
                .padding()

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
