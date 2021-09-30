//
//  String+Localization.swift
//  Gretel
//
//  Created by Ben Reed on 30/09/2021.
//

import Foundation

extension String {
    
    var localized:String {
        return NSLocalizedString(self, comment: String("\(self) comment"))
    }
    
}
