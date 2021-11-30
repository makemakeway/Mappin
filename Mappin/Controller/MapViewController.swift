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
    var currentLocation: CLLocationCoordinate2D = LocationManager.shared.currentLocation {
        didSet {
            print("DEBUG: 현재 위치 = \(currentLocation)")
            if !locationUpdated {
                loadMap(location: currentLocation)
            }
        }
    }
    
    var locationManager = LocationManager.shared.manager
    
    var locationUpdated = false
    
    let localRealm = try! Realm()
    
    var tasks: Results<LocationDocument>!
    
    //MARK: UI
    
    @IBOutlet weak var mapView: GMSMapView!
    
    
    //MARK: Method
    
    @objc func addButtonClicked(_ sender: UIButton) {
        print("DEBUG: Add button clicked")
        presentActionSheet()
    }
    
    @objc func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func emptyDataDelete() {
        let emptyData = tasks.filter({ $0.memoryList.isEmpty == true })
        
        for task in emptyData {
            try! localRealm.write {
                print("DEBUG: 비어있는 데이터 삭제함 \(task)")
                localRealm.delete(task.self)
            }
        }
        mapView.clear()
        addPin()
    }
    
    func loadMap(location: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(
            withLatitude: location.latitude,
            longitude: location.longitude,
            zoom: 14)

        mapView.settings.scrollGestures = true
        mapView.settings.zoomGestures = true
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.camera = camera
        mapView.delegate = self
    }
    
    func addPin() {
        for task in tasks {
            let latitude = task.locationCoordinate[0]
            let longitude = task.locationCoordinate[1]
            
            let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: latitude,
                                                                    longitude: longitude))
            marker.userData = task
            marker.map = mapView
            
        }
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
        let sheet = UIAlertController(title: "Add a story".localized(), message: nil, preferredStyle: .actionSheet)
        
        let newlyTravel = UIAlertAction(title: "Add a story to a new place".localized(), style: .default) { _ in
            print("DEBUG: 새로운 장소 추가 씬으로")
            let sb = UIStoryboard(name: "AddTravel", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "AddTravelViewController") as! AddTravelViewController
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        let existingTravel = UIAlertAction(title: "Add a story to the existing place".localized(), style: .default) { [weak self](_) in
            print("DEBUG: 기록 추가 씬으로")
            if self!.tasks.isEmpty {
                self?.presentOkAlert(message: "The existing place does not exist. Please create a new place.".localized())
                return
            }
            
            
            let sb = UIStoryboard(name: "AddPin", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "AddPinViewController") as! AddPinViewController
            
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        let cancel = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        
        sheet.addAction(existingTravel)
        sheet.addAction(newlyTravel)
        sheet.addAction(cancel)
        
        self.present(sheet, animated: true, completion: nil)
    }
    
    
    
    func navBarConfig() {
        if #available(iOS 15, *) {
            let backButton = UIButton()

            iOS15ButtonConfig(image: UIImage(systemName: "chevron.left")!, button: backButton, backgroundColor: .white, foregroundColor: .darkGray)
            backButton.addTarget(self, action: #selector(backButtonClicked(_:)), for: .touchUpInside)

            view.addSubview(backButton)

            backButton.translatesAutoresizingMaskIntoConstraints = false
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 44).isActive = true
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true

            let addButton = UIButton()

            iOS15ButtonConfig(image: UIImage(systemName: "plus")!, button: addButton, backgroundColor: .white, foregroundColor: .darkGray)
            addButton.addTarget(self, action: #selector(addButtonClicked(_:)), for: .touchUpInside)

            view.addSubview(addButton)

            addButton.translatesAutoresizingMaskIntoConstraints = false
            addButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 44).isActive = true
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true

        } else {
            let backButton = UIButton()

            iOS13ButtonConfig(image: UIImage(systemName: "chevron.left")!, button: backButton, backgroundColor: .white, foregroundColor: .darkGray)

            view.addSubview(backButton)

            backButton.translatesAutoresizingMaskIntoConstraints = false
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 48).isActive = true
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
            backButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
            backButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

            backButton.addTarget(self, action: #selector(backButtonClicked(_:)), for: .touchUpInside)

            let addButton = UIButton()

            iOS13ButtonConfig(image: UIImage(systemName: "plus")!, button: addButton, backgroundColor: .white, foregroundColor: .darkGray)

            view.addSubview(addButton)

            addButton.translatesAutoresizingMaskIntoConstraints = false
            addButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 48).isActive = true
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
            addButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
            addButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

            addButton.addTarget(self, action: #selector(addButtonClicked(_:)), for: .touchUpInside)
        }
        
        navigationItem.backButtonTitle = ""
    }
    
    
    
    
    //MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        navBarConfig()
        print("viewDidload")
        tasks = localRealm.objects(LocationDocument.self)
        if !locationUpdated {
            self.loadMap(location: currentLocation)
        }
        addPin()
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
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
    
    @available (iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print(#function)
        LocationManager.shared.checkUsersLocationServicesAuthorization()
        switch manager.authorizationStatus {
        case .denied:
            authorizationHandling(title: "Request for access to the location", message: "You need to allow location access to use the app.")
        default:
            print("DEBUG: ㅋㅋ")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(#function)
        LocationManager.shared.checkUsersLocationServicesAuthorization()
        switch status {
        case .denied:
            authorizationHandling(title: "Request for access to the location", message: "You need to allow location access to use the app.")
        default:
            print("DEBUG: ㅋㅋ")
        }
    }
}

//MARK: GMSMapView delegate
extension MapViewController: GMSMapViewDelegate {
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        if #available(iOS 14, *) {
            switch locationManager.authorizationStatus {
            case .denied:
                authorizationHandling(title: "Request for access to the location", message: "You need to allow location access to use the app.")
                return true
            default:
                print("DEBUG: \(#function)")
                return false
            }
        } else {
            switch CLLocationManager.authorizationStatus() {
            case .denied:
                authorizationHandling(title: "Request for access to the location", message: "You need to allow location access to use the app.")
                return true
            default:
                print("DEBUG: \(#function)")
                return false
            }
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("tap \(marker)")
        let zoom = mapView.camera.zoom
        let camera = GMSCameraPosition(latitude: marker.position.latitude, longitude: marker.position.longitude, zoom: zoom)
        
        CATransaction.begin()
        CATransaction.setValue(0.1, forKey: kCATransactionAnimationDuration)
        mapView.animate(to: camera)
        CATransaction.commit()
        
        let sb = UIStoryboard(name: "MarkerInfo", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "MarkerInfoViewController") as! MarkerInfoViewController
        vc.document = marker.userData as? LocationDocument

        self.presentPanModal(vc)
        
        return true
    }
}
