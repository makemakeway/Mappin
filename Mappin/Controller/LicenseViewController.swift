//
//  LicenseViewController.swift
//  Mappin
//
//  Created by 박연배 on 2021/12/01.
//

import UIKit
import GoogleMaps

class LicenseViewController: UIViewController {

    
    //MARK: Properties
    let libraries = [
        [
            Library(name: "Google Maps SDK for iOS",
                    link: "https://goldenrod-zinnia-987.notion.site/Google-Maps-SDK-for-iOS-b48f9183419e46c68d2aa46defc81ce8"),
            Library(name: "ImageSlideshow",
                    link: "https://github.com/zvonicek/ImageSlideshow/blob/master/LICENSE"),
            Library(name: "PanModal",
                    link: "https://github.com/slackhq/PanModal/blob/master/LICENSE"),
            Library(name: "realm-cocoa",
                    link: "https://github.com/realm/realm-cocoa/blob/master/LICENSE"),
            Library(name: "SideMenu",
                    link: "https://github.com/jonkykong/SideMenu/blob/master/LICENSE"),
            Library(name: "TLPhotoPicker",
                    link: "https://github.com/tilltue/TLPhotoPicker/blob/master/LICENSE")
        ],
        [
            Library(name: "Icons made by Freepik from www.flaticon.com",
                    link: "https://www.flaticon.com/authors/freepik")
        ]
    ]
    
    //MARK: UI
    
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: Method
    func tableViewConfig() {
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: DefaultTableViewCell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: DefaultTableViewCell.identifier)
    }
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewConfig()
    }
}

extension LicenseViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DefaultTableViewCell.identifier, for: indexPath) as? DefaultTableViewCell else {
            return UITableViewCell()
        }
        cell.defaultLabel.text = libraries[indexPath.section][indexPath.row].name
        cell.defaultLabel.font = UIFont().mainFontRegular
        
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return libraries[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sb = UIStoryboard(name: "Web", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        vc.link = libraries[indexPath.section][indexPath.row].link
        
        if indexPath.section == 0 {
            self.navigationItem.backButtonTitle = libraries[indexPath.section][indexPath.row].name
        } else {
            self.navigationItem.backButtonTitle = ""
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return libraries.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Open source license".localized()
        case 1:
            return "App Icon".localized()
        default:
            return nil
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}
