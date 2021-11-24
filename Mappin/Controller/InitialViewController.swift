//
//  InitialViewController.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/17.
//

import UIKit
import RealmSwift

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
    
    //MARK: Method
    
    func tableViewConfig() {
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: InitialTableViewCell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: InitialTableViewCell.identifier)
        tableView.register(InitialTableViewHeader.self, forHeaderFooterViewReuseIdentifier: InitialTableViewHeader.identifier)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tasks = localRealm.objects(LocationDocument.self)
        print("DEBUG: Tasks is \(tasks)")
    }
    

}

//MARK: Table View Delegate
extension InitialViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: InitialTableViewCell.identifier, for: indexPath) as? InitialTableViewCell else {
            return UITableViewCell()
        }
        
       
        
        let task = tasks[indexPath.row]
        
        cell.backgroundColor = .systemBackground
        
        if let memory = task.memoryList.first {
            cell.documentTitleLabel.text = task.documentTitle
            
            cell.dateLabel.text = dateToString(date: memory.memoryDate)
            
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
        
        header.titleLabel.text = "장소"
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
}
