//
//  TravelDetailViewController.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/23.
//

import UIKit

class TravelDetailViewController: UIViewController {

    
    //MARK: Properties
    
    var photoImages = [UIImage]()
    
    
    
    //MARK: UI
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    @IBOutlet weak var carouselView: UICollectionView!
    
    //MARK: Method
    
    func carouselViewConfig() {
        carouselView.delegate = self
        carouselView.dataSource = self
        
        let flowLayout = UICollectionViewFlowLayout()
        
        
        carouselView.collectionViewLayout = flowLayout
    }
    
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .darkGray
    }
    
}

//MARK: CollectionView extension
extension TravelDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TravelDetailCollectionViewCell.identifier, for: indexPath) as? TravelDetailCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        return cell
    }
    
    
}
