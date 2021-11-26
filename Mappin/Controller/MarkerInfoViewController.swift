//
//  MarkerInfoViewController.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/25.
//

import UIKit
import PanModal

class MarkerInfoViewController: UIViewController {

    
    //MARK: Properties
    var document: LocationDocument? = nil
    
    
    //MARK: UI

    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: Method
    func panModalConfig() {
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .shortForm)
    }
    
    func tableViewConfig() {
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: MarkerInfoTableViewCell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: MarkerInfoTableViewCell.identifier)
    }
    
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewConfig()
    }
    

}

//MARK: PanModal
extension MarkerInfoViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return tableView
    }
    var shortFormHeight: PanModalHeight {
        return .contentHeight(view.frame.size.height * 0.4)
    }
    var longFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(0)
    }
}

//MARK: TableView
extension MarkerInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let document = document else {
            return 0
        }
        
        return document.memoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MarkerInfoTableViewCell.identifier, for: indexPath) as? MarkerInfoTableViewCell else {
            return UITableViewCell()
        }
        
        guard let tasks = document else {
            return UITableViewCell()
        }
        
        let task = tasks.memoryList[indexPath.row]
        
        cell.dateLabel.text = dateToString(date: task.memoryDate)
        cell.memoryDescriptionLabel.text = task.memoryDescription
        cell.photoImageView.image = ImageManager.shared.loadImageFromDocumentDirectory(imageName: "\(task._id)_0.jpeg")
        cell.photoImageView.contentMode = .scaleAspectFill
        cell.photoImageView.layer.cornerRadius = 5
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let tasks = document {
            let sb = UIStoryboard(name: "Detail", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "TravelDetailViewController") as! TravelDetailViewController
            vc.task = tasks.memoryList[indexPath.row]
            self.presentPanModal(vc)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.size.height * 0.15
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return document?.documentTitle ?? ""
    }
}