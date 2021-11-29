//
//  Extension+String.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/30.
//

import Foundation

extension String {
    func localized(bundle: Bundle = .main, table: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: table, bundle: bundle, value: self, comment: "")
    }
}
