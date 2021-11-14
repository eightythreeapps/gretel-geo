//
//  TrackViewModel.swift
//  Gretel
//
//  Created by Ben Reed on 13/11/2021.
//

import Foundation

typealias TrackDetailDashboardItems = [TrackDetailDashboardItem]

enum TrackDetailDashboardItemType {
    case duration
    case distance
    case pointsCount
    case startDate
    case endDate
}

struct TrackDetailDashboardItem {
    var title:String = ""
    var value:Any = ""
}

class TrackDetailViewModel {
    
    private var track:Track!
    
    required init(track:Track) {
        self.track = track
    }
            
    func name() -> String {
        return self.track.name ?? ""
    }
    
    func originalModel() -> Track {
        return self.track
    }
    
    func formattedDuration() -> String {
        return "00:25:45"
    }
    
    func calculatedDistance() -> String {
        return "10km"
    }
    
    func pointsCount() -> Int {
        return self.track.points?.count ?? 0
    }
    
    func formattedStartDate() -> String {
        return "3rd Oct 2021"
    }
    
    func formattedEndDate() -> String {
        return "5th Oct 2021"
    }
    
    func dashboardItems() -> TrackDetailDashboardItems {
        
        let dashboardItems = [
            TrackDetailDashboardItem(title: "Started".localized, value: self.formattedStartDate()),
            TrackDetailDashboardItem(title: "Ended".localized, value: self.formattedEndDate()),
            TrackDetailDashboardItem(title: "Duration".localized, value: self.formattedDuration()),
            TrackDetailDashboardItem(title: "Points".localized, value: self.pointsCount()),
            TrackDetailDashboardItem(title: "Distance".localized, value: self.calculatedDistance())
        ]
        
        return dashboardItems
        
    }
    
}
