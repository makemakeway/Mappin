//
//  MarkerInfoTableViewCell.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/25.
//

import UIKit

class MarkerInfoTableViewCell: UITableViewCell {

    
    static let identifier = "MarkerInfoTableViewCell"
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var memoryDescriptionLabel: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
