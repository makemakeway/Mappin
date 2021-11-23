//
//  TravelListViewController.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/23.
//

import UIKit

class TravelListViewController: UIViewController {
    
    

    //MARK: Properties
    var travelDocument: TravelDocument? = nil {
        didSet {
            self.title = travelDocument?.documentTitle ?? ""
        }
    }
    
    //MARK: UI
    
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: Method
    
    func tableViewConfig() {
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: TravelListTableViewCell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: TravelListTableViewCell.identifier)
        tableView.separatorStyle = .none
    }
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableViewConfig()
    }

}


//MARK: TableView Delegate

extension TravelListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let tasks = travelDocument else {
            return 0
        }
        
        return tasks.travels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TravelListTableViewCell.identifier, for: indexPath) as? TravelListTableViewCell else {
            return UITableViewCell()
        }
        
        guard let tasks = travelDocument else {
            return UITableViewCell()
        }
        
        let task = tasks.travels[indexPath.row]
        
        cell.photoImageView.image = ImageManager.shared.loadImageFromDocumentDirectory(imageName: "\(task._id)_0.jpeg")
        
        cell.opacityView.backgroundColor = UIColor(white: 0.3, alpha: 0.3)
        
        cell.dateLabel.text = dateToString(date: task.travelDate)
        
        cell.locationDescriptionLabel.text = task.locationDescription
        
        cell.photoImageView.contentMode = .scaleAspectFill
        
        return cell
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
        
        let task = tasks.travels[indexPath.row]
        
        
        for imageName in task.travelPicture {
            guard let image = ImageManager.shared.loadImageFromDocumentDirectory(imageName: "\(imageName).jpeg") else {
                print("DEBUG: 이미지 가져오는거 실패했음 ㅠㅠ")
                return
            }
            vc.photoImages.append(image)
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
