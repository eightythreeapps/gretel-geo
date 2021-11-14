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
    
    private var track:Track!
    
    ///Default map zoom level
    private var regionZoom = 200.0
    
    ///Works with the gesture recognizers to control map interaction
    public var shouldTrackUserLocation = true
    public var shouldUpdatePolyline = false
    public var currentViewState:RecorderState = .newTrack
    public var isEmptyTrack:Bool = true
    public var isInitialLoad = true
    
    init(track:Track?, locationDataProvider:LocationDataProvider, trackDataProvider:TrackDataProvider, trackRecorder:TrackRecorder) {
        self.track = track
        self.trackRecorder = trackRecorder
        self.trackDataProvider = trackDataProvider
        self.locationDataProvider = locationDataProvider
    }

    
    func initializeTrack() {
        
        if self.track == nil {
            
            guard let track = self.trackDataProvider.createNewTrack(name: TrackDataProvider.DefaultTrackName, startDate: Date()) else {
                return
            }
            
            self.track = track
             
        }
        
    }
}
