//
//  AddTravelViewController.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/18.
//

import UIKit
import RealmSwift
import GoogleMaps
import CoreLocation

class AddTravelViewController: UIViewController {

    
    //MARK: Properties
    
    let localRealm = try! Realm()
    
    var tasks: Results<LocationDocument>!
    
    var nationalCode = ""
    
    var pinLocation = LocationManager.shared.currentLocation {
        didSet {
            mapView.clear()
            loadMap(location: pinLocation)
            drawPin()
            LocationManager.shared.getAddress(location: CLLocation(latitude: pinLocation.latitude,
                                                                   longitude: pinLocation.longitude)) { [weak self](code) in
                self?.nationalCode = code
            }
        }
    }
    
    let locationManager = LocationManager.shared.manager
    
    //MARK: UI
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    //MARK: Method
    
    @objc func forwardButtonClicked(_ sender: UIBarButtonItem) {
        print("DEBUG: forwardButtonClicked")
        
        if checkTitleIsValid() {
            print("DEBUG: 유효한 타이틀")
            
            let location = List<Double>()
            location.append(pinLocation.latitude)
            location.append(pinLocation.longitude)
            
            try! localRealm.write {
                localRealm.add(LocationDocument(title: titleTextField.text!,
                                                memoryList: List<MemoryData>(),
                                                location: location,
                                                nationalCode: nationalCode,
                                                latest: Date(),
                                                oldest: Date(),
                                                lastUpdated: Date()))
            }
            
            let sb = UIStoryboard(name: "AddPin", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "AddPinViewController") as! AddPinViewController
            vc.documentTitle = titleTextField.text!
            
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            print("DEBUG: 유효하지 않은 타이틀")
        }

    }
    
    @objc func mapViewClicked(gesture: UITapGestureRecognizer) {
        let sb = UIStoryboard(name: "SelectLocation", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "SelectLocationViewController") as! SelectLocationViewController
        vc.modalPresentationStyle = .fullScreen
        vc.location = pinLocation
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func loadMap(location: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(
            withLatitude: location.latitude,
            longitude: location.longitude,
            zoom: 16)

        mapView.settings.scrollGestures = false
        mapView.settings.zoomGestures = false
        mapView.settings.tiltGestures = false
        mapView.settings.rotateGestures = false
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(mapViewClicked(gesture:)))
        
        mapView.addGestureRecognizer(gesture)
        
        mapView.camera = camera
    }
    
    func drawPin() {
        
        let marker = GMSMarker(position: pinLocation)
        
        
        marker.map = mapView
    }
    
    func checkTitleIsValid() -> Bool {
        
        guard let title = titleTextField.text, !(title.isEmpty) else {
            
            presentOkAlert(message: "추가하고 싶은 장소를 입력해주세요.")
            return false
        }
        
        
        if !(tasks.filter("documentTitle = '\(title)'").isEmpty) {
            print("쭝복임!")
            presentOkAlert(message: "이미 기록했던 장소입니다.\n다른 장소를 입력해주세요.")
            return false
        }
        
        return true
    }
    
    func navBarConfig() {
        let button = UIBarButtonItem(image: UIImage(systemName: "paperplane"),
                                     style: UIBarButtonItem.Style.plain,
                                     target: self,
                                     action: #selector(forwardButtonClicked(_:)))
        
        self.navigationItem.rightBarButtonItem = button
        self.title = "장소 추가"
        self.navigationItem.backButtonTitle = ""
    }
    
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        navBarConfig()
        
        loadMap(location: pinLocation)
        drawPin()
        
        titleTextField.font = UIFont().mainFontRegular
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.titleTextField.becomeFirstResponder()
        
        tasks = localRealm.objects(LocationDocument.self)
    }
}


extension AddTravelViewController: CLLocationManagerDelegate {
    @available (iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print(#function)
        LocationManager.shared.checkUsersLocationServicesAuthorization()
        let auth = LocationManager.shared.manager.authorizationStatus
        switch manager.authorizationStatus {
        case .denied:
            authorizationHandling(title: "위치 접근 권한 요청", message: "위치 접근 권한을 허용해야 앱을 이용할 수 있습니다.")
        case .notDetermined, .restricted:
            LocationManager.shared.checkCurrentLocationAutorization(status: auth)
        default:
            print("DEBUG: ㅋㅋ")
            pinLocation = LocationManager.shared.currentLocation
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(#function)
        LocationManager.shared.checkUsersLocationServicesAuthorization()
        let auth = CLLocationManager.authorizationStatus()
        switch status {
        case .denied:
            authorizationHandling(title: "위치 접근 권한 요청", message: "위치 접근 권한을 허용해야 앱을 이용할 수 있습니다.")
        case .notDetermined, .restricted:
            LocationManager.shared.checkCurrentLocationAutorization(status: auth)
        default:
            print("DEBUG: ㅋㅋ")
            pinLocation = LocationManager.shared.currentLocation
        }
    }
}
