//
//  AddTravelViewController.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/18.
//

import UIKit
import RealmSwift

class AddTravelViewController: UIViewController {

    
    //MARK: Properties
    
    let localRealm = try! Realm()
    
    var tasks: Results<TravelDocument>!
    
    //MARK: UI
    
    @IBOutlet weak var titleTextField: UITextField!
    
    
    //MARK: Method
    
    @objc func forwardButtonClicked(_ sender: UIBarButtonItem) {
        print("DEBUG: forwardButtonClicked")
        
        if checkTitleIsValid() {
            print("DEBUG: 유효한 타이틀")
            
            try! localRealm.write {
                localRealm.add(TravelDocument(title: titleTextField.text!, travel: List<Travel>()))
            }
            
            let sb = UIStoryboard(name: "AddPin", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "AddPinViewController") as! AddPinViewController
            vc.documentTitle = titleTextField.text!
            
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            print("DEBUG: 유효하지 않은 타이틀")
        }

    }
    
    func checkTitleIsValid() -> Bool {
        
        guard let title = titleTextField.text, !(title.isEmpty) else {
            
            presentOkAlert(message: "여행 제목을 입력해주세요.")
            return false
        }
        
        
        if !(tasks.filter("documentTitle = '\(title)'").isEmpty) {
            print("쭝복임!")
            presentOkAlert(message: "이미 존재하는 여행 제목입니다.\n다른 제목을 입력해주세요.")
            return false
        }
        
        return true
    }
    
    func navBarConfig() {
        let button = UIBarButtonItem(image: UIImage(systemName: "paperplane"),
                                     style: UIBarButtonItem.Style.plain,
                                     target: self,
                                     action: #selector(forwardButtonClicked(_:)))
        
        self.navigationItem.rightBarButtonItem = button
        self.title = "여행 추가"
    }
    
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        navBarConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.titleTextField.becomeFirstResponder()
        
        tasks = localRealm.objects(TravelDocument.self)
    }

}
