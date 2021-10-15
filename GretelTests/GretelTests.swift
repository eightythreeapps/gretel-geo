//
//  GretelTests.swift
//  GretelTests
//
//  Created by Ben Reed on 22/09/2021.
//

import XCTest
import CoreLocation
import Combine

@testable import Gretel

class GretelTests: XCTestCase {
    
    var locationDataProvider:LocationDataProvider!
    var trackDataProvider:TrackDataProvider!
    var trackRecorder:TrackRecorder!
    
    var cancellables:[AnyCancellable] = []
    var trackID = UUID()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let locationManager = CLLocationManager()
        let context = CoreDataManager().testPersistentStoreCoordinator.viewContext
        self.locationDataProvider = LocationDataProvider(locationManager: locationManager,
                                                        locationPublisher: PassthroughSubject<CLLocation, Error>(),
                                                        permissionPublisher: PassthroughSubject<Bool, Never>(),
                                                        headingPublisher: PassthroughSubject<CLHeading, Error>())
        
        self.trackDataProvider = TrackDataProvider(context: context)
        
        self.trackRecorder = TrackRecorder(trackDataProvider: self.trackDataProvider, locationDataProvider: self.locationDataProvider)
        
        XCTAssertNotNil(self.locationDataProvider)
        XCTAssertNotNil(self.trackDataProvider)
        XCTAssertNotNil(self.trackRecorder)
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

//    func testLocationManagerCanLocateUser() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//        
//        let expectation = self.expectation(description: "User has been located")
//        var error: Error?
//        var locationFound:Bool = false
//        
//        self.locationDataProvider.$hasLocatedUser.sink { completion in
//            switch completion {
//                case .finished:
//                    break
//                case .failure(let encounteredError):
//                    print(encounteredError.localizedDescription)
//                    error = encounteredError
//            }
//            
//            expectation.fulfill()
//            
//        } receiveValue: { userHasBeenLocated in
//            locationFound = userHasBeenLocated
//            
//        }.store(in: &cancellables)
//        
//        self.locationDataProvider.startTrackingLocation()
//        
//        waitForExpectations(timeout: 10)
//        
//        // Asserting that our Combine pipeline yielded the
//        // correct output:
//        XCTAssertNil(error)
//        XCTAssertTrue(locationFound)
//    }
    
    func testSaveValidNewTack() {
        
        let customTrackName = "Custom track name"
        let date = Date()
        let track = self.trackDataProvider.createNewTrack(name: customTrackName, startDate: date)
        
        XCTAssertNotNil(track)
        XCTAssertNotNil(track?.id)
        XCTAssert(track?.dateStarted == date)
        XCTAssert(track?.name == customTrackName)
    }
    
    func testSaveTrackWithDefaultName() {
    
        let date = Date()
        let track = self.trackDataProvider.createNewTrack(name: nil, startDate: date)
        
        XCTAssertNotNil(track)
        XCTAssertNotNil(track?.id)
        XCTAssert(track?.dateStarted == date)
        XCTAssert(track?.name == TrackDataProvider.DefaultTrackName)
        
    }
    
    func testSavePointsToTrack() {
        let date = Date()
        let track = self.trackDataProvider.createNewTrack(name: "Track loaded by ID", startDate:date)
        
        let baseLat = 36.595104
        let baseLon = -82.188744
        
        let numberOfPoints = 10
        
        let count = 1...numberOfPoints
        for _ in count {
            self.trackDataProvider.add(location: self.generateRandomLocation(lat: baseLat, lng: baseLon), to: track!)
        }
        
        XCTAssertNotNil(track)
        XCTAssertTrue(track?.dateStarted == date)
        XCTAssertEqual(track?.points?.count, numberOfPoints)
        
    }
    
    func testLoadTrackByID() {
        
        let date = Date()
        let track = self.trackDataProvider.createNewTrack(name: "Track loaded by ID", startDate:date)
        
        let trackId = track?.id
        let loadedTrack = self.trackDataProvider.loadTrackByID(trackID: trackId!)
        
        XCTAssertTrue(loadedTrack?.id == trackId)
        
    }
    
    func testGetTrackPointsAsOrderedArray() {
        
        let date = Date()
        let track = self.trackDataProvider.createNewTrack(name: "Track loaded by ID", startDate:date)
        let baseLat = 36.595104
        let baseLon = -82.188744
        let numberOfPoints = 10
        let delay:UInt32 = 1
        
        let expectation = self.expectation(description: "Points have been created")
        
        let count = 1...numberOfPoints
        for number in count {
            self.trackDataProvider.add(location: self.generateRandomLocation(lat: baseLat, lng: baseLon), to: track!)
            
            if number == numberOfPoints {
                expectation.fulfill()
            }
            
            sleep(delay)
        }
        
        waitForExpectations(timeout: Double((delay * UInt32(numberOfPoints)) + 1))
        
        let points = self.trackDataProvider.getTrackPointsAsOrderedArray(trackPoints: track?.points)
        XCTAssertFalse(points.isEmpty)
        XCTAssertEqual(points.count, numberOfPoints)
        
        XCTAssertNotNil(track)
        XCTAssertTrue(track?.dateStarted == date)
        XCTAssertEqual(track?.points?.count, numberOfPoints)
        
    }
    
    func testActiveTrackMatch() {
        
        let date = Date()
        let trackOne = self.trackDataProvider.createNewTrack(name: "Track One", startDate: date)
        let trackTwo = self.trackDataProvider.createNewTrack(name: "Track Two", startDate: date)
        
        self.trackRecorder.setCurrentTrack(track: trackOne!)
        
        XCTAssert(self.trackRecorder.getCurrentTrack() == trackOne!)
        
    }
    
    func testActiveTrackMismatch() {
        
        let date = Date()
        let trackOne = self.trackDataProvider.createNewTrack(name: "Track One", startDate: date)
        let trackTwo = self.trackDataProvider.createNewTrack(name: "Track Two", startDate: date)
        
        self.trackRecorder.setCurrentTrack(track: trackOne!)
        
        XCTAssertFalse(self.trackRecorder.getCurrentTrack() == trackTwo)
    }
    
    func testNewActiveTrack() {
        
        let date = Date()
        let trackOne = self.trackDataProvider.createNewTrack(name: "Track One", startDate: date)
        let trackTwo = self.trackDataProvider.createNewTrack(name: "Track Two", startDate: date)
        
        self.trackRecorder.setCurrentTrack(track: trackOne!)
        
        sleep(2)
        
        self.trackRecorder.setCurrentTrack(track: trackTwo!)
        
        XCTAssertTrue(self.trackRecorder.getCurrentTrack() == trackTwo!)
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

extension GretelTests {
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    //https://gis.stackexchange.com/questions/25877/generating-random-locations-nearby
    func generateRandomLocation(lat: CLLocationDegrees, lng: CLLocationDegrees) -> CLLocation {
        let radius : Double = 100000 // this is in meters so 100 KM
        let radiusInDegrees: Double = radius / 111000
        let u : Double = Double(arc4random_uniform(100)) / 100.0
        let v : Double = Double(arc4random_uniform(100)) / 100.0
        let w : Double = radiusInDegrees * u.squareRoot()
        let t : Double = 2 * Double.pi * v
        let x : Double = w * cos(t)
        let y : Double = w * sin(t)

        // Adjust the x-coordinate for the shrinking of the east-west distances
        //in cos converting degree to radian
        let new_x : Double = x / cos(lat * .pi / 180 )

        let processedLat = new_x + lat
        let processedLng = y + lng

        return CLLocation(latitude: processedLat, longitude: processedLng)
    }
    
}
