//
//  MarkerInfoView.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/23.
//

import UIKit

class MarkerInfoView: UIView {

    static let identifier = "MarkerInfoView"
    
    @IBOutlet weak var tempLabel: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }
    
    private func loadXib() {
        
        let nibs = UINib(nibName: MarkerInfoView.identifier, bundle: Bundle.main)
        
        
        guard let xibView = nibs.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        
        xibView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        xibView.frame = self.bounds
        self.addSubview(xibView)
    }
}
