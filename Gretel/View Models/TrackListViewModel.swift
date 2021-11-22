//
//  TrackListViewModel.swift
//  Gretel
//
//  Created by Ben Reed on 13/11/2021.
//

import UIKit
import CoreData

class TrackListViewModel: NSObject  {

    public var fetchedResultsController:NSFetchedResultsController<Track>!
    public var trackDataProvider:TrackDataProvider!
    public var trackRecorder:TrackRecorder!
    
    required init(trackDataProvider:TrackDataProvider, trackRecorder:TrackRecorder, fetchedResultsController:NSFetchedResultsController<Track>) {
        
        super.init()
        
        self.trackRecorder = trackRecorder
        self.trackDataProvider = trackDataProvider
        self.fetchedResultsController = fetchedResultsController
        
    }
    
    func fetchData() {
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
        
    }
    
    func deleteObject(at indexPath:IndexPath) {
        let track = self.fetchedResultsController.object(at: indexPath)
        self.trackDataProvider.deleteTrack(track: track)
    }
    
    func track(forIndexPath indexPath:IndexPath) -> Track {
        
        let track = self.fetchedResultsController.object(at: indexPath)
        return track
        
    }
    
}

extension TrackListViewModel: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard let sections = self.fetchedResultsController.sections else {
            return ""
        }
        
        let sectionInfo = sections[section]
        return sectionInfo.name
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let track = self.fetchedResultsController.object(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = track.name
        cell.detailTextLabel?.text = "\(String(describing: track.dateStarted))"
        
        if let activeTrack = self.trackRecorder.currentTrack() {
            if track.id == activeTrack.id {
                cell.backgroundColor = .green
            }else{
                cell.backgroundColor = .white
            }
        }else{
            cell.backgroundColor = .white
        }
        
        return cell
    }
    
}
