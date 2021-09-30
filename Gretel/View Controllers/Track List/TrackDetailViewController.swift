//
//  TrackDetailViewController.swift
//  Gretel
//
//  Created by Ben Reed on 24/09/2021.
//

import UIKit
import MapKit
import Combine

enum DetailViewState {
    case newTrack
    case activeTrack
    case inactiveTrack
}

class TrackDetailViewController: UIViewController, Storyboarded {

    ///Set up a recognizer to capture the user panning the map view. This is works in conjunction with the var `shouldTrackUserLocation`
    ///to make sure that the user can pan the map without the location update re-centering the view on the users current position
    private lazy var mapPanGestureRecognizer:UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(mapViewDidPan(sender:)))
        recognizer.delegate = self
        return recognizer
    }()
    
    ///This gesture recognizer captures the pinch input to make sure that both pan and pinch are captured and will both set `shouldTrackUserLocation`
    ///to false, thus enusring the user can interact with the map view without constantly being re-centered by CLLocationManager updates.
    private lazy var mapPinchGestureRecognizer:UIPinchGestureRecognizer = {
        let recognizer = UIPinchGestureRecognizer(target: self, action: #selector(mapViewWasPinched(sender:)))
        recognizer.delegate = self
        return recognizer
    }()
    
    ///Provides a reset mechanism for `shouldTrackUserLocation`. This sets it back to true and allows the app to take over location tracking duties on the map view
    private lazy var mapDoubleTapGestureRecognizer:UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(mapViewWasDoubleTapped(sender:)))
        recognizer.delegate = self
        recognizer.numberOfTapsRequired = 2
        recognizer.numberOfTouchesRequired = 1
        
        return recognizer
    }()
    
    ///Default map zoom level
    private var regionZoom = 200.0
    
    ///Works with the gesture recognizers to control map interaction
    private var shouldTrackUserLocation = true
    
    ///Subscription store
    private var cancellables:[AnyCancellable] = []
    
    //Outlets
    @IBOutlet private var mapView:MKMapView!
    @IBOutlet private var recorderButton:UIButton!
    
    //Dependencies
    var locationDataProvider:LocationDataProvider!
    var trackDataProvider:TrackDataProvider!
    var trackRecorder:TrackRecorder!
    
    //Injectables
    var track:Track?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureMapView()
        self.initializeSubscriptions()
        self.locationDataProvider.requestAccessToUsersLocation()
        
        self.title = self.track?.name ?? "New track"
        
        if let track = self.track {
           
            if track.isActive {
                self.configureView(for: .activeTrack)
            }else{
                self.configureView(for: .inactiveTrack)
            }
            
        }else{
            self.configureView(for: .newTrack)
        }
        
    }
    
}

private extension TrackDetailViewController {
    
    func configureView(for state:DetailViewState) {
        
        switch state {
        case .newTrack:
            print("New track")
            self.shouldTrackUserLocation = true
        case .activeTrack:
            print("Active track")
            self.shouldTrackUserLocation = true
            
        case .inactiveTrack:
            print("Inactive track")
            self.shouldTrackUserLocation = false
        }
        
    }

    func initializeSubscriptions() {
        
        self.locationDataProvider.$hasLocatedUser.sink { hasLocatedUser in
            self.recorderButton.isEnabled = hasLocatedUser
        }.store(in: &cancellables)
        
        //Checks to see if the Track Recorder is active so the UI can update accordingly
        self.trackRecorder.$isRecording.sink { isRecording in
            
            if let track = self.track {
                
                if isRecording && track.isActive {
                    self.recorderButton.setTitle("Stop".localized, for: .normal)
                }else{
                    self.recorderButton.setTitle("Resume".localized, for: .normal)
                }
            }else{
                
                self.recorderButton.setTitle("Start".localized, for: .normal)
                
            }
            
        }.store(in: &cancellables)
        
        //Checks the location data provider to see if we have permission to access the users location
        self.locationDataProvider.permissionPublisher.sink { granted in
            if granted {
                self.locationDataProvider.startTrackingLocation()
            }else{
                self.displayPermissionError()
            }
        }.store(in: &cancellables)
        
        self.locationDataProvider.locationPublisher.sink { completion in
            switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                    self.displayLocationError()
            }
        } receiveValue: { location in
            
            if self.shouldTrackUserLocation {
                self.updateUserLocation(location: location)
            }
            
        }.store(in: &cancellables)
        
    }
    
    ///Configures the mapView when the view loads
    ///This method adds the custom gesture recognisers needed to give users the ability to interact with the map view and override `updateUserLocation(location:)`
    func configureMapView() {
        
        self.mapView.addGestureRecognizer(self.mapPanGestureRecognizer)
        self.mapView.addGestureRecognizer(self.mapDoubleTapGestureRecognizer)
        self.mapView.addGestureRecognizer(self.mapPinchGestureRecognizer)
        self.mapView.showsScale = true
        self.mapView.showsUserLocation = true
        self.mapView.showsCompass = true
        
    }
    
    func addTrackAsOverlay() {
        
    }
    
    func zoomMapToTrack(track:Track) {
        
    }
    
    ///Updates a users location on the mapView
    func updateUserLocation(location:CLLocation) {
        self.zoomMapToLocation(location: location)
    }
    
    func zoomMapToLocation(location:CLLocation) {
        let coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region = self.mapView.regionThatFits(MKCoordinateRegion(center: coordinate, latitudinalMeters: regionZoom, longitudinalMeters: regionZoom))
        self.mapView.setRegion(region, animated: true)
    }
    
    func displayPermissionError() {
        let alertView = UIAlertController(title: "Error".localized,
                                          message: "You have not allowed access to your location. To do this, please update the permission in the Settings app.".localized,
                                          preferredStyle: .alert)
        
        alertView.addAction(UIAlertAction(title: "Dismiss".localized, style: .default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
    
    func displayLocationError() {
        let alertView = UIAlertController(title: "Error".localized,
                                          message: "Unable to determine users location".localized,
                                          preferredStyle: .alert)
        
        alertView.addAction(UIAlertAction(title: "Dismiss".localized, style: .default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
    
    @IBAction func recorderButtonHandler(sender:UIButton) {
        
        if self.trackRecorder.isRecording {
           
            if let track = self.track {
                self.trackRecorder.stopRecordingTrack(track: track)
            }
            
        }else{
           
            //Check if we already have a track or whether we shoudl create a new one
            let track = self.track != nil ? self.track : self.trackDataProvider.startNewTrack(name: "New track", startDate: Date())
            guard let recordableTrack = track else{
                return
            }
            
            //Set the title in the navigation bar
            self.track = recordableTrack
            self.title = recordableTrack.name
            
            //Start recording
            self.trackRecorder.startRecordingTrack(track: recordableTrack)
            
        }
        
    }
    
}

extension TrackDetailViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func mapViewDidPan(sender:MKMapView) {
        self.shouldTrackUserLocation = false
    }
    
    @objc func mapViewWasDoubleTapped(sender:MKMapView) {
        self.shouldTrackUserLocation = true
    }
    
    @objc func mapViewWasPinched(sender:MKMapView) {
        self.shouldTrackUserLocation = false
    }
}
