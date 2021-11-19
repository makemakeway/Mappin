//
//  MapViewController.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/17.
//

import UIKit
import CoreLocation
import GoogleMaps
import RealmSwift

class MapViewController: UIViewController {

    
    //MARK: Properties
    var currentLocation: CLLocationCoordinate2D? {
        didSet {
            print("DEBUG: 현재 위치 = \(currentLocation!)")
            if !locationUpdated {
                loadMap(location: currentLocation!)
                getCurrentAddress(location: CLLocation(latitude: currentLocation!.latitude,
                                                       longitude: currentLocation!.longitude))
            }
        }
    }
    
    var locationManager = LocationManager.shared.manager
    
    var locationUpdated = false
    
    let localRealm = try! Realm()
    
    var tasks: Results<TravelDocument>!
    
    //MARK: UI
    
    @IBOutlet weak var mapView: GMSMapView!
    
    
    //MARK: Method
    
    @objc func addButtonClicked(_ sender: UIBarButtonItem) {
        print("DEBUG: Add button clicked")
        presentActionSheet()
        
    }
    
    func loadMap(location: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(
            withLatitude: location.latitude,
            longitude: location.longitude,
            zoom: 16)

        mapView.settings.scrollGestures = true
        mapView.settings.zoomGestures = true
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.camera = camera
    }
    
    func addPin() {
        
    }
    
    
    func getCurrentAddress(location: CLLocation) {
        let coder = CLGeocoder()
        let locale = Locale(identifier: "ko-KR")
        coder.reverseGeocodeLocation(location, preferredLocale: locale) { (placemark, error) -> Void in
            guard error == nil, let place = placemark?.first else {
                print("주소 설정 불가능")
                return
            }
            
            
            let address = [place.administrativeArea!, place.locality!, place.thoroughfare!, place.subThoroughfare!]
            
            UserDefaults.standard.set(location.coordinate.longitude, forKey: "userLongitude")
            UserDefaults.standard.set(location.coordinate.latitude, forKey: "userLatitude")
            UserDefaults.standard.set(address.joined(separator: " "), forKey: "userLocation")
        }
    }
    
    func presentActionSheet() {
        let sheet = UIAlertController(title: "핀 추가", message: nil, preferredStyle: .actionSheet)
        
        let newlyTravel = UIAlertAction(title: "새로운 여행에 핀 추가하기", style: .default) { _ in
            print("DEBUG: 새로운 여행 추가 씬으로")
            let sb = UIStoryboard(name: "AddTravel", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "AddTravelViewController") as! AddTravelViewController
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        let existingTravel = UIAlertAction(title: "기존 여행에 핀 추가하기", style: .default) { [weak self](_) in
            print("DEBUG: 핀 추가 씬으로")
            if self!.tasks.isEmpty {
                self?.presentOkAlert(message: "기존 여행이 존재하지 않습니다. 새로운 여행을 만들어주세요.")
                return
            }
            
            
            let sb = UIStoryboard(name: "AddPin", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "AddPinViewController") as! AddPinViewController
            
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        sheet.addAction(existingTravel)
        sheet.addAction(newlyTravel)
        sheet.addAction(cancel)
        
        self.present(sheet, animated: true, completion: nil)
    }
    
    func addButtonconfig() -> UIBarButtonItem {
        let button = UIBarButtonItem(image: UIImage(systemName: "plus"),
                                     style: UIBarButtonItem.Style.done,
                                     target: self,
                                     action: #selector(addButtonClicked(_:)))
        
        return button
    }
    
    func navBarConfig() {
        self.navigationItem.rightBarButtonItem = addButtonconfig()
        self.navigationItem.leftBarButtonItem?.tintColor = .label
    }
    
    
    //MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        navBarConfig()
        
        tasks = localRealm.objects(TravelDocument.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
        if !locationUpdated, currentLocation != nil {
            self.loadMap(location: currentLocation!)
        }
        
    }
    

}

//MARK: LocationManager Delegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = locations.last?.coordinate {
            currentLocation = coordinate
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("DEBUG: \(error)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if #available(iOS 14.0, *) {
            print(#function)
            LocationManager.shared.checkUsersLocationServicesAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(#function)
        LocationManager.shared.checkUsersLocationServicesAuthorization()
    }
}
