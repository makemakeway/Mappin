//
//  ImageManager.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/23.
//

import UIKit

class ImageManager {
    private init() {
        
    }
    
    static let shared = ImageManager()
    
    func loadImageFromDocumentDirectory(imageName: String) -> UIImage? {
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDomain = FileManager.SearchPathDomainMask.userDomainMask
        let path = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomain, true)
        
        if let directoryPath = path.first {
            let imageURL = URL(fileURLWithPath: directoryPath).appendingPathComponent(imageName)
            return UIImage(contentsOfFile: imageURL.path)
        }
        
        print("DEBUG: 이미지 불러오기 실패")
        return nil
    }
    
    
    
}
