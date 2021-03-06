//
//  InitialTableViewCell.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/17.
//

import UIKit

class InitialTableViewCell: UITableViewCell {

    static let identifier = "InitialTableViewCell"
    
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var documentTitleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var opacityView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
