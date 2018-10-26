//
//  SearchViewController.swift
//  CloudServices
//
//  Created by Nikolay Taran on 26.10.18.
//  Copyright © 2018 Nikolay Taran. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    // Main screen
    var mainController: ViewController?
    
    // Text to search
    var searchText: String
    
    // Searched files
    var files: [FilesTree] = []
    
    // Search results list
    let resultsTableView = UITableView()
    var searchDataSource: SearchDelegateDataSource?
    
    // Multiple attach button
    let attachButton = UIButton()
    
    // Selected file size/modified
    let emptyFolder = UILabel()
    
    convenience init(searchText: String, files: [FilesTree], mainController: ViewController) {
        self.init(nibName: nil, bundle: nil)
        self.searchText = searchText
        self.files = files
        self.mainController = mainController
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        searchText = ""
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func signOut(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: AppDelegate.dropboxEmail ?? "", message: "Are you sure you want to log out from Dropbox?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action: UIAlertAction!) in
        }))
        alert.addAction(UIAlertAction(title: "Log out", style: .default, handler: {(action: UIAlertAction!) in
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        
        navigationItem.title = searchText
        let leftBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelSearch(sender:)))
        navigationItem.leftBarButtonItem = leftBarButton
        let signoutButton = UIBarButtonItem(title: "Sign out", style: .plain, target: self, action: #selector(self.signOut(sender:)))
        navigationItem.rightBarButtonItem = signoutButton
        
        // Selected file size/modified
        emptyFolder.textAlignment = .center
        emptyFolder.text = "Nothing found"
        emptyFolder.numberOfLines = 0
        emptyFolder.textColor = .lightGray
        
        view.addSubview(emptyFolder)
        ViewController.performAutolayoutConstants(subview: emptyFolder, view: view, left: 0.0, right: 0.0, top: view.frame.height / 2 - view.frame.height / 2 / 3, bottom: -view.frame.height / 2)
        
        resultsTableView.tableFooterView = UIView(frame: .zero)
        searchDataSource = SearchDelegateDataSource(searchController: self, mainController: mainController!)
        resultsTableView.delegate = searchDataSource
        resultsTableView.dataSource = searchDataSource
        view.addSubview(resultsTableView)
        ViewController.performAutolayoutConstants(subview: resultsTableView, view: view, left: 0.0, right: 0.0, top: 0.0, bottom: 0.0)
        
        attachButton.backgroundColor = .white
        attachButton.setTitle("Attach", for: .normal)
        attachButton.setTitleColor(.red, for: .normal)
        attachButton.isHidden = true
        attachButton.addTarget(self, action: #selector(multipleSelection(sender:)), for: .touchUpInside)
        
        view.addSubview(attachButton)
        ViewController.performAutolayoutConstants(subview: attachButton, view: view, left: 0.0, right: 0.0, top: view.frame.height - 100, bottom: 0.0)
    }
    
    func multipleSelection(sender: UIButton) {
        var selected: [FilesTree] = []
        for i in 0..<files.count {
            if (searchDataSource?.selectionCheckbox[i].isChecked)! {
                selected.append(files[i])
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
        
        _ = navigationController?.popToViewController(mainController!, animated: true)
    }
    
    func cancelSearch(sender: UIBarButtonItem) {
        if !attachButton.isHidden {
            let alert = UIAlertController(title: "Cancel selection?", message: "Are you sure you want to abandon selection?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action: UIAlertAction!) in
            }))
            alert.addAction(UIAlertAction(title: "Deselect", style: .default, handler: {(action: UIAlertAction!) in
                _ = self.navigationController?.popViewController(animated: true)
            }))
            
            present(alert, animated: true, completion: nil)
        } else {
            _ = navigationController?.popViewController(animated: true)
        }
    }
}
