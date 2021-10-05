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
    private var cancellables:[AnyCancellable] = []
    public var activeTrack:Track?
    
    @Published var isRecording = false
    
    required init(trackDataProvider:TrackDataProvider, locationDataProvider:LocationDataProvider) {
        self.trackDataProvider = trackDataProvider
        self.locationDataProvider = locationDataProvider
        
        self.initializeSubscribers()
    }
    
    public func setActiveTrack(track:Track) {
        self.activeTrack = track
    }
    
    private func initializeSubscribers() {
        
        self.$isRecording.sink { isRecording in
            
            if let track = self.activeTrack, isRecording  {
                self.startRecordingTrack(track: track)
            }else{
                self.stopRecordingTrack()
            }
            
        }.store(in: &cancellables)
        
        self.locationDataProvider.locationPublisher.sink { completion in
            switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
            }
        } receiveValue: { location in
            
            if let track = self.activeTrack, self.isRecording {
                self.trackDataProvider.add(location: location, to:track)
            }
            
        }.store(in: &cancellables)
        
    }
    
    func startRecordingTrack(track:Track) {
        
        self.beginRecording(track: track)
        
    }
    
    func stopRecordingTrack() {
        if let track = self.activeTrack {
            self.endRecording(track: track)
        }
    }

}

private extension TrackRecorder {
    
    func beginRecording(track:Track) {
        self.activeTrack = track
        self.trackDataProvider.setActiveTrack(track: track)
    }
    
    func endRecording(track:Track) {
        self.trackDataProvider.setTrackInactive(track: track, endDate: Date())
        self.isRecording = false
    }
}
