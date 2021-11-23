//
//  TravelListTableViewCell.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/23.
//

import UIKit

class TravelListTableViewCell: UITableViewCell {

    
    static let identifier = "TravelListTableViewCell"
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var locationDescriptionLabel: UILabel!
    
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
