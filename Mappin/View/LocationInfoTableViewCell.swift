//
//  LocationInfoTableViewCell.swift
//  Mappin
//
//  Created by 박연배 on 2021/12/08.
//

import UIKit

class LocationInfoTableViewCell: UITableViewCell {

    
    static let identifier = "LocationInfoTableViewCell"
    
    
    @IBOutlet weak var locationTitleLabel: UILabel!
    
    @IBOutlet weak var locationAddressLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
