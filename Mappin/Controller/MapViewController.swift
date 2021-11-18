//
//  MapViewController.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/17.
//

import UIKit
import CoreLocation
import GoogleMaps

class MapViewController: UIViewController {

    
    //MARK: Properties
    var currentLocation: CLLocationCoordinate2D? {
        didSet {
            print("DEBUG: 현재 위치 = \(currentLocation!)")
            if !locationUpdated {
                loadMap()
            }
        }
    }
    
    var locationManager = LocationManager.shared.manager
    
    var locationUpdated = false
    
    //MARK: UI
    
    
    
    //MARK: Method
    
    @objc func addButtonClicked(_ sender: UIBarButtonItem) {
        print("DEBUG: Add button clicked")
        presentActionSheet()
    }
    
    func presentActionSheet() {
        let sheet = UIAlertController(title: "핀 추가", message: nil, preferredStyle: .actionSheet)
        
        let newlyTravel = UIAlertAction(title: "새로운 여행에 핀 추가하기", style: .default) { _ in
            print("DEBUG: 새로운 여행 추가 씬으로")
        }
        
        let existingTravel = UIAlertAction(title: "기존 여행에 핀 추가하기", style: .default) { _ in
            print("DEBUG: 핀 추가 씬으로")
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
    
    func loadMap() {
        guard let location = currentLocation else {
            print("DEBUG: 위치 정보 없음")
            return
        }
        
        let camera = GMSCameraPosition.camera(
            withLatitude: location.latitude,
            longitude: location.longitude,
            zoom: 16)

        let mapView = GMSMapView.map(withFrame: view.frame, camera: camera)
        mapView.settings.scrollGestures = true
        mapView.settings.zoomGestures = true
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        
        self.view.addSubview(mapView)
        locationUpdated = true
    }
    
    
    //MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        navBarConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
        if !locationUpdated {
            loadMap()
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
