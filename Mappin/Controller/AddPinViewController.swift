//
//  AddPinViewController.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/18.
//

import UIKit
import RealmSwift
import GoogleMaps


class AddPinViewController: UIViewController {

    
    //MARK: Properties
    let localRealm = try! Realm()
    
    var locationAddress = UserDefaults.standard.string(forKey: "userLocation")
    
    var pinLocation = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: "userLatitude"), longitude: UserDefaults.standard.double(forKey: "userLongitude"))
    
    var photoImages: [UIImage] = []
    
    //MARK: UI
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var documentTitleTextField: UITextField!
    
    @IBOutlet weak var dateTextField: UITextField!
    
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var contentTextView: UITextView!
    
    
    
    
    
    //MARK: Method
    @objc func addPin(_ sender: UIBarButtonItem) {
        print("DEBUG: 핀 추가")
    }
    
    func titleTextFieldConfig() {
        documentTitleTextField.placeholder = "타이틀 선택"
        documentTitleTextField.font = UIFont.systemFont(ofSize: 20)
        makeUnderLine(view: documentTitleTextField)
    }
    
    func dateTextFieldConfig() {
        dateTextField.placeholder = "날짜 선택"
        dateTextField.font = UIFont.systemFont(ofSize: 20)
        makeUnderLine(view: dateTextField)
    }
    
    func locationTextFieldConfig() {
        locationTextField.placeholder = "위치 선택"
        locationTextField.font = UIFont.systemFont(ofSize: 20)
        
        makeUnderLine(view: locationTextField)
    }
    
    func makeUnderLine(view: UIView) {
        let underline = CALayer()
        
        underline.frame = CGRect(x: 0, y: view.frame.height + 1, width: view.frame.width - 25, height: 1)
        underline.backgroundColor = UIColor.lightGray.cgColor
        view.layer.addSublayer(underline)
        
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
        
        
        mapView.camera = camera
    }
    
    func drawPin() {
        let marker = GMSMarker(position: pinLocation)
        marker.map = mapView
    }
    
    func navBarConfig() {
        let button = UIBarButtonItem(image: UIImage(),
                                     style: UIBarButtonItem.Style.plain,
                                     target: self,
                                     action: #selector(addPin(_:)))
        
        self.navigationItem.rightBarButtonItem = button
        self.title = "핀 추가"
    }
    
    func collectionViewConfig() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib(nibName: PhotoCollectionViewCell.identifier, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.scrollDirection = .horizontal
        
        collectionView.collectionViewLayout = flowLayout
    }
    
    func textViewConfig() {
        contentTextView.showsVerticalScrollIndicator = false
        contentTextView.autocorrectionType = .no
        contentTextView.autocapitalizationType = .none
    }
    
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navBarConfig()
        collectionViewConfig()
        textViewConfig()
        dateTextFieldConfig()
        locationTextFieldConfig()
        
        self.loadMap(location: pinLocation)
        drawPin()
        titleTextFieldConfig()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let address = locationAddress else {
            return
        }
        locationTextField.text = address
        
        
    }

}

//MARK: CollectionView Delegate

extension AddPinViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        return photoImages.count < 10 ? photoImages.count + 1 : photoImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as? PhotoCollectionViewCell else {
            print("DEBUG: 셀 변환 실패함 ㅋㅋ")
            return UICollectionViewCell()
        }
        
        if photoImages.count != 0 {
            let data = photoImages[indexPath.row]
            
            if photoImages.count < 10 && data.size.width != 0 {
                cell.photoImageView.image = data
            }
            else {
                cell.photoImageView.image = UIImage(systemName: "camera")
                cell.photoImageView.backgroundColor = .purple
            }
        }
        else {
            cell.photoImageView.image = UIImage(systemName: "camera")
            cell.photoImageView.backgroundColor = .purple
        }
        
        cell.layer.cornerRadius = 10
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height = collectionView.frame.height - 20
        
        return CGSize(width: height, height: height)
    }
    
}

