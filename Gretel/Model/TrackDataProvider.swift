//
//  TrackDataProvider.swift
//  Gretel
//
//  Created by Ben Reed on 24/09/2021.
//

import Foundation
import CoreData

typealias Tracks = [Track]

class TrackDataProvider {
    
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
        
        //Add it to the Track
        track.addToPoints(trackPoint)
        
        do {
            try self.coreDataManager.persistentContainer.viewContext.save()
            print("Location saved")
        }catch {
            print("Failed to store location \(error)")
        }
        
    }
    
    public func startNewTrack(name:String? = nil, startDate:Date) -> Track? {
        
        let track = Track(context: self.coreDataManager.persistentContainer.viewContext)
        track.name = name ?? "New track"
        track.dateStarted = startDate
        
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
    
    
}
