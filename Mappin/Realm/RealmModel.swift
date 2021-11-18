//
//  RealmModel.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/17.
//

import Foundation
import RealmSwift

class TravelDocument: Object {
    @Persisted(primaryKey: true) var documentTitle: String
    @Persisted var travels: List<Travel>
    @Persisted var pinColor: String = "red"
    
    convenience init(title: String, travel: List<Travel>) {
        self.init()
        
        self.documentTitle = title
        self.travels = travel
    }
}


class Travel: Object {
    @Persisted var travelTitle: String
    @Persisted var travelDate: Date
    @Persisted var travelPicture: List<String>
    @Persisted var travelContent: String
    @Persisted var travelLocation: List<Double>
    @Persisted(primaryKey: true) var _id: ObjectId
    
    convenience init(title: String, date: Date, picture: List<String>, content: String, location: List<Double>) {
        self.init()
        
        self.travelTitle = title
        self.travelDate = date
        self.travelPicture = picture
        self.travelContent = content
        self.travelLocation = location
    }
}



