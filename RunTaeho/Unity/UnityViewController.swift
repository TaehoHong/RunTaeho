//
//  ViewController.swift
//  RunTaeho
//
//  Created by Hong Taeho on 2/7/25.
//

import Foundation
import UIKit

final class UnityViewController: NSObject {
    var unityNavigationController: UINavigationController
    
    public var viewController: UIViewController {
        unityNavigationController.topViewController ?? UIViewController()
    }
    
    var nativeButton = UIButton(type: .system)  
    
    init(navigationController: UINavigationController) {
        self.unityNavigationController = navigationController
        super.init()
         setupLayout()
    }
    
    func setupLayout() {
        let screenSize = UIScreen.main.bounds.size
        viewController.view.addSubview(nativeButton)
        nativeButton.setTitle("Native Button", for: .normal)
        nativeButton.setTitleColor(.black, for: .normal)
        nativeButton.backgroundColor = .white
        nativeButton.addTarget(self, action: #selector(tappedNativeButton(_:)), for: .touchUpInside)
        nativeButton.frame = CGRect(x: screenSize.width/4,
                                    y: screenSize.height/8,
                                    width: screenSize.width/2,
                                    height: 50)
        
    }
    
    @objc func tappedNativeButton(_ sender: UIButton) {
        print("tappedNativeButton!")
    }
}
