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
    
    var currentLocation = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: "userLatitude"), longitude: UserDefaults.standard.double(forKey: "userLongitude"))
    
    private init() {
        
    }
    
    func getAddress(location: CLLocation, completion: @escaping ((String) -> ()))  {
        let coder = CLGeocoder()
        let locale = Locale(identifier: "ko-KR")
        
        coder.reverseGeocodeLocation(location, preferredLocale: locale) { (placemark, error) -> Void in
            guard error == nil, let place = placemark?.first else {
                print("주소 설정 불가능")
                return
            }
            
            
            
            let address = [place.administrativeArea ?? "", place.locality ?? "", place.thoroughfare ?? "", place.subThoroughfare ?? ""]
            
            let addressQuery = address.joined(separator: " ")
            
            completion(addressQuery)
            return
        }
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
