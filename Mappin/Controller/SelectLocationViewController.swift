//
//  SelectLocationViewController.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/21.
//

import UIKit
import GoogleMaps
import GooglePlaces
import RealmSwift

class SelectLocationViewController: UIViewController {

    
    //MARK: Properties
    
    var location: CLLocationCoordinate2D?
    
    var searchTimer: Timer?
    
    var placesClient: GMSPlacesClient!
    
    var searchResults = [SearchResult]()
    
    var searchText = ""
    
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
    
    var tableView: UITableView!
    
    var searchBar: UISearchBar!
    
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
    
    func tableViewConfig() {
        
        tableView = UITableView(frame: CGRect(x: 20, y: 100, width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.height - 140), style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self

        tableView.backgroundColor = .clear
        tableView.layer.cornerRadius = 10
        view.addSubview(tableView)
        tableView.isHidden = true
        
        let nib = UINib(nibName: LocationInfoTableViewCell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: LocationInfoTableViewCell.identifier)
        
        let nib2 = UINib(nibName: DefaultTableViewCell.identifier, bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: DefaultTableViewCell.identifier)
    }
    
    func searchBarConfig() {
        searchBar = UISearchBar()
        
        view.addSubview(searchBar)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 10).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -10).isActive = true
        searchBar.centerYAnchor.constraint(equalTo: backButton.centerYAnchor, constant: 0).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
    
        searchBar.searchTextField.textColor = .black
        searchBar.autocorrectionType = .no
        searchBar.autocapitalizationType = .none
        searchBar.searchTextField.backgroundColor = .white
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.placeholder = "Search".localized()
        
        searchBar.delegate = self
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
        
        placesClient = GMSPlacesClient.shared()
        
        searchBarConfig()
        tableViewConfig()
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

extension SelectLocationViewController: GMSAutocompleteTableDataSourceDelegate {
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWith place: GMSPlace) {
        
        let camera = GMSCameraPosition(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 18)
        
        CATransaction.begin()
        CATransaction.setValue(0.2, forKey: kCATransactionAnimationDuration)
        mapView.animate(to: camera)
        CATransaction.commit()
        
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: Error) {
        print("ERROR")
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didSelect prediction: GMSAutocompletePrediction) -> Bool {
        tableView.isHidden = true
        return true
    }
    
    func didUpdateAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        tableView.reloadData()
    }
    
    func didRequestAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        tableView.reloadData()
    }
    
}

//MARK: SearchBar Delegate
extension SelectLocationViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.searchText = searchText
        
        if searchText.isEmpty {
            tableView.isHidden = true
        } else {
            tableView.isHidden = false
        }
        
        self.searchTimer?.invalidate()
        self.searchTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { [weak self](_) in
            LoadingIndicator.shared.showIndicator()
            
            self?.searchResults.removeAll()
            
            let token = GMSAutocompleteSessionToken()
            let filter = GMSAutocompleteFilter()
            filter.type = .establishment
            
            DispatchQueue.main.async {
                self?.placesClient.findAutocompletePredictions(fromQuery: searchText,
                                                               filter: filter,
                                                               sessionToken: token) { results, error in
                    if let error = error {
                        print("ERROR: \(error)")
                        LoadingIndicator.shared.hideIndicator()
                        return
                    }
                    if let results = results {
                        let group = DispatchGroup()
                        
                        for result in results {
                            group.enter()
                            let id = result.placeID
                            let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
                                                                      UInt(GMSPlaceField.coordinate.rawValue))
                            
                            self?.placesClient.fetchPlace(fromPlaceID: id,
                                                          placeFields: fields,
                                                          sessionToken: nil) { place, error in
                                if let error = error {
                                    print("fetch Place Error: \(error)")
                                    return
                                }
                                if let place = place {
                                    let result = SearchResult(primaryString: result.attributedPrimaryText,
                                                              secondaryString: result.attributedSecondaryText ?? NSAttributedString(string: ""),
                                                              coordinate: place.coordinate)
                                    self?.searchResults.append(result)
                                    group.leave()
                                }
                            }
                        }
                        group.notify(queue: DispatchQueue.main) {
                            LoadingIndicator.shared.hideIndicator()
                            self?.tableView.reloadData()
                        }
                    }
                }
            }
            
            
        })
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if !(searchBar.text!.isEmpty) {
            tableView.isHidden = false
            tableView.reloadData()
        }
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}


//MARK: ScrollView Delegate
extension SelectLocationViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
        if scrollView.contentOffset.y < -60 || scrollView.contentOffset.y > 60{
            DispatchQueue.main.async { [weak self] in
                UIView.animate(withDuration: 0.2) {
                    self?.tableView.isHidden = true
                    self?.view.endEditing(true)
                }
            }
        }
    }
}


//MARK: TableView Delegate
extension SelectLocationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count == 0 ? 1 : searchResults.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LocationInfoTableViewCell.identifier, for: indexPath) as? LocationInfoTableViewCell else {
            return UITableViewCell()
        }
        
        guard let errorCell = tableView.dequeueReusableCell(withIdentifier: DefaultTableViewCell.identifier, for: indexPath) as? DefaultTableViewCell else {
            return UITableViewCell()
        }
        
        if searchResults.isEmpty {
            errorCell.defaultLabel.text = "검색 결과가 없거나\n네트워크에 연결되어 있지 않습니다."
            errorCell.defaultLabel.font = UIFont().mainFontBold
            
            return errorCell
        }
        
        let data = searchResults[indexPath.row]
        
        let title = data.primaryString.string
        let attrTitle = NSMutableAttributedString(string: title)
        
        
        if title.uppercased().contains(searchText.uppercased()) {
            attrTitle.addAttribute(.foregroundColor, value: UIColor.orange, range: (searchText as NSString).range(of: searchText))
        }
        
        
        
        cell.locationTitleLabel.textColor = .black
        cell.locationTitleLabel.attributedText = attrTitle
        cell.locationTitleLabel.font = UIFont().mainFontRegular
        
        
        cell.locationAddressLabel.attributedText = data.secondaryString
        cell.locationAddressLabel.font = UIFont().smallFontRegular
        cell.locationAddressLabel.textColor = .darkGray
        
        cell.contentView.backgroundColor = .white
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        let coordinate = searchResults[indexPath.row].coordinate
        let camera = GMSCameraPosition(latitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 18)
        
        CATransaction.begin()
        CATransaction.setValue(0.2, forKey: kCATransactionAnimationDuration)
        mapView.animate(to: camera)
        CATransaction.commit()
        
        tableView.isHidden = true
    }
}
