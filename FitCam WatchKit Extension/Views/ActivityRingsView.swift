//
//  ActivityRingsView.swift
//  FitCam WatchKit Extension
//
//  Created by Kadeem Palacios on 8/28/22.
//

import SwiftUI
import HealthKit
import Foundation


struct ActivityRingsView: WKInterfaceObjectRepresentable {
    
    typealias WKInterfaceObjectType = WKInterfaceActivityRing
    
    
    let healthStore:HKHealthStore
    
    func makeWKInterfaceObject(context: Context) -> WKInterfaceActivityRing {
        let activityRingsObject = WKInterfaceActivityRing()
        
        let calendar = Calendar.current
        var components = calendar.dateComponents(
            [.era, .year, .month, .day],
            from: Date())
        
        components.calendar = calendar
        
        let predicate = HKQuery.predicateForActivitySummary(with: components)
        
        let query = HKActivitySummaryQuery(predicate: predicate) {
            query,summaries, error in
            DispatchQueue.main.async {
                activityRingsObject.setActivitySummary(summaries?.first, animated: true)
            }
        }
        healthStore.execute(query)
        
        return activityRingsObject
    }
    
    
    
    
    func updateWKInterfaceObject(_ wkInterfaceObject: WKInterfaceObjectType, context: Context) {
        
    }
}

struct ActivityRingsView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityRingsView(healthStore: HKHealthStore())
    }
}
