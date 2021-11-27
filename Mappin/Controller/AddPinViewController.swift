//
//  AddPinViewController.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/18.
//

import UIKit
import RealmSwift
import PhotosUI
import SwiftUI


class AddPinViewController: UIViewController {

    
    //MARK: Properties
    let localRealm = try! Realm()

    
    var photoImages: [UIImage] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
            
        }
    }
    
    var titleSource = [String]()
    
    var tasks: Results<LocationDocument>!
    
    let datePicker = UIDatePicker()
    
    let titlePickerView = UIPickerView()
    
    var pickerIndex = 0
    
    var documentTitle: String? = nil
    
    //MARK: UI
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var documentTitleTextField: CustomTextField!
    
    @IBOutlet weak var dateTextField: UITextField!
    
    @IBOutlet weak var locationTextField: CustomTextField!
    
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var titleStackView: UIStackView!
    
    @IBOutlet weak var dateStackView: UIStackView!
    
    @IBOutlet weak var locationStackView: UIStackView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    
    //MARK: Method
    @objc func addPin(_ sender: UIBarButtonItem) {
        print("DEBUG: 핀 추가")
        if addDataToRealm() {
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            presentOkAlert(message: "스토리를 추가하지 못했습니다.\n잠시후 다시 시도하거나 앱을 재실행해주세요.")
        }
        
    }
    
    @objc func selectButtonClicked(_ sender: UIBarButtonItem) {
        print("DEBUG: 선택")
        
        if sender.tag == 0 {
            dateTextField.text = dateToString(date: datePicker.date)
        } else {
            print("도큐먼트")
            documentTitleTextField.text = titleSource[pickerIndex]
            documentTitle = titleSource[pickerIndex]
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
    

    
    
    //MARK: functions
    
    func presentActionSheetInsteadKeyboard(message: String, picker: UIView) {
        
        let actionSheet = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        actionSheet.view.addSubview(picker)
        actionSheet.view.heightAnchor.constraint(equalToConstant: 350).isActive = true
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.trailingAnchor.constraint(equalTo: actionSheet.view.trailingAnchor).isActive = true
        picker.leadingAnchor.constraint(equalTo: actionSheet.view.leadingAnchor).isActive = true
        picker.topAnchor.constraint(equalTo: actionSheet.view.topAnchor, constant: 20).isActive = true
        
        let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        actionSheet.addAction(cancelButton)
        
        if picker is UIPickerView {
            
            let okButton = UIAlertAction(title: "선택", style: .default) { _ in
                self.documentTitleTextField.text = self.titleSource[self.pickerIndex]
                self.documentTitle = self.titleSource[self.pickerIndex]
            }
            
            actionSheet.addAction(okButton)
    
            present(actionSheet, animated: true, completion: nil)
            
        } else {
            
            let okButton = UIAlertAction(title: "선택", style: .default) { _ in
                self.dateTextField.text = self.dateToString(date: self.datePicker.date)
            }
            
            actionSheet.addAction(okButton)
            
            present(actionSheet, animated: true, completion: nil)
        }
    }
    
    func addDataToRealm() -> Bool {
        if dataValidCheck() {
            let task = MemoryData(date: datePicker.date,
                                  picture: RealmSwift.List<String>(),
                                  content: contentTextView.text!,
                                  description: locationTextField.text!)

            for (index, image) in photoImages.enumerated() {
                let imageName = "\(task._id)_\(index).jpeg"
                saveImageToDocumentDirectory(imageName: imageName, image: image)
                task.memoryPicture.append(imageName)
            }
            
            guard let currentTasks = localRealm.object(ofType: LocationDocument.self, forPrimaryKey: documentTitle!) else {
                print("DEBUG: Tasks 불러오기 실패 title = \(documentTitle)")
                print("DEBUG: tasks = \(tasks)")
                return false
            }

            try! localRealm.write {
                currentTasks.memoryList.append(task)
                localRealm.add(task)
            }
            
            return true
        }
        return false
    }
    
    func dataValidCheck() -> Bool {
        if documentTitle == nil {
            presentOkAlert(message: "스토리를 추가할 장소를 설정해주세요.")
            return false
        }
        
        if contentTextView.textColor == .darkGray {
            presentOkAlert(message: "스토리 내용을 입력해주세요.")
            return false
        }
        
        if photoImages.isEmpty {
            presentOkAlert(message: "사진을 추가해주세요.")
            return false
        }
        
        guard let location = locationTextField.text, !(location.isEmpty) else {
            presentOkAlert(message: "스토리 제목을 입력해주세요.")
            return false
        }
        
        return true
    }
    
    func saveImageToDocumentDirectory(imageName: String, image: UIImage) {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let imageURL = documentDirectory.appendingPathComponent(imageName)
        
        guard let data = image.jpegData(compressionQuality: 0.5) else {
            return
        }
        
        if FileManager.default.fileExists(atPath: imageURL.path) {
            do {
                try FileManager.default.removeItem(at: imageURL)
                print("DEBUG: 기존 이미지 삭제 완료")
            } catch {
                print("DEBUG: 기존 이미지 삭제 실패")
            }
        }
        
        do {
            try data.write(to: imageURL)
            print("DEBUG: 이미지 저장 완료")
        } catch {
            print("DEBUG: 이미지 저장 실패")
        }
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
    }

    
    func titleTextFieldConfig() {
        documentTitleTextField.placeholder = "스토리를 추가할 장소를 선택해주세요."
        documentTitleTextField.font = UIFont.systemFont(ofSize: 18)
        documentTitleTextField.delegate = self
        
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
        dateTextField.placeholder = "스토리를 추가할 날짜를 선택해주세요."
        dateTextField.font = UIFont.systemFont(ofSize: 18)
        dateTextField.delegate = self
        
        makeUnderLine(view: dateStackView)
    }
    
    func datePickerConfig() {
        datePicker.datePickerMode = .date
        
        datePicker.maximumDate = Date()
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
    }
    
    func locationTextFieldConfig() {
        locationTextField.placeholder = "스토리의 제목을 입력해주세요."
        locationTextField.font = UIFont.systemFont(ofSize: 18)
        locationTextField.clearButtonMode = .whileEditing
        locationTextField.delegate = self
        
        makeUnderLine(view: locationStackView)
    }
    

    
    func navBarConfig() {
        let button = UIBarButtonItem(image: UIImage(systemName: "paperplane"),
                                     style: UIBarButtonItem.Style.plain,
                                     target: self,
                                     action: #selector(addPin(_:)))
        
        self.navigationItem.rightBarButtonItem = button
        self.title = "스토리 추가"
    }
    
    func collectionViewConfig() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib(nibName: PhotoCollectionViewCell.identifier, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        flowLayout.itemSize = CGSize(width: collectionView.frame.size.width - 60, height: collectionView.frame.size.width - 60)
        flowLayout.minimumInteritemSpacing = 20
        flowLayout.minimumLineSpacing = 20
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
        
        contentTextView.layer.cornerRadius = 5
    }
    
    func scrollViewConfig() {
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
    }
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tasks = localRealm.objects(LocationDocument.self)
        
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
        
        
        titleTextFieldConfig()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("DEBUG: ViewWillAppear")
        setKeyboardObserver()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG: ViewWillDisAppear")
        removeKeyboardObserver()
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
                cell.cameraImage.image = UIImage(systemName: "camera.on.rectangle")
                cell.layer.borderColor = UIColor.lightGray.cgColor
                cell.layer.borderWidth = 1
                cell.cameraLabel.isHidden = false
                cell.photoImageView.contentMode = .scaleAspectFit
                cell.photoCountLabel.text = "\(photoImages.count) / 10"
                cell.addGestureRecognizer(gesture)
            }
        }
        else {
            cell.cameraImage.image = UIImage(systemName: "camera.on.rectangle")
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.borderWidth = 1
            cell.cameraLabel.isHidden = false
            cell.photoImageView.contentMode = .scaleAspectFit
            cell.photoCountLabel.text = "\(photoImages.count) / 10"
            cell.addGestureRecognizer(gesture)
        }
        
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
    }
    
}


//MARK: ScrollView Delegate
extension AddPinViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y < -40 {
            view.endEditing(true)
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
        print(#function)
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
            contentTextView.text = "스토리 내용을 입력해주세요."
            contentTextView.textColor = .darkGray
        }
        print(#function)
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
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else {
                return
            }
            
            if !(results.isEmpty)  {
                self.photoImages.removeAll()
                
                let group = DispatchGroup()
                
                LoadingIndicator.shared.showIndicator()
                
                for result in results {
                    group.enter()
                    let itemProvider = result.itemProvider
                    if itemProvider.canLoadObject(ofClass: UIImage.self) {
                        itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                            self.photoImages.append(image as! UIImage)
                            group.leave()
                        }
                    }
                    
                }
                group.wait()
                
                LoadingIndicator.shared.hideIndicator()
            }
        }
    }
}


//MARK: TextField delegate

extension AddPinViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == dateTextField {
            presentActionSheetInsteadKeyboard(message: "날짜 선택", picker: datePicker)
            return false
        } else if textField == documentTitleTextField {
            presentActionSheetInsteadKeyboard(message: "장소 선택", picker: titlePickerView)
            return false
        }
        return true
    }
}
