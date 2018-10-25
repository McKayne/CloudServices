//
//  ViewController.swift
//  CloudServices
//
//  Created by для интернета on 24.10.18.
//  Copyright © 2018 Nikolay Taran. All rights reserved.
//

import UIKit
import SwiftyDropbox

extension UINavigationBar {
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        let screenRect = UIScreen.main.bounds
        return CGSize(width: screenRect.size.width, height: 90.0)
    }
}

class ViewController: UIViewController {
    
    // Navigation bar
    let defaultTitle = "Cloud Services"
    
    // File preview
    let preview = UIImageView()
    
    // Selected file name
    var fileName = UILabel()
    
    // File previews
    var filesTree = FilesTree(isDirectory: true, name: "Dummy")
    
    // Selected file size/modified
    var fileAttributes = UILabel()
    
    // Selected file URL
    var fileURL = UILabel()
    
    // Применение AutoLayout к элементу на экране
    static func performAutolayoutConstants(subview: UIView, view: UIView, left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.leftAnchor.constraint(equalTo: view.leftAnchor, constant: left).isActive = true
        subview.rightAnchor.constraint(equalTo: view.rightAnchor, constant: right).isActive = true
        subview.topAnchor.constraint(equalTo: view.topAnchor, constant: top).isActive = true
        subview.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottom).isActive = true
    }
    
    func customDeserialization(client: DropboxClient, filesList: Files.ListFolderResultSerializer.ValueType, filesTree: FilesTree, path: String) -> FilesTree {
        //print(filesList)
        
        let tags = filesList.description.components(separatedBy: [" ", ";"])
        var isDirectory: [Bool] = []
        var size: [Int?] = []
        var dateString: [String] = []
        var urlString: [String] = []
        for i in 0..<tags.count {
            if tags[i].hasPrefix("folder") {
                isDirectory.append(true)
                //print("FOLDER")
            } else if tags[i].hasPrefix("file") {
                isDirectory.append(false)
                //print("FILE")
            } else if tags[i].hasPrefix("size") {
                //print("SIZE")
                //print(tags[i + 2])
                size.append(Int(tags[i + 2]))
            } else if tags[i].hasPrefix("\"server_modified\"") {
                //print(tags[i + 2])
                dateString.append(tags[i + 2])
            } else if tags[i].hasPrefix("\"path_display\"") {
                var chars = tags[i + 2].characters
                chars.removeFirst()
                chars.removeLast()
                urlString.append(String(chars))
                //print(String(chars))
            }
        }
        
        var fileSizeIndex = 0
        for i in 0..<filesList.entries.count {
            //print("Name = \(nth.name)")
            
            var child = FilesTree(isDirectory: isDirectory[i], name: filesList.entries[i].name)
            if !isDirectory[i] {
                
                
                child.size = size[fileSizeIndex]
                child.dateString = dateString[fileSizeIndex]
                fileSizeIndex += 1
            } else {
                //print("Recursive \(path + "/" + filesList.entries[i].name)")
                
                child = dropboxFilesList(path: path + "/" + filesList.entries[i].name)
                child.name = filesList.entries[i].name
            }
            child.file = DropboxFile(name: filesList.entries[i].name)
            child.urlString = urlString[i]
            if urlString[i].hasSuffix("jpg") {
                print(urlString[i])
                
                // Download to Data
                client.files.download(path: urlString[i])
                    .response { response, error in
                        if let response = response {
                            let responseMetadata = response.0
                            //print(responseMetadata)
                            let fileContents = response.1
                            //print(fileContents)
                            child.preview = UIImage(data: fileContents)
                            if child.preview == nil {
                                print("Nil image")
                            }
                        } else if let error = error {
                            print(error)
                        }
                    }
                    .progress { progressData in
                        //print(progressData)
                }
            }
            
            filesTree.childFiles.append(child)
        }
        
        return filesTree
    }
    
    func dropboxFilesList(path: String) -> FilesTree {
        var filesTree = FilesTree(isDirectory: true, name: "")
        
        // Reference after programmatic auth flow
        let client = DropboxClientsManager.authorizedClient
        
        client?.files.listFolder(path: path).response(queue: DispatchQueue(label: "MyCustomSerialQueue")) { response, error in
            if let result = response {
                //print(Thread.current)  // Output: <NSThread: 0x61000007bec0>{number = 4, name = (null)}
                //print(Thread.main)     // Output: <NSThread: 0x608000070100>{number = 1, name = (null)}
                
                //re
                
                filesTree = self.customDeserialization(client: client!, filesList: result, filesTree: filesTree, path: path)
                
                //print(filesList)
                
                //print(result.entries.count)
                //filesList = result
                
            }
        }
        
        //print(filesList)
        return filesTree
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                      controller: self,
                                                      openURL: { (url: URL) -> Void in
                                                        UIApplication.shared.openURL(url)
        })
        
        view.backgroundColor = .white
        
        // Navigation bar
        navigationItem.title = defaultTitle
        let selectButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(self.selectFiles(sender:)))
        navigationItem.rightBarButtonItem = selectButton
        
        // Recursive files list
        filesTree = dropboxFilesList(path: "")
        
        // Selected file name
        fileName.textAlignment = .center
        fileName.text = "No file selected"
        view.addSubview(fileName)
        ViewController.performAutolayoutConstants(subview: fileName, view: view, left: 0.0, right: 0.0, top: view.frame.height / 2 - 150, bottom: -(view.frame.height / 2 + 150 - 30))
        
        // Selected file preview
        preview.image = UIImage(named: "dummyFile.png")
        view.addSubview(preview)
        ViewController.performAutolayoutConstants(subview: preview, view: view, left: 0.0, right: 0.0, top: view.frame.height / 2 - 100, bottom: -(view.frame.height / 2 + 100 - view.frame.width))
        
        // Selected file size/modified
        fileAttributes.textAlignment = .center
        fileAttributes.textColor = .gray
        fileAttributes.text = ""
        view.addSubview(fileAttributes)
        ViewController.performAutolayoutConstants(subview: fileAttributes, view: view, left: 0.0, right: 0.0, top: view.frame.height / 2 + 220, bottom: -(view.frame.height / 2 - 220 - 30))
        
        // Selected file URL
        fileURL.textAlignment = .center
        fileURL.textColor = .gray
        fileURL.text = ""
        view.addSubview(fileURL)
        ViewController.performAutolayoutConstants(subview: fileURL, view: view, left: 0.0, right: 0.0, top: view.frame.height / 2 + 240, bottom: -(view.frame.height / 2 - 240 - 30))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func selectFiles(sender: UIBarButtonItem) {
        let filesListController = FilesListViewController(mainController: self, filesTree: filesTree)
        navigationController?.pushViewController(filesListController, animated: true)
    }
}

