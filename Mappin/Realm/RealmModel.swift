//
//  RealmModel.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/17.
//

import Foundation
import RealmSwift
import CoreLocation

class LocationDocument: Object {
    @Persisted(primaryKey: true) var documentTitle: String
    @Persisted var memoryList: List<MemoryData>
    @Persisted var pinColor: String = "red"
    @Persisted var locationCoordinate: List<Double>
    @Persisted var stared: Bool = false
    @Persisted var nationalCode: String
    @Persisted var latestWrittenDate: Date
    @Persisted var oldestWrittenDate: Date
    @Persisted var lastUpdated: Date
    @Persisted var presentImage: String
    
    convenience init(title: String, memoryList: List<MemoryData>, location: List<Double>, nationalCode: String, latest: Date, oldest: Date, lastUpdated: Date) {
        self.init()
        
        self.documentTitle = title
        self.memoryList = memoryList
        self.locationCoordinate = location
        self.nationalCode = nationalCode
        self.latestWrittenDate = latest
        self.oldestWrittenDate = oldest
        self.lastUpdated = lastUpdated
    }
}


class MemoryData: Object {
    @Persisted var memoryDate: Date
    @Persisted var memoryPicture: List<String>
    @Persisted var memoryContent: String
    @Persisted var memoryDescription: String
    @Persisted var memoryCategory: String = "default"
    @Persisted(primaryKey: true) var _id: ObjectId
    
    convenience init(date: Date, picture: List<String>, content: String, description: String) {
        self.init()
        
        self.memoryDate = date
        self.memoryPicture = picture
        self.memoryContent = content
        self.memoryDescription = description
    }
}



