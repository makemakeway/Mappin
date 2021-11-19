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
    
    func mapViewConfig() {
        mapView.settings.scrollGestures = false
        mapView.settings.zoomGestures = false
        mapView.settings.tiltGestures = false
        mapView.settings.rotateGestures = false
        
        mapView.isMyLocationEnabled = true
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
    
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navBarConfig()
        collectionViewConfig()
        mapViewConfig()
    }
    

}

//MARK: CollectionView Delegate

extension AddPinViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as? PhotoCollectionViewCell else {
            print("DEBUG: 셀 변환 실패함 ㅋㅋ")
            return UICollectionViewCell()
        }
        
        cell.photoImageView.image = UIImage(systemName: "camera")
        cell.photoImageView.backgroundColor = .blue
        cell.layer.cornerRadius = 10
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height = collectionView.frame.height - 20
        
        return CGSize(width: height, height: height)
    }
    
}
