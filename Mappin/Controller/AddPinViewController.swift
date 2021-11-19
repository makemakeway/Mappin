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
    
    var titleSource = [String]()
    
    var tasks: Results<TravelDocument>!
    
    let datePicker = UIDatePicker()
    
    
    //MARK: UI
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var documentTitleTextField: UITextField!
    
    @IBOutlet weak var dateTextField: UITextField!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var titleStackView: UIStackView!
    
    @IBOutlet weak var dateStackView: UIStackView!
    
    @IBOutlet weak var locationStackView: UIStackView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    
    //MARK: Method
    @objc func addPin(_ sender: UIBarButtonItem) {
        print("DEBUG: 핀 추가")
    }
    
    @objc func selectButtonClicked(_ sender: UIBarButtonItem) {
        print("DEBUG: 선택")
        
        dateTextField.text = dateToString(date: datePicker.date)
    }
    

    
    func titleTextFieldConfig() {
        documentTitleTextField.placeholder = "타이틀을 선택해주세요."
        documentTitleTextField.font = UIFont.systemFont(ofSize: 18)
        
        let titlePickerView = UIPickerView()
        titlePickerView.delegate = self
        titlePickerView.dataSource = self
        
        documentTitleTextField.inputView = titlePickerView
        
        makeUnderLine(view: titleStackView)
    }
    
    func titleSourceUpdate() {
        for task in tasks {
            titleSource.append(task.documentTitle)
        }
    }
    
    func dateTextFieldConfig() {
        dateTextField.placeholder = "날짜를 선택해주세요."
        dateTextField.font = UIFont.systemFont(ofSize: 18)
        
        dateTextField.inputView = datePicker
        
        makeUnderLine(view: dateStackView)
    }
    
    func datePickerConfig() {
        datePicker.datePickerMode = .date
        
        datePicker.maximumDate = Date()
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.sizeToFit()
        
        let selectButton = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(selectButtonClicked(_:)))
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        toolBar.setItems([space, selectButton], animated: false)
        
        dateTextField.inputAccessoryView = toolBar
    }
    
    func locationLabelConfig() {
        locationLabel.text = "위치를 선택해주세요."
        locationLabel.font = UIFont.systemFont(ofSize: 18)
        
        makeUnderLine(view: locationStackView)
    }
    
    func makeUnderLine(view: UIView) {
        let underline = CALayer()
        
        underline.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width - 25, height: 0.5)
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
        
        marker.icon = GMSMarker.markerImage(with: UIColor.blue)
        
        marker.map = mapView
    }
    
    func navBarConfig() {
        let button = UIBarButtonItem(image: UIImage(systemName: "paperplane"),
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
        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        contentTextView.layer.borderWidth = 0.5
        
        contentTextView.delegate = self
        contentTextView.text = "내용"
        contentTextView.textColor = .darkGray
        contentTextView.font = UIFont.systemFont(ofSize: 18)
    }
    
    func scrollViewConfig() {
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
    }
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tasks = localRealm.objects(TravelDocument.self)
        
        titleSourceUpdate()
        navBarConfig()
        collectionViewConfig()
        
        textViewConfig()
        
        dateTextFieldConfig()
        datePickerConfig()
        dateTextField.text = dateToString(date: Date())
        
        locationLabelConfig()
        
        scrollViewConfig()
        self.loadMap(location: pinLocation)
        
        titleTextFieldConfig()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        drawPin()
        
        guard let address = locationAddress else {
            print("DEBUG: 주소 없엉 ㅠㅠ")
            return
        }
        locationLabel.text = address
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
                cell.photoImageView.backgroundColor = .lightGray
                cell.photoImageView.tintColor = .white
            }
        }
        else {
            cell.photoImageView.image = UIImage(systemName: "camera")
            cell.photoImageView.backgroundColor = .lightGray
            cell.photoImageView.tintColor = .white
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


//MARK: ScrollView Delegate
extension AddPinViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if dateTextField.isEditing || documentTitleTextField.isEditing {
            view.endEditing(true)
        }
        
        
        if scrollView.contentOffset.y < -40 {
            contentTextView.resignFirstResponder()
        }
    }
}


//MARK: Picker Delegate
extension AddPinViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return tasks.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return titleSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.documentTitleTextField.text = titleSource[row]
    }
    
}

//MARK: TextView Delegate

extension AddPinViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        setKeyboardObserver()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .darkGray {
            textView.text = nil
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            contentTextView.text = "내용"
            contentTextView.textColor = .darkGray
        }
        removeKeyboardObserver()
    }
}
