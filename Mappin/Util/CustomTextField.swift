//
//  CustomTextField.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/21.
//

import Foundation
import UIKit


class CustomTextField: UITextField {
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        
        return false
    }
    
}
