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
    
    @objc func dismissButtonClicked(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func completeButtonClicked(_ sender: UIButton) {
        
        if let nvc = self.presentingViewController as? UINavigationController {
            guard let vc = nvc.topViewController as? AddTravelViewController else {
                print("DEBUG: presentingViewController 변환 못하는데??")
                return
            }
            
            vc.pinLocation = mapView.camera.target
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
        if #available(iOS 15, *) {
            let backButton = UIButton()

            iOS15ButtonConfig(image: UIImage(systemName: "xmark")!, button: backButton, backgroundColor: .white, foregroundColor: .darkGray)
            backButton.addTarget(self, action: #selector(dismissButtonClicked(_:)), for: .touchUpInside)

            view.addSubview(backButton)

            backButton.translatesAutoresizingMaskIntoConstraints = false
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 44).isActive = true
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true

            let addButton = UIButton()

            iOS15ButtonConfig(image: UIImage(systemName: "paperplane")!, button: addButton, backgroundColor: .white, foregroundColor: .darkGray)
            addButton.addTarget(self, action: #selector(completeButtonClicked(_:)), for: .touchUpInside)

            view.addSubview(addButton)

            addButton.translatesAutoresizingMaskIntoConstraints = false
            addButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 44).isActive = true
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true

        } else {
            let backButton = UIButton()

            iOS13ButtonConfig(image: UIImage(systemName: "xmark")!, button: backButton, backgroundColor: .white, foregroundColor: .darkGray)

            view.addSubview(backButton)

            backButton.translatesAutoresizingMaskIntoConstraints = false
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 48).isActive = true
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
            backButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
            backButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

            backButton.addTarget(self, action: #selector(dismissButtonClicked(_:)), for: .touchUpInside)

            let addButton = UIButton()

            iOS13ButtonConfig(image: UIImage(systemName: "paperplane")!, button: addButton, backgroundColor: .white, foregroundColor: .darkGray)

            view.addSubview(addButton)

            addButton.translatesAutoresizingMaskIntoConstraints = false
            addButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 48).isActive = true
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
            addButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
            addButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

            addButton.addTarget(self, action: #selector(completeButtonClicked(_:)), for: .touchUpInside)
        }
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
