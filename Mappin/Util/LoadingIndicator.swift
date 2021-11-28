//
//  LoadingIndicator.swift
//  Mappin
//
//  Created by 박연배 on 2021/11/27.
//

import UIKit

class LoadingIndicator {
    static let shared = LoadingIndicator()
    
    private init() {
        
    }
    
    func showIndicator() {
        DispatchQueue.main.async {
            var window: UIWindow
            if #available(iOS 15, *) {
                let scenes = UIApplication.shared.connectedScenes
                let windowScene = scenes.first as? UIWindowScene
                guard let win = windowScene?.windows.last else { return }
                window = win
            } else {
                guard let win = UIApplication.shared.windows.last else { return }
                window = win
            }
            
            var loadingIndicatorView = UIActivityIndicatorView()
            
            if let existView = window.subviews.first(where: { $0 is UIActivityIndicatorView }) as? UIActivityIndicatorView {
                loadingIndicatorView = existView
            } else {
                loadingIndicatorView = UIActivityIndicatorView(style: .large)
                loadingIndicatorView.frame = window.frame
                window.addSubview(loadingIndicatorView)
                loadingIndicatorView.startAnimating()
            }
            print("SHOW INDICATOR")
        }
    }
    
    func hideIndicator() {
        DispatchQueue.main.async {
            var window: UIWindow
            if #available(iOS 15, *) {
                let scenes = UIApplication.shared.connectedScenes
                let windowScene = scenes.first as? UIWindowScene
                guard let win = windowScene?.windows.last else { return }
                window = win
            } else {
                guard let win = UIApplication.shared.windows.last else { return }
                window = win
            }
            
            window.subviews.filter({ $0 is UIActivityIndicatorView }).forEach( { $0.removeFromSuperview() } )
            print("HIDE INDICATOR")
        }
    }
}
