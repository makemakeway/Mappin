//
//  LocationManager.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/18.
//

import Foundation
import CoreLocation


class LocationManager {
    static let shared = LocationManager()
    
    
    let manager = CLLocationManager()
    
    
    private init() {
        
    }
    
    func checkUsersLocationServicesAuthorization() {
        
        let auth: CLAuthorizationStatus
        
        if #available(iOS 14.0, *) {
            auth = manager.authorizationStatus
        } else {
            auth = CLLocationManager.authorizationStatus()
        }
        
        if CLLocationManager.locationServicesEnabled() {
            checkCurrentLocationAutorization(status: auth)
        }
        
    }
    
    func checkCurrentLocationAutorization(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("DEBUG: 사용자의 위치 권한이 설정되지 않았음")
            manager.requestWhenInUseAuthorization()
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.startUpdatingLocation()
        case .restricted, .denied:
            print("DEBUG: 사용자의 위치 권한 사용 불가. Alert 띄워주자")
        case .authorizedAlways, .authorizedWhenInUse:
            print("DEBUG: 사용자의 위치 권한 사용 가능.")
            manager.startUpdatingLocation()
        @unknown default:
            print("DEBUG: 아 에러임 ㅋㅋ")
        }
        
        if #available(iOS 14.0, *) {
            let accuracyState = manager.accuracyAuthorization
            
            switch accuracyState {
            case .fullAccuracy:
                print("DEBUG: fullAccuracy")
            case .reducedAccuracy:
                print("DEBUG: reducedAccuracy")
            @unknown default:
                print("DEBUG: 아 언노운 ㅋㅋ")
            }
        }
        
        
    }
    
    
}