//
//  WebViewController.swift
//  Mappin
//
//  Created by 박연배 on 2021/12/01.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    //MARK: Properties
    var link = ""
    
    //MARK: UI
    
    @IBOutlet weak var webView: WKWebView!
    
    //MARK: Method
    
    func loadURL(link: String) {
        guard let url = URL(string: link) else {
            return
        }
        let request = URLRequest(url: url)
        
        print(request)
        
        self.webView.load(request)
    }
    
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadURL(link: link)
    }
    
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        LoadingIndicator.shared.showIndicator()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        LoadingIndicator.shared.hideIndicator()
    }
}
