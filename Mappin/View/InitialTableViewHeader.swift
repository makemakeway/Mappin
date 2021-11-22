//
//  InitialTableViewHeader.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/22.
//

import UIKit

class InitialTableViewHeader: UITableViewHeaderFooterView {

    static let identifier = "InitialTableViewHeader"
    
    let titleLabel = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.frame = CGRect(x: 20, y: 0,
                                  width: contentView.frame.size.width,
                                  height: contentView.frame.size.height)
    }
}
