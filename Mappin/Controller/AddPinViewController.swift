//
//  AddPinViewController.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/18.
//

import UIKit
import RealmSwift
import Photos
import TLPhotoPicker


class AddPinViewController: UIViewController {

    
    //MARK: Properties
    let localRealm = try! Realm()

    
    var photoImages: [UIImage] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadSections(IndexSet(0...0))
                
            }
        }
    }
    
    var titleSource = [String]()
    
    var tasks: Results<LocationDocument>!
    
    let datePicker = UIDatePicker()
    
    let titlePickerView = UIPickerView()
    
    var pickerIndex = 0
    
    var documentTitle: String? = nil
    
    var selectedAsset = [TLPHAsset]()
    
    var memoryData: MemoryData? = nil {
        didSet {
            editMode = true
        }
    }
    
    var editMode = false
    
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
    @objc func removePhoto(_ sender: UIButton) {
        photoImages.remove(at: sender.tag)
        print("DEBUG: \(sender.tag)번째 지움")
    }
    
    @objc func addPin(_ sender: UIBarButtonItem) {
        print("DEBUG: 핀 추가")
        if editMode {
            updateDataToRealm()
            self.navigationController?.popViewController(animated: true)
            return
        }
        if addDataToRealm() {
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            presentOkAlert(message: "Failed to add story.\n Please try again in a little while or run the app again.".localized())
        }
        
    }
    
    func updateDataToRealm() {
        if dataValidCheck() {
            guard let currentTask = localRealm.object(ofType: MemoryData.self, forPrimaryKey: memoryData!._id) else { return }
            guard let currentDocument = localRealm.object(ofType: LocationDocument.self, forPrimaryKey: documentTitleTextField.text!) else { return }
            
            let group = DispatchGroup()
            LoadingIndicator.shared.showIndicator()
            try! localRealm.write {
                for imageName in currentTask.memoryPicture {
                    group.enter()
                    ImageManager.shared.deleteImageFromDocumentDirectory(imageName: imageName)
                    group.leave()
                }
                group.wait()
                
                currentTask.memoryPicture.removeAll()
                for (index, image) in photoImages.enumerated() {
                    group.enter()
                    let imageName = "\(currentTask._id)_\(index)"
                    ImageManager.shared.saveImageToDocumentDirectory(imageName: imageName, image: image)
                    currentTask.memoryPicture.append(imageName)
                    group.leave()
                }
                group.wait()
                print("DEBUG: datepicker \(datePicker.date)")
                print("DEBUG: dateTextField \(dateTextField.text!)")
                currentTask.memoryDate = stringTodate(string: dateTextField.text!)
                currentTask.memoryContent = contentTextView.text!
                currentTask.memoryDescription = locationTextField.text!
                
                let memoryList = currentDocument.memoryList.sorted(byKeyPath: "memoryDate", ascending: false)
                
                currentDocument.latestWrittenDate = memoryList.first!.memoryDate
                currentDocument.oldestWrittenDate = memoryList.last!.memoryDate
                currentDocument.lastUpdated = Date()
            }
            LoadingIndicator.shared.hideIndicator()
            return
        }
    }
    
    @objc func cameraImageClicked(_ gesture: CustomGesture) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let library = UIAlertAction(title: "Add a photo".localized(), style: .default) { [weak self](_) in
            
            guard let self = self else { return }
            
            let vc = TLPhotosPickerViewController()
            vc.delegate = self
            vc.modalPresentationStyle = .fullScreen
            vc.view.backgroundColor = .systemBackground
            
            vc.cancelButton.title = "Cancel".localized()
            vc.doneButton.title = "Done".localized()
            vc.configure = self.TLPhotoPickerConfig()
            
            
            self.present(vc, animated: true, completion: nil)
        }
        
        
        
        let cancel = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        
        sheet.addAction(library)
        sheet.addAction(cancel)
        
        self.present(sheet, animated: true, completion: nil)
    }
    
    
    //MARK: functions
    
    func editModeConfig() {
        if let data = memoryData {
            documentTitleTextField.isUserInteractionEnabled = false
            dateTextField.text = dateToString(date: data.memoryDate)
            locationTextField.text = data.memoryDescription
            contentTextView.text = data.memoryContent
            self.title = "Edit a Story".localized()
            for image in data.memoryPicture {
                guard let img = ImageManager.shared.loadImageFromDocumentDirectory(imageName: "\(image)") else { return }
                photoImages.append(img)
            }
            
            
        }
    }
    
    func TLPhotoPickerConfig() -> TLPhotosPickerConfigure {
        var config = TLPhotosPickerConfigure()
        
        config.allowedVideo = false
        config.allowedLivePhotos = false
        config.allowedVideoRecording = false
        config.fetchCollectionTypes = [(.album, .albumRegular)]
        config.maxSelectedAssets = 10
        config.mediaType = .image
        
        config.doneTitle = "Done".localized()
        config.cancelTitle = "Cancel".localized()
        config.tapHereToChange = "Album".localized()
        config.autoPlay = false
        
        return config
    }
    
    func presentActionSheetInsteadKeyboard(message: String, picker: UIView) {
        
        let actionSheet = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        actionSheet.view.addSubview(picker)
        actionSheet.view.heightAnchor.constraint(equalToConstant: 350).isActive = true
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.trailingAnchor.constraint(equalTo: actionSheet.view.trailingAnchor).isActive = true
        picker.leadingAnchor.constraint(equalTo: actionSheet.view.leadingAnchor).isActive = true
        picker.topAnchor.constraint(equalTo: actionSheet.view.topAnchor, constant: 20).isActive = true
        
        let cancelButton = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        
        actionSheet.addAction(cancelButton)
        
        if picker is UIPickerView {
            
            let okButton = UIAlertAction(title: "Done".localized(), style: .default) { _ in
                self.documentTitleTextField.text = self.titleSource[self.pickerIndex]
                self.documentTitle = self.titleSource[self.pickerIndex]
            }
            
            actionSheet.addAction(okButton)
    
            present(actionSheet, animated: true, completion: nil)
            
        } else {
            
            let okButton = UIAlertAction(title: "Done".localized(), style: .default) { _ in
                self.dateTextField.text = self.dateToString(date: self.datePicker.date)
            }
            
            actionSheet.addAction(okButton)
            
            present(actionSheet, animated: true, completion: nil)
        }
    }
    
    func addDataToRealm() -> Bool {
        if dataValidCheck() {
            
            LoadingIndicator.shared.showIndicator()
            
            let group = DispatchGroup()
            
            let task = MemoryData(date: datePicker.date,
                                  picture: RealmSwift.List<String>(),
                                  content: contentTextView.text!,
                                  description: locationTextField.text!)

            for (index, image) in photoImages.enumerated() {
                group.enter()
                let imageName = "\(task._id)_\(index)"
                ImageManager.shared.saveImageToDocumentDirectory(imageName: imageName, image: image)
                task.memoryPicture.append(imageName)
                group.leave()
            }
            group.wait()
            
            guard let currentTasks = localRealm.object(ofType: LocationDocument.self, forPrimaryKey: documentTitle!) else {
                print("DEBUG: Tasks 불러오기 실패")
                return false
            }

            try! localRealm.write {
                currentTasks.memoryList.append(task)
                localRealm.add(task)
                let memoryList = currentTasks.memoryList.sorted(byKeyPath: "memoryDate", ascending: false)
                
                currentTasks.latestWrittenDate = memoryList.first!.memoryDate
                currentTasks.oldestWrittenDate = memoryList.last!.memoryDate
                currentTasks.lastUpdated = Date()
            }
            
            LoadingIndicator.shared.hideIndicator()
            
            return true
        }
        return false
    }
    
    func dataValidCheck() -> Bool {
        if documentTitle == nil {
            presentOkAlert(message: "Please enter a place to add a story.".localized())
            return false
        }
        
        if contentTextView.textColor == .darkGray {
            presentOkAlert(message: "Please enter the contents of the story.".localized())
            return false
        }
        
//        if photoImages.isEmpty {
//            presentOkAlert(message: "Please add a photo.".localized())
//            return false
//        }
        
        guard let location = locationTextField.text, !(location.isEmpty) else {
            presentOkAlert(message: "Please enter the title of the story.".localized())
            return false
        }
        
        return true
    }
    
    
    
    func pickerViewConfig() {
        titlePickerView.delegate = self
        titlePickerView.dataSource = self
    }

    
    func titleTextFieldConfig() {
        documentTitleTextField.placeholder = "Choose a place to add a story".localized()
        documentTitleTextField.font = UIFont().mainFontRegular
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
        dateTextField.placeholder = "Choose the date of the story".localized()
        dateTextField.font = UIFont().mainFontRegular
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
        locationTextField.placeholder = "Title of the story".localized()
        locationTextField.font = UIFont().mainFontRegular
        locationTextField.clearButtonMode = .whileEditing
        locationTextField.delegate = self
        locationTextField.autocorrectionType = .no
        locationTextField.autocapitalizationType = .none
        
        makeUnderLine(view: locationStackView)
    }
    

    
    func navBarConfig() {
        let button = UIBarButtonItem(image: UIImage(systemName: "paperplane"),
                                     style: UIBarButtonItem.Style.plain,
                                     target: self,
                                     action: #selector(addPin(_:)))
        
        self.navigationItem.rightBarButtonItem = button
        self.title = "Add a Story".localized()
    }
    
    func collectionViewConfig() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib(nibName: PhotoCollectionViewCell.identifier, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: collectionView.frame.size.width - 60)
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
        
        if !editMode {
            contentTextView.text = "Contents of the story".localized()
            contentTextView.textColor = .darkGray
        }
        
        contentTextView.font = UIFont().mainFontRegular
        
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
        editModeConfig()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
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
        
        cell.clipsToBounds = false
        
        let gesture = CustomGesture(target: self, action: #selector(cameraImageClicked(_:)))
        gesture.index = indexPath.row
        
        if photoImages.count != 0 && indexPath.row < photoImages.count {
            let data = photoImages[indexPath.row]
            
            if photoImages.count <= 10 && data.size.width != 0 {
                cell.photoImageView.image = data
                cell.photoImageView.contentMode = .scaleAspectFill
                cell.photoImageView.layer.cornerRadius = 10
                cell.cameraLabel.isHidden = true
                cell.removeGestureRecognizer(gesture)
                
                if #available(iOS 15, *) {
                    let deleteButton = UIButton()
                    iOS15ButtonConfig(image: UIImage(systemName: "minus")!, button: deleteButton, backgroundColor: .red, foregroundColor: .white)
                    
                    cell.container.addSubview(deleteButton)
                    cell.container.layer.cornerRadius = 10
                    deleteButton.translatesAutoresizingMaskIntoConstraints = false
                    deleteButton.topAnchor.constraint(equalTo: cell.container.topAnchor, constant: -10).isActive = true
                    deleteButton.trailingAnchor.constraint(equalTo: cell.container.trailingAnchor, constant: 10).isActive = true
                    deleteButton.tag = indexPath.row
                    deleteButton.addTarget(self, action: #selector(removePhoto(_:)), for: .touchUpInside)
                } else {
                    let deleteButton = UIButton()
                    iOS13ButtonConfig(image: UIImage(systemName: "minus")!, button: deleteButton, backgroundColor: .red, foregroundColor: .white)
                    let config = UIImage.SymbolConfiguration(scale: .large)
                    deleteButton.setPreferredSymbolConfiguration(config, forImageIn: .normal)
                    
                    cell.container.addSubview(deleteButton)
                    cell.container.layer.cornerRadius = 10
                    
                    deleteButton.translatesAutoresizingMaskIntoConstraints = false
                    deleteButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
                    deleteButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
                    deleteButton.topAnchor.constraint(equalTo: cell.container.topAnchor, constant: -10).isActive = true
                    deleteButton.trailingAnchor.constraint(equalTo: cell.container.trailingAnchor, constant: 10).isActive = true
                    deleteButton.tag = indexPath.row
                    deleteButton.addTarget(self, action: #selector(removePhoto(_:)), for: .touchUpInside)
                }
                
            }
            else {
                cell.cameraImage.image = UIImage(systemName: "camera.on.rectangle")
                cell.cameraImage.tintColor = .orange
                cell.layer.borderColor = UIColor.lightGray.cgColor
                cell.layer.borderWidth = 1
                cell.cameraLabel.isHidden = false
                cell.photoImageView.contentMode = .scaleAspectFit
                cell.photoCountLabel.text = "\(photoImages.count) / 10"
                cell.photoCountLabel.font = UIFont().mainFontRegular
                cell.addPhotoLabel.text = "Add a photo".localized()
                cell.addGestureRecognizer(gesture)
            }
        }
        else {
            cell.cameraImage.image = UIImage(systemName: "camera.on.rectangle")
            cell.cameraImage.tintColor = .orange
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.borderWidth = 1
            cell.cameraLabel.isHidden = false
            cell.photoImageView.contentMode = .scaleAspectFit
            cell.photoCountLabel.text = "\(photoImages.count) / 10"
            cell.photoCountLabel.font = UIFont().mainFontRegular
            cell.addPhotoLabel.text = "Add a photo".localized()
            cell.addGestureRecognizer(gesture)
        }
        
        cell.layer.cornerRadius = 10
        
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
            contentTextView.text = "Contents of the story".localized()
            contentTextView.textColor = .darkGray
        }
        print(#function)
    }
}

//MARK: TLPicker Delegate
extension AddPinViewController: TLPhotosPickerViewControllerDelegate {
    
    
    func shouldDismissPhotoPicker(withTLPHAssets: [TLPHAsset]) -> Bool {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            if !(withTLPHAssets.isEmpty) {
                self.selectedAsset = withTLPHAssets
                self.photoImages.removeAll()
                
                LoadingIndicator.shared.showIndicator()
                
                let group = DispatchGroup()
                for asset in withTLPHAssets {
                    group.enter()
                    self.photoImages.append(asset.fullResolutionImage!)
                    group.leave()
                }
                
                group.wait()
                LoadingIndicator.shared.hideIndicator()
            }
        }
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
        return true
    }
    
    func handleNoAlbumPermissions(picker: TLPhotosPickerViewController) {
        picker.dismiss(animated: true) { [weak self] in
            self?.authorizationHandling(title: "Request for access to the Photos", message: "Please allow access to Photos to use the app.")
        }
    }
    
    func handleNoCameraPermissions(picker: TLPhotosPickerViewController) {
        picker.dismiss(animated: true) { [weak self] in
            self?.authorizationHandling(title: "Request for access to the Camera", message: "Please allow access to Camera to use the app.")
        }
        
    }
    
    
}


//MARK: TextField delegate

extension AddPinViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == dateTextField {
            presentActionSheetInsteadKeyboard(message: "Choose a Date".localized(), picker: datePicker)
            return false
        } else if textField == documentTitleTextField {
            presentActionSheetInsteadKeyboard(message: "Choose a Place".localized(), picker: titlePickerView)
            return false
        }
        return true
    }
}
