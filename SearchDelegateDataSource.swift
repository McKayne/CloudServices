//
//  SearchDelegateDataSource.swift
//  CloudServices
//
//  Created by Nikolay Taran on 26.10.18.
//  Copyright © 2018 Nikolay Taran. All rights reserved.
//

import UIKit

class SearchDelegateDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    let mainController: ViewController
    let searchController: SearchViewController
    
    // Selection checkbox list
    var selectionCheckbox: [CustomCheckbox] = []
    
    init(searchController: SearchViewController, mainController: ViewController) {
        self.searchController = searchController
        self.mainController = mainController
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.files.count > 0 {
            tableView.isHidden = false
        } else {
            tableView.isHidden = true
        }
        return searchController.files.count
    }
    
    func checkboxList() {
        for _ in 0..<searchController.files.count {
            selectionCheckbox.append(CustomCheckbox(frame: CGRect(x: 0, y: 0, width: 30, height: 30), searchListDataSource: self))
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        checkboxList()
        
        let file = searchController.files[indexPath.row]
        
        let nameLabel = UILabel()
        let attributesLabel = UILabel()
        cell.accessoryView = selectionCheckbox[indexPath.row]
            
        if let preview = file.file?.preview {
            cell.contentView.addSubview(preview)
            preview.frame = CGRect(x: 15, y: 15, width: 100 - 30, height: 100 - 30)
                
            if let previewImage = file.preview {
                preview.image = previewImage
            }
        }
            
            
        // File name
            
        nameLabel.numberOfLines = 0
        cell.contentView.addSubview(nameLabel)
        ViewController.performAutolayoutConstants(subview: nameLabel, view: cell.contentView, left: 100.0, right: -50.0, top: 0.0, bottom: -50.0)
            
        nameLabel.text = file.name
            
        // File attributes
        attributesLabel.numberOfLines = 0
        cell.contentView.addSubview(attributesLabel)
        ViewController.performAutolayoutConstants(subview: attributesLabel, view: cell.contentView, left: 100.0, right: -50.0, top: 50.0, bottom: 0.0)
            
        attributesLabel.textColor = .lightGray
            
        attributesLabel.text = FilesDelegateDataSource.attributesString(fileName: file)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let file = searchController.files[indexPath.row]
        
        mainController.selectedFiles = [file]
        mainController.pages = [FileViewController(backgroundColor: .white, file: file)]
        
        mainController.pageView.dataSource = nil // old page view's cache bug
        mainController.pageView.setViewControllers([mainController.pages[0]], direction: .forward, animated: true, completion: nil)
        mainController.pageView.dataSource = mainController
        
        _ = searchController.navigationController?.popToViewController(mainController, animated: true)
    }
}
