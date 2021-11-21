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
    
    
    
    //MARK: UI
    
    @IBOutlet weak var mapView: GMSMapView!
    
    
    //MARK: Method
    
    @objc func dismissButtonClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func completeButtonClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func mapViewConfig(location: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude,
                                              longitude: location.longitude,
                                              zoom: 16)
        mapView.settings.scrollGestures = true
        mapView.settings.zoomGestures = true
        mapView.settings.myLocationButton = true
        mapView.camera = camera
        
        let pinImageView = UIImageView(image: UIImage(named: "pin"))
        
        self.view.addSubview(pinImageView)
        pinImageView.center = view.center
    }
    
    func navBarConfig() {
        let dismissButton = UIBarButtonItem(image: UIImage(systemName: "xmark"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(dismissButtonClicked(_:)))
        let completeButton = UIBarButtonItem(image: UIImage(systemName: "paperplane"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(completeButtonClicked(_:)))
        
        self.navigationItem.leftBarButtonItem = dismissButton
        self.navigationItem.rightBarButtonItem = completeButton
    }
    
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navBarConfig()
        mapViewConfig(location: LocationManager.shared.currentLocation)
    }
}
