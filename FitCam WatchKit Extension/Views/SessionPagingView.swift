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
        .onChange(of: workoutManager.running) { _ in
            displayMetricsView()
        }
    }
    private func displayMetricsView() {
        withAnimation {
            selection = .metrics
        }
    }
}

struct SessionPagingView_Previews: PreviewProvider {
    static var previews: some View {
        SessionPagingView()
    }
}
