//
//  Extension+UIViewController.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/18.
//

import UIKit
import CoreLocation
import GoogleMaps
import RealmSwift

extension UIViewController {
    func presentOkAlert(message: String) {
        let alert = UIAlertController(title: nil, message: "\(message)", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default, handler: nil)
        
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func emptyDataDelete(tasks: Results<LocationDocument>, tableView: UITableView?, localRealm: Realm) {
        let emptyData = tasks.filter({ $0.memoryList.isEmpty == true })
        
        for task in emptyData {
            try! localRealm.write {
                print("DEBUG: 비어있는 데이터 삭제함")
                localRealm.delete(task.self)
            }
        }
        if let tableView = tableView {
            tableView.reloadSections(IndexSet(0...0), with: .automatic)
        }
    }
    
    func makeUnderLine(view: UIView) {
        let underline = CALayer()
        
        underline.frame = CGRect(x: 0, y: view.frame.height, width: UIScreen.main.bounds.width - 40, height: 0.5)
        underline.backgroundColor = UIColor.lightGray.cgColor
        view.layer.addSublayer(underline)
        
    }
    
    func floatingAddButtonConfig(button: UIButton, image: String, backgroundColor: UIColor, tintColor: UIColor) {
        button.backgroundColor = backgroundColor
        button.tintColor = tintColor
        button.setTitle("", for: .normal)
        button.setImage(UIImage(systemName: image), for: .normal)
        
        button.layer.cornerRadius = 22
        
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowRadius = 2
        button.layer.shadowOpacity = 0.7
        button.layer.shadowOffset = CGSize.zero
    }
    
    @available (iOS 15, *)
    func iOS15ButtonConfig(image: UIImage, button: UIButton, backgroundColor: UIColor, foregroundColor: UIColor) {
        var configure = UIButton.Configuration.filled()

        configure.cornerStyle = .capsule
        configure.baseBackgroundColor = backgroundColor
        configure.image = image
        configure.baseForegroundColor = foregroundColor
        configure.title = ""
        button.configuration = configure

        button.frame.size = CGSize(width: 44, height: 44)
        button.layer.shadowOffset = .zero
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowRadius = 2
        button.layer.shadowOpacity = 0.7
    }
    
    func iOS13ButtonConfig(image: UIImage, button: UIButton, backgroundColor: UIColor, foregroundColor: UIColor) {
        button.setTitle("", for: .normal)
        button.setImage(image, for: .normal)
        
        button.tintColor = foregroundColor
        button.backgroundColor = backgroundColor
        
        button.layer.cornerRadius = 22
        button.layer.shadowOffset = .zero
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowRadius = 2
        button.layer.shadowOpacity = 0.7
    }
    
    
    func dateToString(date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        
        return df.string(from: date)
    }
    
    func setKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        print("KEYBOARD WILL SHOW")
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRect = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRect.height
            
            if self.view.frame.origin.y == 0 {
                UIView.animate(withDuration: 1) {
                    self.view.frame.origin.y -= keyboardHeight
                }
            }
        }
    }
    
    
    
    @objc func keyboardWillHide(notification: NSNotification) {
        print("KEYBOARD WILL HIDE")
        if self.view.frame.origin.y != 0 {
            
            UIView.animate(withDuration: 1) {
                self.view.frame.origin.y = 0
            }
        }
    }
    
    func authorizationHandling(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "예", style: .default) { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
        
        alert.addAction(ok)
        
        present(alert, animated: true, completion: nil)
    }
}
