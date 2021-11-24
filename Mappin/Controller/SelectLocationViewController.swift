//
//  SelectLocationViewController.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/21.
//

import UIKit
import GoogleMaps

class SelectLocationViewController: UIViewController {

    
    //MARK: Properties
    
    var location: CLLocationCoordinate2D?
    
    
    //MARK: UI
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    //MARK: Method
    
    @objc func dismissButtonClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func completeButtonClicked(_ sender: UIBarButtonItem) {
        
        if let nvc = self.presentingViewController as? UINavigationController {
            guard let vc = nvc.topViewController as? AddTravelViewController else {
                print("DEBUG: presentingViewController 변환 못하는데??")
                return
            }
            
            vc.pinLocation = mapView.camera.target
//            LocationManager.shared.getAddress(location: CLLocation(latitude: mapView.camera.target.latitude,
//                                                                   longitude: mapView.camera.target.longitude),
//                                              completion: { _ in
//                // 주소 쓸 일 있을 때 추가하면 됨
//            })
        }
        dismiss(animated: true, completion: nil)
    }
    
    func mapViewConfig(location: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude,
                                              longitude: location.longitude,
                                              zoom: 16)
        mapView.settings.scrollGestures = true
        mapView.settings.zoomGestures = true
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        mapView.camera = camera
        mapView.delegate = self
        
        let pinImageView = UIImageView(image: UIImage(named: "pin"))
        
        self.view.addSubview(pinImageView)
        pinImageView.frame.size = CGSize(width: 40, height: 40)
        pinImageView.center = view.center
        pinImageView.center.y -= 10
    }
    
    func navBarConfig() {
        
        
        let navItem = UINavigationItem(title: "위치 설정")
        
        let dismissButton = UIBarButtonItem(image: UIImage(systemName: "xmark"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(dismissButtonClicked(_:)))
        let completeButton = UIBarButtonItem(image: UIImage(systemName: "paperplane"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(completeButtonClicked(_:)))
        
        navItem.leftBarButtonItem = dismissButton
        navItem.rightBarButtonItem = completeButton
        
        navBar.setItems([navItem], animated: false)
        navBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navBarConfig()
        
        if location != nil {
            mapViewConfig(location: location!)
        } else  {
            mapViewConfig(location: LocationManager.shared.currentLocation)
        }
        
    }
}

//MARK: MapView Delegate
extension SelectLocationViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        print(mapView.camera.target)
        
        // 핀 위치: 37.4987508201444
        // 실제 위치: 37.4987358201444
    }
}
