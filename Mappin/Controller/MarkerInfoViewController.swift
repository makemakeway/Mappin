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
        return nil
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
        
        return cell
    }
    
    
}
