//
//  SummaryView.swift
//  FitCam WatchKit Extension
//
//  Created by Kadeem Palacios on 8/28/22.
//

import SwiftUI
import HealthKit

struct SummaryView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.dismiss) var dismiss
    @State private var durationFormatter: DateComponentsFormatter = {
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    var body: some View {
        
        if workoutManager.workout == nil {
            ProgressView("Saving Workout")
                .navigationBarHidden(true)
        } else {
            ScrollView(.vertical) {
                VStack(alignment: .leading ) {
                    SummaryMetricView(
                        title: "Total Time",
                        value: durationFormatter.string(
                            from: workoutManager.workout?.duration ?? 0.0) ?? "").accentColor(Color.yellow)
                    SummaryMetricView(
                        title: "Total Distance",
                        value: Measurement(
                            value: workoutManager.workout?.totalDistance?.doubleValue(for: .meter()) ?? 0,
                            unit: UnitLength.meters
                        ).formatted(
                            .measurement(
                                width: .abbreviated,
                                usage: .road,
                                numberFormatStyle: .number.precision(.fractionLength(2))
                            )
                        )
                    ).accentColor(Color.green)
                    SummaryMetricView(
                        title: "Total Energy",
                        value: Measurement(
                            value: workoutManager.workout?.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0,
                            unit: UnitEnergy.kilocalories).formatted(.measurement(width: .abbreviated, usage: .workout)
                                                                    )
                    ).accentColor(Color.pink)
                    SummaryMetricView(
                        title: "Avg Heart Rate",
                        value: workoutManager.averageHeartRate.formatted(
                            .number.precision(.fractionLength(0))
                        )
                        + "bpm"
                    ).accentColor(Color.red)
                    Text("Activity Rings")
                    ActivityRingsView(healthStore: workoutManager.healthStore
                    ).frame(width: 50, height: 50)
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }.scenePadding() //vstack
            } //scrollview
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
        } // else
    } // if

    
} // body

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
    }
}

struct SummaryMetricView: View {
    var title:String
    var value:String
    
    var body: some View {
        Text(title)
        Text(value)
            .font(.system(.title2, design:.rounded)
                .lowercaseSmallCaps()
            )
            .foregroundColor(.accentColor)
        Divider()
        
        
    }
    
    
    
    
    
}
