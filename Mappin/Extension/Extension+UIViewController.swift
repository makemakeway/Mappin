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
    
    
    
}
