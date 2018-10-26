//
//  LoadingIndicatorController.swift
//  CloudServices
//
//  Created by для интернета on 26.10.18.
//  Copyright © 2018 Nikolay Taran. All rights reserved.
//

import UIKit

class LoadingIndicatorController: UIViewController {
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        
        navigationItem.hidesBackButton = true
        navigationItem.title = "Please wait"
        
        let indicator = UIActivityIndicatorView(frame: CGRect(x: view.frame.width / 2 - 15, y: view.frame.height / 2 - 15, width: 30, height: 30))
        indicator.activityIndicatorViewStyle = .gray
        view.addSubview(indicator)
        
        indicator.isHidden = false
        indicator.startAnimating()
        
        /*let button = UIButton(frame: CGRect(x: 200, y: 400, width: 100, height: 100))
        button.setTitle("DDDD", for: .normal)
        button.backgroundColor = .red
        view.addSubview(button)*/
    }
}
