//
//  AppInfoViewController.swift
//  Mappin
//
//  Created by 박연배 on 2021/12/01.
//

import UIKit

class AppInfoViewController: UIViewController {

    
    //MARK: Properties
    
    let items = [
        "Open source license".localized(),
        "Personal information policy".localized()
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
        // Do any additional setup after loading the view.
    }
    
}

extension AppInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DefaultTableViewCell.identifier, for: indexPath) as? DefaultTableViewCell else {
            return UITableViewCell()
        }
        cell.defaultLabel.text = items[indexPath.row]
        cell.defaultLabel.font = UIFont().mainFontRegular
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            let sb = UIStoryboard(name: "License", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "LicenseViewController") as! LicenseViewController
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let sb = UIStoryboard(name: "Web", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            vc.link = "https://goldenrod-zinnia-987.notion.site/00a9e4b629f0435da8370d1d43b0f328"
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            print("ERROR")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
