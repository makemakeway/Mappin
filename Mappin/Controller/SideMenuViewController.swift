//
//  SideMenuViewController.swift
//  Mappin
//
//  Created by 박연배 on 2021/12/01.
//

import UIKit

class SideMenuViewController: UIViewController {

    
    //MARK: Properties
    
    let menuItems = ["App Info".localized()]
    
    //MARK: UI
    
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: Method
    
    func tableViewConfig() {
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: SideMenuTableViewCell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: SideMenuTableViewCell.identifier)
        tableView.separatorStyle = .none
    }
    
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewConfig()
        
    }
}

extension SideMenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SideMenuTableViewCell.identifier, for: indexPath) as? SideMenuTableViewCell else {
            return UITableViewCell()
        }
        cell.sideMenuLabel.text = "App info".localized()
        cell.sideMenuLabel.font = UIFont().mainFontRegular
        cell.sideMenuIcon.image = UIImage(systemName: "info.circle")
        cell.sideMenuIcon.tintColor = .orange
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "AppInfo", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "AppInfoViewController") as! AppInfoViewController
        
        vc.title = "App info".localized()
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
