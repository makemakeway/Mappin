//
//  TravelDetailViewController.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/23.
//

import UIKit
import PanModal
import ImageSlideshow

class TravelDetailViewController: UIViewController {

    
    //MARK: Properties
    
    var task: MemoryData?
    
    var photoImages = [UIImage]()
    
    @IBOutlet weak var imageSlider: ImageSlideshow!
    
    
    //MARK: UI
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    @IBOutlet weak var locationTitleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var memoryContentLabel: UILabel!
    
    @IBOutlet weak var headerView: UIView!
    
    
    //MARK: Method
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        print("image tap")
        imageSlider.presentFullScreenController(from: self, completion: nil)
    }
    
    func headerViewConfig() {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: headerView.frame.height, width: headerView.frame.width - 30, height: 1)
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        headerView.layer.addSublayer(bottomLine)
    }
    
    func locationTitleLabelConfig() {
        
        if let task = task {
            locationTitleLabel.text = task.memoryDescription
        }
        
    }
    
    func dateLabelConfig() {
        if let task = task {
            dateLabel.text = dateToString(date: task.memoryDate)
        }
    }
    
    func memoryContentLabelConfig() {
        if let task = task {
            memoryContentLabel.text = task.memoryContent
        }
    }
    
    func imageSliderConfig() {
        var inputSource = [ImageSource]()
        
        inputSource = photoImages.map({ ImageSource(image: $0) })
        
        imageSlider.setImageInputs(inputSource)
        imageSlider.contentScaleMode = .scaleAspectFill
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        imageSlider.addGestureRecognizer(gesture)
    }
    
    
    func loadImages() {
        if let task = task {
            for imageName in task.memoryPicture {
                guard let image = ImageManager.shared.loadImageFromDocumentDirectory(imageName: "\(imageName).jpeg") else {
                    return
                }
                photoImages.append(image)
            }
        }
    }
    
    func scrollViewConfig() {
        mainScrollView.contentInsetAdjustmentBehavior = .never
        mainScrollView.showsVerticalScrollIndicator = false
    }
    
    func navbarConfig() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImages()
        scrollViewConfig()
        navbarConfig()
        imageSliderConfig()
        
        locationTitleLabelConfig()
        dateLabelConfig()
        memoryContentLabelConfig()
        headerViewConfig()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
}


//MARK: ScrollView delegate
extension TravelDetailViewController: UIScrollViewDelegate {
    
}

//MARK: PanModal
extension TravelDetailViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return mainScrollView
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(UIScreen.main.bounds.height * 0.5)
    }
    var longFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(20)
    }
    
}
