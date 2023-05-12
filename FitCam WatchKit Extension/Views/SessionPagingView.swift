//
//  SessionPagingView.swift
//  FitCam WatchKit Extension
//
//  Created by Kadeem Palacios on 8/27/22.
//

import SwiftUI
import WatchKit

struct SessionPagingView: View {
    @State private var selection: Tab = .metrics
    @EnvironmentObject var workoutManager: WorkoutManager
    
    enum Tab {
        case controls, metrics, nowPlaying
    }
    
    var body: some View {
        TabView(selection: $selection) {
            ControlsView().tag(Tab.controls)
            MetricsView().tag(Tab.metrics)
            NowPlayingView().tag(Tab.nowPlaying)
        }
        .navigationTitle(workoutManager.selectedWorkout?.name ?? "")
        .navigationBarHidden(selection == .nowPlaying)
        .navigationBarBackButtonHidden(true)
        .onChange(of: workoutManager.running) { running in
            if !running {
                withAnimation {
                    dismissView()
                }
                
            }
        }
    }
    
    private func dismissView() {
        // Change the selection to a different tab to dismiss the view
        selection = .controls
    }
}

struct SessionPagingView_Previews: PreviewProvider {
    static var previews: some View {
        SessionPagingView()
    }
}
