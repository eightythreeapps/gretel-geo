//
//  TrackDataProvider.swift
//  Gretel
//
//  Created by Ben Reed on 24/09/2021.
//

import Foundation
import CoreData

typealias Tracks = [Track]
typealias TrackPoints = [TrackPoint]

class TrackDataProvider {
    
    public static let DefaultTrackName = "New track".localized
    private var coreDataManager:CoreDataManager!
    
    init(coreDataManager:CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
    
    public func trackListResultsController() -> NSFetchedResultsController<Track> {
        
        let fetchRequest: NSFetchRequest<Track> = Track.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateStarted", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.coreDataManager.persistentContainer.viewContext, sectionNameKeyPath: "dateStarted", cacheName: nil)

        return fetchedResultsController
        
    }

    public func add(location:CLLocation, to track:Track) {
        
        //Create the new TrackPoint object
        let trackPoint = TrackPoint(context: self.coreDataManager.persistentContainer.viewContext)
        trackPoint.latitude = location.coordinate.latitude
        trackPoint.longitude = location.coordinate.longitude
        trackPoint.datetime = Date()
        trackPoint.altitude = location.altitude
        trackPoint.id = UUID()
        
        //Add it to the Track
        track.addToPoints(trackPoint)
        
        do {
            try self.coreDataManager.persistentContainer.viewContext.save()
            print("Location saved")
        }catch {
            print("Failed to store location \(error)")
        }
        
    }
    
    public func createNewTrack(name:String? = nil, startDate:Date) -> Track? {
        
        let track = Track(context: self.coreDataManager.persistentContainer.viewContext)
        track.name = name ?? TrackDataProvider.DefaultTrackName
        track.dateStarted = startDate
        track.id = UUID()
        
        do {
            try self.coreDataManager.persistentContainer.viewContext.save()
            return track
        } catch {
            print("Create failed: \(error.localizedDescription)")
            
        }
        
        return nil
    }
    
    public func deleteTrack(track:Track) {
        self.coreDataManager.persistentContainer.viewContext.delete(track)
    }
    
    public func setTrackInactive(track:Track, endDate:Date? = nil) {
        track.isActive = false
        if endDate != nil {
            track.dateEnded = endDate
        }
        do {
            try self.coreDataManager.persistentContainer.viewContext.save()
        }catch {
            print("\(error.localizedDescription)")
        }
        
    }
    
    public func setActiveTrack(track:Track) {
        
        var tracks = Tracks()
        let request:NSFetchRequest<Track> = Track.fetchRequest()

        do {
            tracks = try self.coreDataManager.persistentContainer.viewContext.fetch(request)
            
            for loadedTrack in tracks {
                loadedTrack.isActive = false
            }
            
            track.isActive = true
            try self.coreDataManager.persistentContainer.viewContext.save()
            
        } catch {
            print("\(error.localizedDescription)")
        }
    
    }
        
    func loadTrackByID(trackID:UUID) -> Track? {
        
        var tracks = Tracks()
        let request:NSFetchRequest<Track> = Track.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", "id", trackID as CVarArg)
        
        do {
            tracks = try self.coreDataManager.persistentContainer.viewContext.fetch(request)
            if tracks.count == 1 {
                return tracks.first
            }
        } catch {
            print("\(error.localizedDescription)")
        }
        
        return nil
    }
    
    func getTrackPointsAsOrderedArray(trackPoints:NSSet?) -> [CLLocationCoordinate2D] {
        
        guard let points = trackPoints?.allObjects as? TrackPoints else { return [CLLocationCoordinate2D]() }
        
        let sortedPoints = points.sorted { pointA, pointB in
            return pointA.datetime!.compare(pointB.datetime!) == .orderedAscending
        }
            
        let coordinates = sortedPoints.map {
            CLLocationCoordinate2D(latitude: CLLocationDegrees($0.latitude), longitude: CLLocationDegrees($0.longitude))
        }
        
        return coordinates
        
    }
    
}
