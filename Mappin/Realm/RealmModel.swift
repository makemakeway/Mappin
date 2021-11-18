//
//  RealmModel.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/17.
//

import Foundation
import RealmSwift

class TravelDocument: Object {
    @Persisted var documentTitle: String
    @Persisted var travels: List<Travel>
}


class Travel: Object {
    @Persisted var travelTitle: String
    @Persisted var travelDate: Date
    @Persisted var travelPicture: List<String>
    @Persisted var travelContent: String
    @Persisted var travelLocation: List<Double>
}
