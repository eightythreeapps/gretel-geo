//
//  Coordinator.swift
//  Gretel
//
//  Created by Ben Reed on 22/09/2021.
//

import Foundation
import UIKit

protocol Coordinator:AnyObject {
    var childCoordinators: [Coordinator] {get set}
    var navigationController: UINavigationController {get set}
    
    func start()
}
