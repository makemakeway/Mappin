//
//  SelectLocationViewController.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/21.
//

import UIKit
import GoogleMaps
import GooglePlaces

class SelectLocationViewController: UIViewController {

    
    //MARK: Properties
    
    var location: CLLocationCoordinate2D?
    
    
    //MARK: UI
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    lazy var backButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    lazy var addButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    var resultViewController: GMSAutocompleteResultsViewController!
    
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
    
    func searchBarConfig() {
        resultViewController = GMSAutocompleteResultsViewController()
        resultViewController.delegate = self
        
        let searchController = UISearchController(searchResultsController: resultViewController)
        searchController.searchResultsUpdater = resultViewController
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.searchTextField.backgroundColor = .white
        searchController.searchBar.searchTextField.borderStyle = .roundedRect
        searchController.searchBar.searchTextField.textColor = .black
        searchController.searchBar.delegate = self
        
        let subView = UIView()
        
        subView.addSubview(searchController.searchBar)
        view.addSubview(subView)
        
        searchController.searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchController.searchBar.leadingAnchor.constraint(equalTo: subView.leadingAnchor, constant: 0).isActive = true
        searchController.searchBar.trailingAnchor.constraint(equalTo: subView.trailingAnchor, constant: 0).isActive = true
        searchController.searchBar.centerYAnchor.constraint(equalTo: subView.centerYAnchor, constant: 0).isActive = true
        
        subView.translatesAutoresizingMaskIntoConstraints = false
        subView.centerYAnchor.constraint(equalTo: backButton.centerYAnchor, constant: 0).isActive = true
        subView.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 10).isActive = true
        subView.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -10).isActive = true
        subView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
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
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        if #available(iOS 15, *) {

            iOS15ButtonConfig(image: UIImage(systemName: "xmark")!, button: backButton, backgroundColor: .white, foregroundColor: .darkGray)
            backButton.addTarget(self, action: #selector(dismissButtonClicked(_:)), for: .touchUpInside)

            view.addSubview(backButton)

            backButton.translatesAutoresizingMaskIntoConstraints = false
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 48).isActive = true
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true


            iOS15ButtonConfig(image: UIImage(systemName: "paperplane")!, button: addButton, backgroundColor: .white, foregroundColor: .darkGray)
            addButton.addTarget(self, action: #selector(completeButtonClicked(_:)), for: .touchUpInside)

            view.addSubview(addButton)

            addButton.translatesAutoresizingMaskIntoConstraints = false
            addButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 48).isActive = true
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true

        } else {

            iOS13ButtonConfig(image: UIImage(systemName: "xmark")!, button: backButton, backgroundColor: .white, foregroundColor: .darkGray)

            view.addSubview(backButton)

            backButton.translatesAutoresizingMaskIntoConstraints = false
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 48).isActive = true
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
            backButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
            backButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

            backButton.addTarget(self, action: #selector(dismissButtonClicked(_:)), for: .touchUpInside)

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
    
    func checkAuthorization() {
        if #available(iOS 14, *) {
            switch LocationManager.shared.manager.authorizationStatus {
            case .denied:
                authorizationHandling(title: "Request for access to the location", message: "Please allow access Location to use the app.")
            default:
                print("ㅋㅋ")
            }
        } else {
            switch CLLocationManager.authorizationStatus() {
            case .denied:
                authorizationHandling(title: "Request for access to the location", message: "Please allow access Location to use the app.")
            default:
                print("ㅋㅋ")
            }
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
        
        searchBarConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkAuthorization()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
    }
    
}

//MARK: MapView Delegate
extension SelectLocationViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        print(mapView.camera.target)
        
        // 핀 위치: 37.4987508201444
        // 실제 위치: 37.4987358201444
    }
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        checkAuthorization()
        return false
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        print("Move")
        DispatchQueue.main.async { [weak self] in
            UIView.animate(withDuration: 0.2) {
                self?.view.endEditing(true)
            }
        }
        
    }
}

//MARK: GMSAutocompleteResultsViewControllerDelegate

extension SelectLocationViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        print(place)
        
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        print("kk")
    }
}

//MARK: SearchBar Delegate
extension SelectLocationViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
}
