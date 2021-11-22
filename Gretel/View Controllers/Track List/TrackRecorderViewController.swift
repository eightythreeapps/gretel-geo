//
//  TrackDetailViewController.swift
//  Gretel
//
//  Created by Ben Reed on 24/09/2021.
//

import UIKit
import MapKit
import Combine

enum RecorderViewState {
    case newTrack
    case activeTrack
    case inactiveTrack
}

class TrackRecorderViewController: UIViewController, Storyboarded {
    
    public var shouldTrackUserLocation = true
    public var shouldUpdatePolyline = false
    public var isEmptyTrack:Bool = true
    public var isInitialLoad = true
  
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
    
    public var viewModel:TrackRecorderViewModel!
    
    ///Subscription store
    private var cancellables:[AnyCancellable] = []
    
    //Outlets
    @IBOutlet private var mapView:MKMapView!
        
    //Injectables
    var track:TrackDetailViewModel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.initializeSubscriptions()
        self.configureMapView()
        
        //self.viewModel.locationDataProvider.requestAccessToUsersLocation()
        
    }
    
    
}

private extension TrackRecorderViewController {
        
    func configureView(for state:RecorderState) {
//
//        self.viewModel.currentViewState = state
//        self.trackRecorderViewController.configure(for: state)
//
//        switch state {
//        case .newTrack:
//            self.viewModel.shouldTrackUserLocation = true
//            self.viewModel.shouldUpdatePolyline = false
//        case .activeTrack:
//            self.viewModel.shouldTrackUserLocation = true
//            self.viewModel.shouldUpdatePolyline = true
//        case .inactiveTrack:
//            self.viewModel.shouldTrackUserLocation = true
//            //self.addTrackOverlay(for: self.track)
//        }
        
    }
    
    func addTrackOverlay(for track:Track) {
        
//        guard let trackPoints = track.points else { return }
//
//        //Check this
//        let pathCoordinates = self.viewModel.trackDataProvider.getTrackPointsAsOrderedArray(trackPoints: trackPoints)
//
//        let newPolyline = MKPolyline(coordinates: pathCoordinates, count: pathCoordinates.count)
//
//        if self.mapView.overlays.count > 0 {
//            let existingPolylineIndex = self.mapView.overlays.firstIndex {  $0.isKind(of: MKPolyline.self) }!
//            self.mapView.removeOverlay(self.mapView.overlays[existingPolylineIndex])
//        }
//
//        //self.mapView.removeOverlay()
//        self.mapView.addOverlay(newPolyline)
//
//        //On intial load of an inactive track, zoom the map to fit.
//        if self.viewModel.currentViewState == .inactiveTrack && self.viewModel.isInitialLoad {
//            self.zoomMapToPolyline(polyline: newPolyline)
//            self.viewModel.isInitialLoad = false
//        }
//
    }
    
    func zoomMapToPolyline(polyline:MKPolyline) {
        self.mapView.setVisibleMapRect(polyline.boundingMapRect, animated: false)
    }
    
    ///Configures the mapView when the view loads
    ///This method adds the custom gesture recognisers needed to give users the ability to interact with the map view and override `updateUserLocation(location:)`
    func configureMapView() {
        
        self.mapView.delegate = self
        self.mapView.addGestureRecognizer(self.mapPanGestureRecognizer)
        self.mapView.addGestureRecognizer(self.mapDoubleTapGestureRecognizer)
        self.mapView.addGestureRecognizer(self.mapPinchGestureRecognizer)
        self.mapView.showsScale = true
        self.mapView.showsUserLocation = true
        self.mapView.showsCompass = true
        
    }

    ///Updates a users location on the mapView
    func updateUserLocation(location:CLLocation) {
        self.zoomMapToLocation(location: location)
    }
    
    func zoomMapToLocation(location:CLLocation) {
        
        let zoomRegionMeters = 200.0
        let coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region = self.mapView.regionThatFits(MKCoordinateRegion(center: coordinate,
                                                                    latitudinalMeters: zoomRegionMeters,
                                                                    longitudinalMeters: zoomRegionMeters))
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
    
    func displayExistingTrackWarning() {
        let alertController = UIAlertController(title: "Already recording".localized, message: "You are already recording a track. Starting a new one will stop the existing recording. Do you wish to continue?", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel new recording", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Start new track", style: .destructive, handler: { action in
            //self.trackRecorder.setCurrentTrack(track: self.track)
            //self.viewModel.trackRecorder.currentState = .recording
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func initializeSubscriptions() {
        
        //self.initializePermissionSubscription()
        self.initializeLocationUpdatesSubscriptions()
        self.initializeStateSubscription()
        
    }
    
    func initializeLocationUpdatesSubscriptions() {
        
//        //Hook the record button up to a subscriber to enable/disable if we cannot locate the user
//        self.viewModel.locationDataProvider.$hasLocatedUser.sink { hasLocatedUser in
//            //self.recorderButton.isEnabled = hasLocatedUser
//            if hasLocatedUser {
//                self.zoomMapToLocation(location: CLLocation(latitude: self.mapView.userLocation.coordinate.latitude, longitude: self.mapView.userLocation.coordinate.longitude))
//            }
//        }.store(in: &cancellables)
//
//        self.viewModel.locationDataProvider.locationPublisher.sink { completion in
//            switch completion {
//                case .finished:
//                    break
//                case .failure(let error):
//                    print("Error: \(error)")
//                    self.displayLocationError()
//            }
//        } receiveValue: { location in
//
//            if self.viewModel.shouldTrackUserLocation {
//                self.updateUserLocation(location: location)
//            }
//
//            if self.viewModel.shouldUpdatePolyline {
//                guard let track = self.viewModel.trackRecorder.getCurrentTrack() else{
//                    return
//                }
//
//                self.addTrackOverlay(for: track)
//
//            }
//
//        }.store(in: &cancellables)
    
    }
    
    func initializeStateSubscription() {
        
//        //Checks to see if the Track Recorder is active so the UI can update accordingly
//        self.viewModel.trackRecorder.$currentState.sink { state in
//
////            var isActiveTrack = false
////            if let recorderTrack = self.viewModel.trackRecorder.getCurrentTrack() {
////                isActiveTrack = self.viewModel.trackDataProvider.isCurrentActiveTrack(track1: self.track, track2: recorderTrack)
////            }
////
////            if state == .recording && isActiveTrack {
////                self.configureView(for: .activeTrack)
////            }else if !isActiveTrack, let points = self.track.points, points.count == 0 {
////                self.configureView(for: .newTrack)
////            }else{
////                self.configureView(for: .inactiveTrack)
////            }
//
//        }.store(in: &cancellables)
        
    }
    
    
    
}


extension TrackRecorderViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let lineView = MKPolylineRenderer(overlay: overlay)
        lineView.strokeColor = .blue
        lineView.lineWidth = 5
        return lineView
    
    }
}

extension TrackRecorderViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func mapViewDidPan(sender:MKMapView) {
        //self.viewModel.shouldTrackUserLocation = false
    }
    
    @objc func mapViewWasDoubleTapped(sender:MKMapView) {
        //self.viewModel.shouldTrackUserLocation = true
    }
    
    @objc func mapViewWasPinched(sender:MKMapView) {
        //self.viewModel.shouldTrackUserLocation = false
    }
}
