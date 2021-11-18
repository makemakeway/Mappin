//
//  InitialViewController.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/17.
//

import UIKit

class InitialViewController: UIViewController {

    //MARK: Properties
    
    
    
    //MARK: UI
    
    @IBOutlet weak var tableView: UITableView!
    
    
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
    
    //MARK: LifeCycle
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
