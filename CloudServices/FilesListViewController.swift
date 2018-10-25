//
//  FilesListViewController.swift
//  CloudServices
//
//  Created by для интернета on 24.10.18.
//  Copyright © 2018 Nikolay Taran. All rights reserved.
//

import UIKit

class FilesListViewController: UIViewController {
    
    var refreshControl = UIRefreshControl()
    
    // Main screen
    var mainController: ViewController?
    
    // Files list
    var filesTree: FilesTree?
    
    // Files table view
    let filesTableView = UITableView()
    var filesDelegateDataSource: FilesDelegateDataSource?
    
    // Multiple attach button
    let attachButton = UIButton()
    
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
    
        filesTableView.refreshControl = refreshControl
        
        filesTableView.tableFooterView = UIView(frame: .zero)
        filesDelegateDataSource = FilesDelegateDataSource(filesTree: filesTree!, controller: self, mainController: mainController!, filesListController: self)
        filesTableView.delegate = filesDelegateDataSource
        filesTableView.dataSource = filesDelegateDataSource
        view.addSubview(filesTableView)
        
        // Files table view autolayout
        filesTableView.translatesAutoresizingMaskIntoConstraints = false
        filesTableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0.0).isActive = true
        filesTableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0.0).isActive = true
        filesTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0).isActive = true
        filesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0).isActive = true
        
        attachButton.backgroundColor = .white
        attachButton.setTitleColor(.red, for: .normal)
        attachButton.isHidden = true
        attachButton.addTarget(self, action: #selector(multipleSelection(sender:)), for: .touchUpInside)
        view.addSubview(attachButton)
        ViewController.performAutolayoutConstants(subview: attachButton, view: view, left: 0.0, right: 0.0, top: view.frame.height - 50.0, bottom: 0.0)
    }
    
    func multipleSelection(sender: UIButton) {
        var selected: [FilesTree] = []
        for i in 0..<filesTree!.childFiles.count {
            if (filesDelegateDataSource?.selectionCheckbox[i].isChecked)! {
                print("gfjgfgjfgfgfgf")
                selected.append(filesTree!.childFiles[i])
            }
        }
        
        mainController?.selectedFiles = selected
        mainController?.pages = []
        for nth in selected {
            mainController?.pages.append(FileViewController(backgroundColor: .white, file: nth))
        }
        
        mainController?.pageView.dataSource = nil // old page view's cache bug
        mainController?.pageView.setViewControllers([(mainController?.pages[0])!], direction: .forward, animated: true, completion: nil)
        mainController?.pageView.dataSource = mainController
        
        /*mainController.
         */
        
        _ = navigationController?.popToViewController(mainController!, animated: true)
    }
}
