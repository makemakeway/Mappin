//
//  Extension+UIFont.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/28.
//

import UIKit

/*
 쿠키런
 CookieRunOTF-Black
 CookieRunOTF-Bold
 CookieRunOTF-Regular
 
 에스코어
 S-CoreDream-3Light
 S-CoreDream-4Regular
 S-CoreDream-6Bold
 S-CoreDream-8Heavy
 */

extension UIFont {
    var mainFontBlack: UIFont {
        return UIFont(name: "S-CoreDream-8Heavy", size: 17)!
    }
    var mainFontBold: UIFont {
        return UIFont(name: "S-CoreDream-6Bold", size: 17)!
    }
    var mainFontRegular: UIFont {
        return UIFont(name: "S-CoreDream-4Regular", size: 17)!
    }

    var smallFontBlack: UIFont {
        return UIFont(name: "S-CoreDream-8Heavy", size: 14)!
    }

    var smallFontBold: UIFont {
        return UIFont(name: "S-CoreDream-6Bold", size: 14)!
    }

    var smallFontRegular: UIFont {
        return UIFont(name: "S-CoreDream-4Regular", size: 14)!
    }

    var titleFontBlack: UIFont {
        return UIFont(name: "S-CoreDream-8Heavy", size: 20)!
    }

    var titleFontBold: UIFont {
        return UIFont(name: "S-CoreDream-6Bold", size: 20)!
    }

    var titleFontRegular: UIFont {
        return UIFont(name: "S-CoreDream-4Regular", size: 20)!
    }
}
