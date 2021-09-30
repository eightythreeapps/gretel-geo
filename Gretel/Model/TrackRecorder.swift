//
//  TrackRecorder.swift
//  Gretel
//
//  Created by Ben Reed on 28/09/2021.
//

import Foundation
import Combine

class TrackRecorder {
    
    private var trackDataProvider:TrackDataProvider!
    private var locationDataProvider:LocationDataProvider!
    private var track:Track?
    private var cancellables:[AnyCancellable] = []
    
    @Published var isRecording = false
    
    required init(trackDataProvider:TrackDataProvider, locationDataProvider:LocationDataProvider) {
        self.trackDataProvider = trackDataProvider
        self.locationDataProvider = locationDataProvider
    }
    
    func startRecordingTrack(track:Track) {
        self.beginRecording(track: track)
    }
    
    func stopRecordingTrack(track:Track) {
        self.endRecording(track: track)
    }

}

private extension TrackRecorder {
    
    func beginRecording(track:Track) {
        
        self.isRecording = true
        self.trackDataProvider.setActiveTrack(track: track)
        
        self.locationDataProvider.locationPublisher.sink { completion in
            switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
            }
        } receiveValue: { location in
            
            self.trackDataProvider.add(location: location, to: track)
            
        }.store(in: &cancellables)
    }
    
    func endRecording(track:Track) {
        self.isRecording = false
        track.isActive = false
    }
}
