//
//  TrackRecorderViewModel.swift
//  Gretel
//
//  Created by Ben Reed on 14/11/2021.
//

import UIKit

class TrackRecorderViewModel: NSObject {

    //Dependencies
    public var locationDataProvider:LocationDataProvider!
    public var trackDataProvider:TrackDataProvider!
    public var trackRecorder:TrackRecorder!
        
    init(locationDataProvider:LocationDataProvider, trackDataProvider:TrackDataProvider, trackRecorder:TrackRecorder) {
        self.trackRecorder = trackRecorder
        self.trackDataProvider = trackDataProvider
        self.locationDataProvider = locationDataProvider
    }

}
