//
//  TravelListViewController.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/23.
//

import UIKit
import RealmSwift

class TravelListViewController: UIViewController {
    
    

    //MARK: Properties
    var travelDocument: LocationDocument? = nil {
        didSet {
            self.title = travelDocument?.documentTitle ?? ""
        }
    }
    
    let localRealm = try! Realm()
    
    //MARK: UI
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var floatingAddButton: UIButton!
    
    //MARK: Method
    
    func tableViewConfig() {
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: TravelListTableViewCell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: TravelListTableViewCell.identifier)
        tableView.separatorStyle = .none
    }
    
    @IBAction func floatingAddbuttonClicked(_ sender: UIButton) {
        let sb = UIStoryboard(name: "AddPin", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "AddPinViewController") as! AddPinViewController
        vc.documentTitle = self.title
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableViewConfig()
        floatingAddButtonConfig(button: floatingAddButton, image: "plus", backgroundColor: .darkGray, tintColor: .white)
    }

}


//MARK: TableView Delegate

extension TravelListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let tasks = travelDocument else {
            return 0
        }
        
        return tasks.memoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TravelListTableViewCell.identifier, for: indexPath) as? TravelListTableViewCell else {
            return UITableViewCell()
        }
        
        guard let tasks = travelDocument else {
            return UITableViewCell()
        }
        
        let task = tasks.memoryList[indexPath.row]
        
        cell.photoImageView.image = ImageManager.shared.loadImageFromDocumentDirectory(imageName: "\(task._id)_0.jpeg")
        
        cell.opacityView.backgroundColor = UIColor(white: 0.3, alpha: 0.3)
        
        cell.dateLabel.text = dateToString(date: task.memoryDate)
        
        cell.locationDescriptionLabel.text = task.memoryDescription
        
        cell.photoImageView.contentMode = .scaleAspectFill
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard let tasks = travelDocument else {
            return nil
        }
        let task = tasks.memoryList[indexPath.row]
        
        let delete = UIContextualAction(style: .normal, title: nil) { [weak self](_, _, _) in
            print("Delete \(task)")
            try! self?.localRealm.write {
                self?.localRealm.delete(task.self)
            }
            tableView.reloadSections(IndexSet(0...0), with: .automatic)
        }
        
        delete.image = UIImage(systemName: "trash")
        delete.backgroundColor = .red
        
        
        let actions = UISwipeActionsConfiguration(actions: [delete])
        return actions
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height * 0.2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let sb = UIStoryboard(name: "Detail", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "TravelDetailViewController") as! TravelDetailViewController
        
        guard let tasks = travelDocument else {
            return
        }
        
        let task = tasks.memoryList[indexPath.row]
        
        vc.task = task
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
