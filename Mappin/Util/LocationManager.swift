//
//  LocationManager.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/18.
//

import CoreLocation
import UIKit


class LocationManager {
    static let shared = LocationManager()
    
    
    let manager = CLLocationManager()
    
    var currentLocation: CLLocationCoordinate2D = {
        var latitude = UserDefaults.standard.double(forKey: "userLatitude")
        var longitude = UserDefaults.standard.double(forKey: "userLongitude")
        
        print(latitude, longitude)
        
        if latitude == 0.0 && longitude == 0.0 {
            let location = CLLocationCoordinate2D(latitude: 37.56636813704404,
                                                  longitude: 126.97795811732428)
            return location
        } else {
            let location = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: "userLatitude"),
                                                  longitude: UserDefaults.standard.double(forKey: "userLongitude"))
            return location
        }
    }()
    
    private init() {
        
    }
    
    func getAddress(location: CLLocation, completion: @escaping ((String) -> ()))  {
        let coder = CLGeocoder()
        let locale = Locale.current
        
        coder.reverseGeocodeLocation(location, preferredLocale: locale) { (placemark, error) -> Void in
            guard error == nil, let place = placemark?.first else {
                print("주소 설정 불가능")
                return
            }
            if let code = place.isoCountryCode {
                completion(code)
                print("isoCountryCode: \(code)")
            } else {
                print("isoCountryCode: nil")
            }
            
            
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
    
    func codeToFlag(code: String) -> String {
        let base: UInt32 = 127397
        var s = ""
        
        for v in code.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return String(s)
        
    }
    
    func checkCurrentLocationAutorization(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined, .restricted:
            print("DEBUG: 사용자의 위치 권한이 설정되지 않았음")
            manager.requestWhenInUseAuthorization()
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.startUpdatingLocation()
        case .denied:
            print("DEBUG: 사용자의 위치 권한 사용 불가. Alert 띄워주자")
        case .authorizedAlways, .authorizedWhenInUse:
            print("DEBUG: 사용자의 위치 권한 사용 가능.")
            manager.startUpdatingLocation()
            if let location = manager.location {
                currentLocation = location.coordinate
            }
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
