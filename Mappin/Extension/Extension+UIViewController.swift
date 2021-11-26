//
//  Extension+UIViewController.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/18.
//

import Foundation
import UIKit
import CoreLocation
import GoogleMaps

extension UIViewController {
    func presentOkAlert(message: String) {
        let alert = UIAlertController(title: nil, message: "\(message)", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default, handler: nil)
        
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func makeUnderLine(view: UIView) {
        let underline = CALayer()
        
        underline.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width - 25, height: 0.5)
        underline.backgroundColor = UIColor.lightGray.cgColor
        view.layer.addSublayer(underline)
        
    }
    
    func floatingAddButtonConfig(button: UIButton, image: String) {
        button.backgroundColor = .darkGray
        button.tintColor = .white
        button.setTitle("", for: .normal)
        button.setImage(UIImage(systemName: image), for: .normal)
        
        button.layer.cornerRadius = button.frame.width / 2
        
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.7
        button.layer.shadowOffset = CGSize.zero
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
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRect = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRect.height
            
            if self.view.window?.frame.origin.y == 0 {
                UIView.animate(withDuration: 1) {
                    self.view.window?.frame.origin.y -= keyboardHeight
                }
            }
        }
    }
    
    
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.window?.frame.origin.y != 0 {
            
            UIView.animate(withDuration: 1) {
                self.view.window?.frame.origin.y = 0
            }
        }
    }
    
}
