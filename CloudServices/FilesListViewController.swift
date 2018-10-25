//
//  FilesListViewController.swift
//  CloudServices
//
//  Created by для интернета on 24.10.18.
//  Copyright © 2018 Nikolay Taran. All rights reserved.
//

import UIKit

class FilesListViewController: UIViewController {
    
    // Main screen
    var mainController: ViewController?
    
    // Files list
    var filesTree: FilesTree?
    
    // Files table view
    let filesTableView = UITableView()
    var filesDelegateDataSource: FilesDelegateDataSource?
    
    convenience init(mainController: ViewController, filesTree: FilesTree) {
        self.init(nibName: nil, bundle: nil)
        
        self.mainController = mainController
        self.filesTree = filesTree
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //override func loadView() {
    //}
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        
        appendUI()
    }
    
    func appendUI() {
        filesTableView.tableFooterView = UIView(frame: .zero)
        filesDelegateDataSource = FilesDelegateDataSource(filesTree: filesTree!, controller: self, mainController: mainController!)
        filesTableView.delegate = filesDelegateDataSource
        filesTableView.dataSource = filesDelegateDataSource
        view.addSubview(filesTableView)
        
        // Files table view autolayout
        filesTableView.translatesAutoresizingMaskIntoConstraints = false
        filesTableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0.0).isActive = true
        filesTableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0.0).isActive = true
        filesTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0).isActive = true
        filesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0).isActive = true
    }
}
