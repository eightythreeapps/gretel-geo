//
//  TrackDataProvider.swift
//  Gretel
//
//  Created by Ben Reed on 24/09/2021.
//

import Foundation
import CoreData
import SwiftDate

typealias Tracks = [Track]
typealias TrackPoints = [TrackPoint]

class TrackDataProvider {
    
    public static let DefaultTrackName = "New track".localized
    private var context:NSManagedObjectContext!
    
    init(context:NSManagedObjectContext) {
        self.context = context
    }
    
    public func trackListResultsController() -> NSFetchedResultsController<Track> {
        
        let fetchRequest: NSFetchRequest<Track> = Track.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "section", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: "section", cacheName: nil)

        return fetchedResultsController
        
    }

    public func add(location:CLLocation, to track:Track) {
        
        //Create the new TrackPoint object
        let trackPoint = TrackPoint(context: self.context)
        trackPoint.latitude = location.coordinate.latitude
        trackPoint.longitude = location.coordinate.longitude
        trackPoint.datetime = Date()
        trackPoint.altitude = location.altitude
        trackPoint.id = UUID()
        
        //Add it to the Track
        track.addToPoints(trackPoint)
        
        do {
            try self.context.save()
            print("Location saved to track: \(String(describing: track.id))")
        }catch {
            print("Failed to store location \(error)")
        }
        
    }
    
    public func createNewTrack(name:String? = nil, startDate:Date) -> Track? {
    
        let track = Track(context: self.context)
        track.name = name ?? TrackDataProvider.DefaultTrackName
        track.dateStarted = startDate
        track.section = startDate.toFormat("dd MMM yyyy")
        track.id = UUID()
        
        do {
            try self.context.save()
            return track
        } catch {
            print("Create failed: \(error.localizedDescription)")
            
        }
        
        return nil
    }
    
    public func deleteTrack(track:Track) {
        self.context.delete(track)
    }
   
    func loadTrackByID(trackID:UUID) -> Track? {
        
        var tracks = Tracks()
        let request:NSFetchRequest<Track> = Track.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", "id", trackID as CVarArg)
        
        do {
            tracks = try self.context.fetch(request)
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
    
    func isCurrentActiveTrack(track1:Track, track2:Track) -> Bool {
    
        if track1 === track2 {
            return true
        }
        
        return false
    }
    
}

