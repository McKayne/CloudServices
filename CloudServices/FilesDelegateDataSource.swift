//
//  FilesDelegateDataSource.swift
//  CloudServices
//
//  Created by для интернета on 24.10.18.
//  Copyright © 2018 Nikolay Taran. All rights reserved.
//

import UIKit

class FilesDelegateDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    static let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var filesTree: FilesTree
    var controller: UIViewController, mainController: ViewController, filesListController: FilesListViewController
    
    // Selection checkbox list
    var selectionCheckbox: [CustomCheckbox] = []
    
    init(filesTree: FilesTree, controller: UIViewController, mainController: ViewController, filesListController: FilesListViewController) {
        self.filesTree = filesTree
        self.controller = controller
        self.mainController = mainController
        self.filesListController = filesListController
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filesTree.childFiles.count
    }
    
    func checkboxList() {
        for _ in 0..<filesTree.childFiles.count {
            selectionCheckbox.append(CustomCheckbox(frame: CGRect(x: 0, y: 0, width: 30, height: 30), filesListDataSource: self))
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        checkboxList()
        
        let fileOrDir = filesTree.childFiles[indexPath.row]
        
        let nameLabel = UILabel()
        let attributesLabel = UILabel()
        if !fileOrDir.isDirectory {
            cell.accessoryView = selectionCheckbox[indexPath.row]
            
            let file = filesTree.childFiles[indexPath.row].file
        
            if let preview = file?.preview {
                cell.contentView.addSubview(preview)
                preview.frame = CGRect(x: 15, y: 15, width: 100 - 30, height: 100 - 30)
                
                if let previewImage = fileOrDir.preview {
                    preview.image = previewImage
                }
            }
            
        
            // File name
            
            nameLabel.numberOfLines = 0
            cell.contentView.addSubview(nameLabel)
            ViewController.performAutolayoutConstants(subview: nameLabel, view: cell.contentView, left: 100.0, right: -50.0, top: 0.0, bottom: -50.0)
            
            nameLabel.text = fileOrDir.name
        
            // File attributes
            attributesLabel.numberOfLines = 0
            cell.contentView.addSubview(attributesLabel)
            ViewController.performAutolayoutConstants(subview: attributesLabel, view: cell.contentView, left: 100.0, right: -50.0, top: 50.0, bottom: 0.0)
        
            attributesLabel.textColor = .lightGray
            
            attributesLabel.text = FilesDelegateDataSource.attributesString(fileName: fileOrDir)
        } else {
            cell.accessoryType = .disclosureIndicator
            
            let preview = UIImageView(frame: CGRect(x: 15, y: 15, width: 100 - 30, height: 100 - 30))
            preview.image = UIImage(named: "folder.png")
            cell.contentView.addSubview(preview)
            
            //cell.textLabel?.text = fileOrDir.name
            // File name
            nameLabel.numberOfLines = 0
            cell.contentView.addSubview(nameLabel)
            ViewController.performAutolayoutConstants(subview: nameLabel, view: cell.contentView, left: 100.0, right: -50.0, top: 0.0, bottom: -50.0)
            
            nameLabel.text = fileOrDir.name
            
            // File attributes
            let attributesLabel = UILabel()
            attributesLabel.numberOfLines = 0
            cell.contentView.addSubview(attributesLabel)
            ViewController.performAutolayoutConstants(subview: attributesLabel, view: cell.contentView, left: 100.0, right: -50.0, top: 50.0, bottom: 0.0)
            
            attributesLabel.textColor = .lightGray
            
            attributesLabel.text = "\(fileOrDir.childFiles.count) files"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fileOrDir = filesTree.childFiles[indexPath.row]
        
        if fileOrDir.isDirectory {
            print("Directory select")
            
            let nextController = FilesListViewController(mainController: mainController, filesTree: fileOrDir)
            controller.navigationController?.pushViewController(nextController, animated: true)
        } else {
            mainController.selectedFiles = [fileOrDir]
            mainController.pages = [FileViewController(backgroundColor: .white, file: fileOrDir)]
            
            mainController.pageView.dataSource = nil // old page view's cache bug
            mainController.pageView.setViewControllers([mainController.pages[0]], direction: .forward, animated: true, completion: nil)
            mainController.pageView.dataSource = mainController
            
            /*mainController.
            */
            
            _ = controller.navigationController?.popToViewController(mainController, animated: true)
        }
    }
    
    static func attributesString(fileName: FilesTree) -> String {
        var size: Int = fileName.size!
        var units = ""
        if size >= 1024 * 1024 {
            size /= 1024 * 1024
            units = "MB"
        } else if size >= 1024 {
            size /= 1024
            units = "KB"
        } else {
            units = "bytes"
        }
        
        let dateEndIndex = (fileName.dateString?.index((fileName.dateString?.startIndex)!, offsetBy: 11))!
        let endIndex = (fileName.dateString?.index((fileName.dateString?.startIndex)!, offsetBy: 20))!
        let dateSubstring = fileName.dateString?.substring(to: dateEndIndex)
        let timeSubstring = fileName.dateString?.substring(with: dateEndIndex..<endIndex)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "\"yyyy-MM-dd"
        let date = dateFormatter.date(from: dateSubstring!)
        if date == nil {
            print("NIL DATE")
        }
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date!)
        let month = calendar.component(.month, from: date!)
        let year = calendar.component(.year, from: date!)
        
        var attributes = ""
        
        if calendar.component(.year, from: Date()) != year {
            attributes = "\(String(describing: size)) \(units) - \(FilesDelegateDataSource.months[month - 1]) \(day), \(year)"
        } else {
            attributes = "\(String(describing: size)) \(units) - \(FilesDelegateDataSource.months[month - 1]) \(day)"
        }
        
        return attributes
    }
}
