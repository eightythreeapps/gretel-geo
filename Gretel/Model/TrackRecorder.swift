//
//  TrackRecorder.swift
//  Gretel
//
//  Created by Ben Reed on 28/09/2021.
//

import Foundation
import Combine

enum TrackRecorderStatus {
    case paused
    case recording
    case stopped
}

class TrackRecorder {
    
    private var trackDataProvider:TrackDataProvider!
    private var locationDataProvider:LocationDataProvider!
    private var cancellables:[AnyCancellable] = []
    private var track:Track?
    
    @Published var currentState:TrackRecorderStatus = .stopped
    
    required init(trackDataProvider:TrackDataProvider, locationDataProvider:LocationDataProvider) {
        self.trackDataProvider = trackDataProvider
        self.locationDataProvider = locationDataProvider
        
        self.initializeSubscribers()
    }
    
    private func initializeSubscribers() {
        
        self.$currentState.sink { state in
            
            if let track = self.track, state == .recording  {
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
            
            if let track = self.track, self.currentState == .recording {
                self.trackDataProvider.add(location: location, to:track)
            }
            
        }.store(in: &cancellables)
        
    }
    
    func startRecordingTrack(track:Track) {
        
        if let currentTrack = self.getCurrentTrack(), self.currentState == .recording {
            self.endRecording(track: currentTrack)
            self.beginRecording(track: track)
        }else{
            self.beginRecording(track: track)
        }
        
        
    }
    
    func stopRecordingTrack() {
        if let track = self.track {
            self.endRecording(track: track)
        }
    }
    
    func getCurrentTrack() -> Track? {
        return self.track
    }

    public func setCurrentTrack(track:Track) {
        self.track = track
    }
    
}

private extension TrackRecorder {
    
    func beginRecording(track:Track) {
        print("Starting track with ID: \(track.id)")
        self.track = track
    }
    
    func endRecording(track:Track) {
        print("Stopping track \(track.id)")
    }
}
