//
//  TrackDashboardViewController.swift
//  Gretel
//
//  Created by Ben Reed on 14/11/2021.
//

import UIKit

class TrackDashboardViewModel:NSObject, UICollectionViewDataSource {
    
    var dashboardItems:TrackDetailDashboardItems?
    
    required init(dashboardItems:TrackDetailDashboardItems?) {
        self.dashboardItems = dashboardItems
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dashboardItems?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackDashboardBasicCell.CellIdentifier, for: indexPath) as! TrackDashboardBasicCell
        
        let item = self.dashboardItems?[indexPath.row]
        
        cell.titleLabel.text = item?.title
        cell.valueLabel.text = "\(item?.value ?? "")"
        
        return cell
        
    }
    
}

class TrackDashboardBasicCell:UICollectionViewCell {
    
    public static var CellIdentifier = "TrackDashboardBasicCell"
    
    @IBOutlet var titleLabel:UILabel!
    @IBOutlet var valueLabel:UILabel!
    
}

class TrackDashboardViewController: BottomSheetViewController {

    @IBOutlet var collectionView:UICollectionView!
    
    public var viewModel:TrackDashboardViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self.viewModel
        
    }
    
}
