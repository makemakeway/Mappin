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
            if tasks.isEmpty {
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tasks = localRealm.objects(TravelDocument.self)
    }
    

}

//MARK: Table View Delegate
extension InitialViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: InitialTableViewCell.identifier, for: indexPath) as? InitialTableViewCell else {
            return UITableViewCell()
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}
