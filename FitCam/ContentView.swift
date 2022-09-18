//
//  ContentView.swift
//  FitCam
//
//  Created by Kadeem Palacios on 8/27/22.
//

import SwiftUI

struct ContentView: View {
    
    @Binding var isWorkoutSelected:Bool
    
    var body: some View {
        VStack {
            Text("Hello, world!")
                .padding()

        }.fullScreenCover(isPresented: $isWorkoutSelected, content: {
            Text("Camera View")
        })
               
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(isWorkoutSelected: .constant(false))
    }
}
