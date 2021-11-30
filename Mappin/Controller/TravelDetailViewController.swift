//
//  TravelDetailViewController.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/23.
//

import UIKit
import PanModal
import ImageSlideshow
import RealmSwift

class TravelDetailViewController: UIViewController {

    
    //MARK: Properties
    
    var task: MemoryData?
    
    var photoImages = [UIImage]()
    
    var throughMap = false
    
    var documentTitle = ""
    
    var gesture: UITapGestureRecognizer?
    
    let localRealm = try! Realm()
    
    //MARK: UI
    @IBOutlet weak var imageSlider: ImageSlideshow!
    
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
    
    @objc func moreButtonClicked(_ sender: UIButton) {
        print("more Button Clicked")
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let edit = UIAlertAction(title: "Edit the story".localized(), style: .default) { [weak self](_) in
            guard let self = self else { return }
            
            let sb = UIStoryboard(name: "AddPin", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "AddPinViewController") as! AddPinViewController
            vc.title = "Edit the story".localized()
            
            vc.memoryData = self.task
            vc.documentTitle = self.documentTitle
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        let delete = UIAlertAction(title: "Delete the story".localized(), style: .destructive) { [weak self](_) in
            guard let self = self, let task = self.task else { return }
            let alert = UIAlertController(title: nil, message: "Do you really want to delete the story?".localized(), preferredStyle: .alert)
            let ok = UIAlertAction(title: "Delete it".localized(), style: .default) { _ in
                try! self.localRealm.write {
                    guard let task = self.localRealm.object(ofType: MemoryData.self, forPrimaryKey: task._id) else {
                        return
                    }
                    let group = DispatchGroup()
                    for imageName in task.memoryPicture {
                        group.enter()
                        ImageManager.shared.deleteImageFromDocumentDirectory(imageName: imageName)
                        group.leave()
                    }
                    group.wait()
                    
                    self.localRealm.delete(task)
                    self.navigationController?.popViewController(animated: true)
                }
            }
            let cancel = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
            alert.addAction(ok)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        
        actionSheet.addAction(edit)
        actionSheet.addAction(delete)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func addGradient() {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: imageSlider.frame.width, height: imageSlider.frame.height / 6)
        gradient.colors = [UIColor(white: 0.5, alpha: 0.7).cgColor, UIColor(white: 0, alpha: 0).cgColor]
        imageSlider.layer.addSublayer(gradient)
    }
    
    func headerViewConfig() {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: headerView.frame.height, width: UIScreen.main.bounds.width - 40, height: 1)
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        headerView.layer.addSublayer(bottomLine)
    }
    
    func locationTitleLabelConfig() {
        
        if let task = task {
            locationTitleLabel.text = task.memoryDescription
            locationTitleLabel.font = UIFont().mainFontRegular
        }
        
    }
    
    func dateLabelConfig() {
        if let task = task {
            dateLabel.text = dateToString(date: task.memoryDate)
            dateLabel.font = UIFont().mainFontRegular
        }
    }
    
    func memoryContentLabelConfig() {
        if let task = task {
            memoryContentLabel.text = task.memoryContent
            memoryContentLabel.font = UIFont().mainFontRegular
        }
    }
    
    func imageSliderConfig() {
        var inputSource = [ImageSource]()
        
        inputSource = photoImages.map({ ImageSource(image: $0) })
        
        imageSlider.setImageInputs(inputSource)
        imageSlider.contentScaleMode = .scaleAspectFill
        imageSlider.insetsLayoutMarginsFromSafeArea = true
    }
    
    
    func loadImages() {
        photoImages.removeAll()
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
        self.navigationItem.backButtonTitle = ""
    }
    
    func moreButtonConfig() {
        if #available(iOS 15, *) {
            let menuButton = UIButton()
            
            iOS15ButtonConfig(image: UIImage(systemName: "ellipsis")!, button: menuButton, backgroundColor: .darkGray, foregroundColor: .white)
            
            view.addSubview(menuButton)
            
            menuButton.translatesAutoresizingMaskIntoConstraints = false
            menuButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -48).isActive = true
            menuButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
            menuButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
            menuButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
            menuButton.addTarget(self, action: #selector(moreButtonClicked(_:)), for: .touchUpInside)
        } else {
            let menuButton = UIButton()
            
            iOS13ButtonConfig(image: UIImage(systemName: "ellipsis")!, button: menuButton, backgroundColor: .darkGray, foregroundColor: .white)
            
            view.addSubview(menuButton)
            
            menuButton.translatesAutoresizingMaskIntoConstraints = false
            menuButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -48).isActive = true
            menuButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
            menuButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
            menuButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
            menuButton.addTarget(self, action: #selector(moreButtonClicked(_:)), for: .touchUpInside)
        }
    }
    
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollViewConfig()
        navbarConfig()
        
        if !throughMap {
            addGradient()
            moreButtonConfig()
        }
        let gesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        imageSlider.addGestureRecognizer(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadImages()
        imageSliderConfig()
        
        locationTitleLabelConfig()
        dateLabelConfig()
        memoryContentLabelConfig()
        headerViewConfig()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
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
        return .maxHeightWithTopInset(0)
    }
    
}
