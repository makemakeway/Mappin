//
//  SearchResults.swift
//  Mappin
//
//  Created by 박연배 on 2021/12/09.
//

import Foundation
import CoreLocation

struct SearchResult {
    let primaryString: NSAttributedString
    let secondaryString: NSAttributedString
    let coordinate: CLLocationCoordinate2D
}
