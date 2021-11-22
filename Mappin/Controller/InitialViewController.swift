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
    
    var tasks: Results<TravelDocument>! {
        didSet {
            if tasks.isEmpty || tasks.filter({ $0.travels.isEmpty == false }).isEmpty {
                print("비었네용")
                self.emptyHandlingView.isHidden = false
            } else {
                self.emptyHandlingView.isHidden = true
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
    }
    
    func loadImageFromDocumentDirectory(imageName: String) -> UIImage? {
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDomain = FileManager.SearchPathDomainMask.userDomainMask
        let path = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomain, true)
        
        if let directoryPath = path.first {
            let imageURL = URL(fileURLWithPath: directoryPath).appendingPathComponent(imageName)
            return UIImage(contentsOfFile: imageURL.path)
        }
        
        print("DEBUG: 이미지 불러오기 실패")
        return nil
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
        tasks = localRealm.objects(TravelDocument.self)
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
        
        cell.documentTitleLabel.text = task.documentTitle
        cell.dateLabel.text = dateToString(date: task.travels.first!.travelDate)
        
        cell.photoImageView.image = loadImageFromDocumentDirectory(imageName: "\(task.travels.first!._id)_0.jpeg")
        
        cell.photoImageView.contentMode = .scaleAspectFill
        
        cell.photoImageView.layer.cornerRadius = 10
        
        cell.opacityView.backgroundColor = UIColor(white: 0.3, alpha: 0.3)
        cell.opacityView.layer.cornerRadius = 10
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height * 0.4
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: InitialTableViewHeader.identifier) as? InitialTableViewHeader else {
            return nil
        }
        
        header.titleLabel.text = "나의 여행"
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
}
