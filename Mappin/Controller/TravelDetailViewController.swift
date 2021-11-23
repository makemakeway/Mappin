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
    
    @IBOutlet weak var pageControll: UIPageControl!
    
    //MARK: Method
    
    func carouselViewConfig() {
        carouselView.delegate = self
        carouselView.dataSource = self
        let nib = UINib(nibName: TravelDetailCollectionViewCell.identifier, bundle: nil)
        carouselView.register(nib, forCellWithReuseIdentifier: TravelDetailCollectionViewCell.identifier)
        
        let cellWidth = UIScreen.main.bounds.width
        let cellHeight = carouselView.frame.height - 20
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        
        carouselView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        carouselView.collectionViewLayout = flowLayout
        carouselView.isPagingEnabled = true
        carouselView.showsHorizontalScrollIndicator = false
        carouselView.decelerationRate = UIScrollView.DecelerationRate.fast
        
    }
    
    func scrollViewConfig() {
        mainScrollView.contentInsetAdjustmentBehavior = .never
    }
    
    func pageControllConfig() {
        pageControll.numberOfPages = photoImages.count
        pageControll.currentPage = 0
        pageControll.pageIndicatorTintColor = .darkGray
        pageControll.currentPageIndicatorTintColor = .white
        pageControll.isUserInteractionEnabled = false
    }
    
    func navbarConfig() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollViewConfig()
        carouselViewConfig()
        navbarConfig()
        
        if photoImages.count >= 2 {
            pageControllConfig()
        } else {
            pageControll.isHidden = true
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
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
        
        cell.photoImage.image = photoImages[indexPath.row]
        cell.photoImage.contentMode = .scaleAspectFill
        
        return cell
    }
}

//MARK: ScrollView delegate
extension TravelDetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControll.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
}
