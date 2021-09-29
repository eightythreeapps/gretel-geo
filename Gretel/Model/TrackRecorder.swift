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
    
    func startRecording(with track:Track?) {
        
        self.isRecording = true
        
        if let track = track {
            self.track = track
        }else{
            self.track = self.trackDataProvider.startNewTrack(name: "New track", startDate: Date())
        }
        
        self.locationDataProvider.locationPublisher.sink { completion in
            switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
            }
        } receiveValue: { location in
            
            if let track = self.track {
                self.trackDataProvider.add(location: location, to: track)
            }
            
        }.store(in: &cancellables)
        
    }
    
    func stopRecording() {
        self.isRecording = false
    }
    
    
    
}
