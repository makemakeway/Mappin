//
//  PhotoCollectionViewCell.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/18.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {

    static let identifier = "PhotoCollectionViewCell"
    
    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var cameraImage: UIImageView!
    
    @IBOutlet weak var cameraLabel: UILabel!
    
    @IBOutlet weak var photoCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
        photoImageView.backgroundColor = nil
        cameraImage.image = nil
        cameraLabel.isHidden = true
        photoCountLabel.text = ""
        layer.borderWidth = 0
        layer.borderColor = nil
        
        guard let gestures = self.gestureRecognizers else {
            return
        }
        
        for ges in gestures {
            if ges is CustomGesture {
                self.removeGestureRecognizer(ges)
            }
        }
    }
    
}
