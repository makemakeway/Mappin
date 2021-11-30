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
                link: "https://github.com/tilltue/TLPhotoPicker/blob/master/LICENSE"),
    ]
    
    
    //MARK: UI
    
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: Method
    func tableViewConfig() {
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: SideMenuTableViewCell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: SideMenuTableViewCell.identifier)
    }
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewConfig()
    }
}

extension LicenseViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SideMenuTableViewCell.identifier, for: indexPath) as? SideMenuTableViewCell else {
            return UITableViewCell()
        }
        cell.sideMenuLabel.text = libraries[indexPath.row].name
        cell.sideMenuLabel.font = UIFont().mainFontRegular
        
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return libraries.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Web", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        vc.link = libraries[indexPath.row].link
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
