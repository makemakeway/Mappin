//
//  Extension+UIFont.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/28.
//

import UIKit

/*
 
 IBMPlexSansKR
 IBMPlexSansKR-Bold
 IBMPlexSansKR-SemiBold
 
 */

extension UIFont {
    var mainFontBlack: UIFont {
        return UIFont(name: "IBMPlexSansKR-Bold", size: 17)!
    }
    var mainFontBold: UIFont {
        return UIFont(name: "IBMPlexSansKR-SemiBold", size: 17)!
    }
    var mainFontRegular: UIFont {
        return UIFont(name: "IBMPlexSansKR", size: 17)!
    }

    var smallFontBlack: UIFont {
        return UIFont(name: "IBMPlexSansKR-Bold", size: 14)!
    }

    var smallFontBold: UIFont {
        return UIFont(name: "IBMPlexSansKR-SemiBold", size: 14)!
    }

    var smallFontRegular: UIFont {
        return UIFont(name: "IBMPlexSansKR", size: 14)!
    }

    var titleFontBlack: UIFont {
        return UIFont(name: "IBMPlexSansKR-Bold", size: 20)!
    }

    var titleFontBold: UIFont {
        return UIFont(name: "IBMPlexSansKR-SemiBold", size: 20)!
    }

    var titleFontRegular: UIFont {
        return UIFont(name: "IBMPlexSansKR", size: 20)!
    }
}
