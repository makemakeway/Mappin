//
//  DefaultTableViewCell.swift
//  Mappin
//
//  Created by 박연배 on 2021/12/01.
//

import UIKit

class DefaultTableViewCell: UITableViewCell {
    
    
    static let identifier = "DefaultTableViewCell"
    
    @IBOutlet weak var defaultLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
