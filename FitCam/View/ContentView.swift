//
//  ContentView.swift
//  FitCam
//
//  Created by Kadeem Palacios on 8/27/22.
//

import SwiftUI

struct ContentView: View {
    
    @Binding var isWorkoutSelected:Bool
    var cameraViewVC = CameraViewVC()
    var body: some View {
        VStack {
            Text("Select a workout on the watch app to start the camera")
                .padding()

        }.fullScreenCover(isPresented: $isWorkoutSelected, content: {
            cameraViewVC
        })
               
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(isWorkoutSelected: .constant(false))
    }
}
