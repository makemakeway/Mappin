//
//  InitialViewController.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/17.
//

import UIKit
import RealmSwift
import SideMenu

class InitialViewController: UIViewController {

    //MARK: Properties
    
    let localRealm = try! Realm()
    
    var tasks: Results<LocationDocument>! {
        didSet {
            if tasks.isEmpty || tasks.filter({ $0.memoryList.isEmpty == false }).isEmpty {
                print("비었네용")
                self.emptyHandlingView.isHidden = false
            } else {
                self.emptyHandlingView.isHidden = true
                tableView.reloadSections(IndexSet(0...0), with: .automatic)
            }
        }
    }
    
    
    //MARK: UI
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var emptyHandlingView: UIView!
    
    @IBOutlet weak var floatingAddButton: UIButton!
    
    @IBOutlet weak var emptyHandlingLabel: UILabel!
    
    @IBOutlet weak var emptyHandlingButton: UIButton!
    
    //MARK: Method
    
    func localizingText() {
        emptyHandlingLabel.text = "There is no record of writing 🥲".localized()
        emptyHandlingLabel.font = UIFont().mainFontRegular
        emptyHandlingButton.setTitle("Fill it out".localized(), for: .normal)
    }
    
    func tableViewConfig() {
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: InitialTableViewCell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: InitialTableViewCell.identifier)
        tableView.register(InitialTableViewHeader.self, forHeaderFooterViewReuseIdentifier: InitialTableViewHeader.identifier)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
    }
    

    
    func navBarConfig() {
        self.navigationItem.backButtonTitle = ""
    }
    
    @IBAction func sideMenuButtonClicked(_ sender: UIBarButtonItem) {
        
        let sb = UIStoryboard(name: "SideMenu", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "SideMenuViewController")
        
        let sideMenu = SideMenuNavigationController(rootViewController: vc)
        
        sideMenu.leftSide = true
        sideMenu.menuWidth = UIScreen.main.bounds.width * 0.4
        
        present(sideMenu, animated: true, completion: nil)
    }
    
    @IBAction func floatingAddButtonClicked(_ sender: UIButton) {
        let sb = UIStoryboard(name: "AddTravel", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "AddTravelViewController") as! AddTravelViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func mapButtonClicked(_ sender: UIBarButtonItem) {
        let sb = UIStoryboard(name: "Map", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func addButtonClicked(_ sender: UIButton) {
        let sb = UIStoryboard(name: "AddTravel", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "AddTravelViewController") as! AddTravelViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: LifeCycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewConfig()
        floatingAddButtonConfig(button: floatingAddButton, image: "square.and.pencil", backgroundColor: .darkGray, tintColor: .white)
        navBarConfig()
        localizingText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        tasks = localRealm.objects(LocationDocument.self).sorted(byKeyPath: "latestWrittenDate", ascending: false)
        
        emptyDataDelete(tasks: tasks, tableView: tableView, localRealm: localRealm)
    }
    

}

//MARK: Table View Delegate
extension InitialViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: InitialTableViewCell.identifier, for: indexPath) as? InitialTableViewCell else {
            return UITableViewCell()
        }
        
       
        
        let task = tasks[indexPath.row]
        print(task)
        
        cell.backgroundColor = .systemBackground
        cell.selectionStyle = .none
        
        if let memory = task.memoryList.sorted(byKeyPath: "memoryDate", ascending: true).first, !(task.memoryList.isEmpty) {
            cell.documentTitleLabel.text = task.documentTitle
            cell.documentTitleLabel.font = UIFont().titleFontBold
            
            let calendar = Calendar.current
            
            if calendar.dateComponents([.day], from: task.oldestWrittenDate, to: task.latestWrittenDate).day! >= 1 {
                cell.dateLabel.text = dateToString(date: task.oldestWrittenDate) + " ~ " + dateToString(date: task.latestWrittenDate)
            } else {
                cell.dateLabel.text = dateToString(date: task.oldestWrittenDate)
            }
            
            print("old: \(task.oldestWrittenDate)")
            print("latest: \(task.latestWrittenDate)")
            print(calendar.dateComponents([.day], from: task.oldestWrittenDate, to: task.latestWrittenDate).day!)
            
            cell.dateLabel.font = UIFont().smallFontBold
            
            cell.photoImageView.image = ImageManager.shared.loadImageFromDocumentDirectory(imageName: "\(memory._id)_0.jpeg")
            
            cell.photoImageView.contentMode = .scaleAspectFill
            
            cell.photoImageView.layer.cornerRadius = 10
            
            cell.opacityView.backgroundColor = UIColor(white: 0.3, alpha: 0.3)
            cell.opacityView.layer.cornerRadius = 10
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height * 0.4
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sb = UIStoryboard(name: "TravelList", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "TravelListViewController") as! TravelListViewController
        
        vc.travelDocument = tasks[indexPath.row]
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: InitialTableViewHeader.identifier) as? InitialTableViewHeader else {
            return nil
        }
        
        header.titleLabel.text = "Place".localized()
        header.titleLabel.font = UIFont(name: "IBMPlexSansKR-Bold", size: 24)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
}
