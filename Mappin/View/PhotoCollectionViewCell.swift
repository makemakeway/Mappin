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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
