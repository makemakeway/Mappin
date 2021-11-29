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
            let imageURL = URL(fileURLWithPath: directoryPath).appendingPathComponent("Images").appendingPathComponent(imageName)
            return UIImage(contentsOfFile: imageURL.path)
        }
        
        print("DEBUG: 이미지 불러오기 실패")
        return nil
    }
    
    func deleteImageFromDocumentDirectory(imageName: String) {
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDomain = FileManager.SearchPathDomainMask.userDomainMask
        let path = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomain, true)
        
        if let directoryPath = path.first {
            let imageURL = URL(fileURLWithPath: directoryPath).appendingPathComponent("Images").appendingPathComponent(imageName)
            
            do {
                try FileManager.default.removeItem(at: imageURL)
                print("DEBUG: 이미지 삭제 \(imageURL)")
            } catch {
                print("DEBUG: 이미지 삭제 실패")
            }
        }
    }
    
    func saveImageToDocumentDirectory(imageName: String, image: UIImage) {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let imagePath = documentDirectory.appendingPathComponent("Images")
        
        if !FileManager.default.fileExists(atPath: imagePath.path) {
            do {
                try FileManager.default.createDirectory(atPath: imagePath.path,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            } catch {
                print("DEBUG: 폴더 생성에 실패함")
            }
        }
        
        let imageURL = imagePath.appendingPathComponent(imageName)
        
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
    
}
