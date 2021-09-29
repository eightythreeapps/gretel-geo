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
    
    
}
