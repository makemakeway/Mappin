//
//  AddPinViewController.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/18.
//

import UIKit
import RealmSwift
import GoogleMaps
import PhotosUI


class AddPinViewController: UIViewController {

    
    //MARK: Properties
    let localRealm = try! Realm()
    
    var locationAddress = UserDefaults.standard.string(forKey: "userLocation")
    
    var pinLocation = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: "userLatitude"), longitude: UserDefaults.standard.double(forKey: "userLongitude"))
    
    var photoImages: [UIImage] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
            
        }
    }
    
    var titleSource = [String]()
    
    var tasks: Results<TravelDocument>!
    
    let datePicker = UIDatePicker()
    
    let titlePickerView = UIPickerView()
    
    var pickerIndex = 0
    
    var documentTitle: String? = nil
    
    //MARK: UI
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var documentTitleTextField: CustomTextField!
    
    @IBOutlet weak var dateTextField: UITextField!
    
    @IBOutlet weak var locationTextField: CustomTextField!
    
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
        
        if sender.tag == 0 {
            dateTextField.text = dateToString(date: datePicker.date)
        } else {
            print("도큐먼트")
            documentTitleTextField.text = titleSource[pickerIndex]
        }
        
        view.endEditing(true)
    }
    
    @objc func cameraImageClicked(_ gesture: CustomGesture) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: "카메라로 사진 찍기", style: .default) { [weak self](_) in
            let picker = self?.makePhotoPicker(type: .camera)
            picker?.modalPresentationStyle = .fullScreen
            self?.present(picker!, animated: true, completion: nil)
            
        }
        
        let library = UIAlertAction(title: "갤러리에서 사진 선택", style: .default) { [weak self](_) in
            
            if #available(iOS 14, *) {
                let picker = self?.makePHPicker()
                picker?.modalPresentationStyle = .fullScreen
                self?.present(picker!, animated: true, completion: nil)
            } else {
                let picker = self?.makePhotoPicker(type: .photoLibrary)
                picker?.modalPresentationStyle = .fullScreen
                self?.present(picker!, animated: true, completion: nil)
            }
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        sheet.addAction(library)
        sheet.addAction(camera)
        sheet.addAction(cancel)
        
        self.present(sheet, animated: true, completion: nil)
    }
    
    func makePhotoPicker(type: UIImagePickerController.SourceType) -> UIImagePickerController {
        
        let picker = UIImagePickerController()
        picker.sourceType = type
        picker.allowsEditing = true
        picker.delegate = self
        
        return picker
    }
    
    @available(iOS 14, *)
    func makePHPicker() -> PHPickerViewController {
        var configure = PHPickerConfiguration()
        configure.selectionLimit = 10
        configure.filter = .images
        let picker = PHPickerViewController(configuration: configure)
        picker.delegate = self
        return picker
        
    }
    
    func pickerViewConfig() {
        titlePickerView.delegate = self
        titlePickerView.dataSource = self
        let toolBar = makeToolBar()
        toolBar.items?.last?.tag = 1
        
        documentTitleTextField.inputAccessoryView = toolBar
    }

    
    func titleTextFieldConfig() {
        documentTitleTextField.placeholder = "타이틀"
        documentTitleTextField.font = UIFont.systemFont(ofSize: 18)
        documentTitleTextField.inputView = titlePickerView
        makeUnderLine(view: titleStackView)
        
        guard let title = documentTitle else {
            return
        }
        
        documentTitleTextField.text = title
    }
    
    func titleSourceUpdate() {
        for task in tasks {
            titleSource.append(task.documentTitle)
        }
    }
    
    func dateTextFieldConfig() {
        dateTextField.placeholder = "날짜"
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
        
        dateTextField.inputAccessoryView = makeToolBar()
    }
    
    func makeToolBar() -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.black
        toolBar.sizeToFit()
        
        let selectButton = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(selectButtonClicked(_:)))
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        toolBar.setItems([space, selectButton], animated: false)
        return toolBar
    }
    
    func locationTextFieldConfig() {
        locationTextField.text = "위치"
        locationTextField.font = UIFont.systemFont(ofSize: 18)
        
        makeUnderLine(view: locationStackView)
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
        collectionView.showsHorizontalScrollIndicator = false
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
        
        contentTextView.layer.cornerRadius = 10
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
        
        pickerViewConfig()
        
        textViewConfig()
        
        dateTextFieldConfig()
        datePickerConfig()
        dateTextField.text = dateToString(date: Date())
        
        locationTextFieldConfig()
        
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
        
        let gesture = CustomGesture(target: self, action: #selector(cameraImageClicked(_:)))
        gesture.index = indexPath.row
        
        cell.layer.cornerRadius = 10
        
        if photoImages.count != 0 && indexPath.row < photoImages.count {
            let data = photoImages[indexPath.row]
            
            if photoImages.count <= 10 && data.size.width != 0 {
                cell.photoImageView.image = data
                cell.photoImageView.contentMode = .scaleAspectFill
                cell.cameraLabel.isHidden = true
                cell.removeGestureRecognizer(gesture)
            }
            else {
                cell.cameraImage.image = UIImage(named: "camera")
                cell.layer.borderColor = UIColor.lightGray.cgColor
                cell.layer.borderWidth = 1
                cell.cameraLabel.isHidden = false
                cell.photoImageView.contentMode = .scaleAspectFit
                cell.addGestureRecognizer(gesture)
            }
        }
        else {
            cell.cameraImage.image = UIImage(named: "camera")
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.borderWidth = 1
            cell.cameraLabel.isHidden = false
            cell.photoImageView.contentMode = .scaleAspectFit
            cell.addGestureRecognizer(gesture)
        }
        
        
        
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
        if dateTextField.isEditing || documentTitleTextField.isEditing || locationTextField.isEditing {
            view.endEditing(true)
        }
        
        
        if scrollView.contentOffset.y < -40 {
            contentTextView.resignFirstResponder()
        }
    }
}


//MARK: PickerView Delegate
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
        print(component)
        pickerIndex = row
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


//MARK: ImagePickerDelegate

extension AddPinViewController: UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            photoImages.append(image)
            collectionView.reloadData()
        }
        picker.dismiss(animated: true, completion: nil)
    }
}


//MARK: PHPicker Delegate

extension AddPinViewController: PHPickerViewControllerDelegate {
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        if !(results.isEmpty)  {
            photoImages.removeAll()
            
            for result in results {
                let itemProvider = result.itemProvider
                if itemProvider.canLoadObject(ofClass: UIImage.self) {
                    itemProvider.loadObject(ofClass: UIImage.self) { [weak self](image, error) in
                        self?.photoImages.append(image as! UIImage)
                    }
                }
            }
        }
        
    }
}
