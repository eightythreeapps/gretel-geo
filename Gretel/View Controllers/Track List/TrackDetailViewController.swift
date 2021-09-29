//
//  TrackDetailViewController.swift
//  Gretel
//
//  Created by Ben Reed on 24/09/2021.
//

import UIKit
import MapKit
import Combine

class TrackDetailViewController: UIViewController, Storyboarded {

    var track:Track?
    var locationDataProvider:LocationDataProvider!
    var trackRecorder:TrackRecorder!
    
    @IBOutlet var mapView:MKMapView!
    @IBOutlet var recorderButton:UIButton!
    
    private var cancellables:[AnyCancellable] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.track?.name
        
        self.configureMapView()
        
        self.locationDataProvider.permissionPublisher.sink { granted in
            if granted {
                self.initialiseTracking()
            }
        }.store(in: &cancellables)
        
        self.locationDataProvider.requestAccessToUsersLocation()
        
        self.trackRecorder.$isRecording.sink { isRecording in
            
            if isRecording {
                self.recorderButton.setTitle("Stop", for: .normal)
            }else{
                self.recorderButton.setTitle("Start", for: .normal)
            }
            
        }.store(in: &cancellables)
    }
    
    func initialiseTracking() {
        
        self.locationDataProvider.startTrackingLocation()
        self.locationDataProvider.locationPublisher.sink { completion in
            switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
            }
        } receiveValue: { location in
            self.updateUsersLocation(location: location)
        }.store(in: &cancellables)
        
    }
    
    func updateUsersLocation(location:CLLocation) {
        let coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region = self.mapView.regionThatFits(MKCoordinateRegion(center: coordinate, latitudinalMeters: 300, longitudinalMeters: 200))
        self.mapView.setRegion(region, animated: true)
    }
    
    func configureMapView() {
        
        self.mapView.showsScale = true
        self.mapView.showsUserLocation = true
        self.mapView.showsCompass = true
        self.mapView.userTrackingMode = .followWithHeading
    }
    
    @IBAction func recorderButtonHandler(sender:UIButton) {
        
        self.trackRecorder.startRecording(with: track)
        
    }
    
}

extension TrackDetailViewController: MKMapViewDelegate {
    
}

