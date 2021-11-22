//
//  TrackRecorder.swift
//  Gretel
//
//  Created by Ben Reed on 28/09/2021.
//

import Foundation
import Combine

enum RecorderState {
    case stopped
    case paused
    case recording
}

class TrackRecorder {
    
    private var trackDataProvider:TrackDataProvider!
    private var locationDataProvider:LocationDataProvider!
    private var cancellables:[AnyCancellable] = []
    private var track:Track?
   
    @Published var currentState:RecorderState = .stopped
    
    required init(trackDataProvider:TrackDataProvider, locationDataProvider:LocationDataProvider) {
        self.trackDataProvider = trackDataProvider
        self.locationDataProvider = locationDataProvider
        self.initializeSubscribers()
    }
    
    func startRecording(track:Track){
        self.track = track
    }
    
    func stopRecording() {
        
    }
    
    func currentTrack() -> Track? {
        return self.track
    }
}

private extension TrackRecorder {
    
    func initializeSubscribers() {
        
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
    
}
