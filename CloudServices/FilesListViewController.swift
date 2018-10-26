//
//  FilesListViewController.swift
//  CloudServices
//
//  Created by для интернета on 24.10.18.
//  Copyright © 2018 Nikolay Taran. All rights reserved.
//

import UIKit

class FilesListViewController: UIViewController, UISearchBarDelegate {
    
    var refreshControl = UIRefreshControl()
    
    // Main screen
    var mainController: ViewController?
    
    // Email label
    let emailLabel = UILabel()
    
    // Search bar
    let searchBar = UISearchBar()
    
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("SEARCHING")
    }
    
    func searchForText(text: String, files: FilesTree, found: inout [FilesTree]) -> [FilesTree] {
        for nth in files.childFiles {
            if nth.isDirectory {
                found = searchForText(text: text, files: nth, found: &found)
            } else if nth.name.lowercased().contains(text.lowercased()) {
                found.append(nth)
            }
        }
        
        return found
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("SEARCH START")
        
        searchBar.endEditing(true)
        
        var found: [FilesTree] = []
        found = searchForText(text: searchBar.text!, files: filesTree!, found: &found)
        print("Found \(found.count)")
        
        let searchController = SearchViewController(searchText: searchBar.text!, files: found, mainController: mainController!)
        navigationController?.pushViewController(searchController, animated: true)
        searchBar.text = ""
    }
    
    func cancelAction(sender: UIBarButtonItem) {
        if !attachButton.isHidden {
            let alert = UIAlertController(title: "Cancel selection?", message: "Are you sure you want to abandon selection?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action: UIAlertAction!) in
                print("One")
            }))
            alert.addAction(UIAlertAction(title: "Deselect", style: .default, handler: {(action: UIAlertAction!) in
                print("Two")
                _ = self.navigationController?.popViewController(animated: true)
            }))
            
            present(alert, animated: true, completion: nil)
        } else {
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    func signOut(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: AppDelegate.dropboxEmail ?? "", message: "Are you sure you want to log out from Dropbox?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action: UIAlertAction!) in
            print("One")
        }))
        alert.addAction(UIAlertAction(title: "Log out", style: .default, handler: {(action: UIAlertAction!) in
            print("Two")
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        
        // Navigation bar
        let leftBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction(sender:)))
        if (filesTree?.name.isEmpty)! {
            navigationItem.title = "Dropbox"
            navigationItem.hidesBackButton = true
            navigationItem.leftBarButtonItem = leftBarButton
        } else {
            navigationItem.title = filesTree?.name
            
            //navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Title", style: .plain, target: nil, action: nil)
            //navigationItem.backBarButtonItem?.title = "Back"
        }
        let signoutButton = UIBarButtonItem(title: "Sign out", style: .plain, target: self, action: #selector(self.signOut(sender:)))
        navigationItem.rightBarButtonItem = signoutButton
            
        /*emailLabel.textAlignment = .center
        emailLabel.textColor = .lightGray
        emailLabel.text = AppDelegate.dropboxEmail ?? ""
        view.addSubview(emailLabel)
        ViewController.performAutolayoutConstants(subview: emailLabel, view: view, left: 0.0, right: 0.0, top: 0.0, bottom: -(view.frame.height - 100))*/
        
        // Search bar
        searchBar.delegate = self
        view.addSubview(searchBar)
        ViewController.performAutolayoutConstants(subview: searchBar, view: view, left: 0.0, right: 0.0, top: 0.0, bottom: -(view.frame.height - 100))
        
        
        
        
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
        ViewController.performAutolayoutConstants(subview: filesTableView, view: view, left: 0.0, right: 0.0, top: 35.0, bottom: 0.0)
        
        attachButton.backgroundColor = .white
        attachButton.setTitle("Attach", for: .normal)
        attachButton.setTitleColor(.red, for: .normal)
        attachButton.isHidden = false
        attachButton.addTarget(self, action: #selector(multipleSelection(sender:)), for: .touchUpInside)
        
        //attachButton.frame = CGRect(x: 0, y: 400, width: 320, height: 50)
        view.addSubview(attachButton)
        ViewController.performAutolayoutConstants(subview: attachButton, view: view, left: 0.0, right: 0.0, top: view.frame.height - 100, bottom: 0.0)
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
