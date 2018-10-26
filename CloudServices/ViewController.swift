//
//  ViewController.swift
//  CloudServices
//
//  Created by для интернета on 24.10.18.
//  Copyright © 2018 Nikolay Taran. All rights reserved.
//

import UIKit
import SwiftyDropbox

/*extension UINavigationBar {
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        let screenRect = UIScreen.main.bounds
        return CGSize(width: screenRect.size.width, height: ViewController.navBarHeight)
    }
}*/

class ViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    static let accountLabel = UILabel()
    static var navBarHeight: CGFloat = 90.0
    
    var pageView: UIPageViewController!
    var pages: [UIViewController] = []
    let pageControl = UIPageControl()
    
    // Navigation bar
    let defaultTitle = "Cloud Services"
    
    // File previews
    var filesTree = FilesTree(isDirectory: true, name: "Dummy")
    
    // Selected files
    var selectedFiles: [FilesTree] = []
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        print("Fgfgf")
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed {
            print("DID NOT CHANGE")
        }
        print("CHANGED")
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        print("GHGHGH")
        let currentIndex = pages.index(of: viewController)!
        if currentIndex == 0 {
            return nil
        }
        let previousIndex = abs((currentIndex - 1) % pages.count)
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        print("GHGHGH")
        let currentIndex = pages.index(of: viewController)!
        if currentIndex == pages.count - 1 {
            return nil
        }
        let nextIndex = abs((currentIndex + 1) % pages.count)
        return pages[nextIndex]
    }
    
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
                var url = tags[i + 2]
                var j = 1
                while !tags[i + 2 + j].hasPrefix("\"") {
                    url += " \(tags[i + 2 + j])"
                    j += 1
                }
                
                var chars = url.characters
                chars.removeFirst()
                while chars.last != "\"" {
                    chars.removeLast()
                }
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
            if urlString[i].hasSuffix("jpg") || urlString[i].hasSuffix("png") {
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
        super.viewDidLoad()
        
        // Recursive files list
        filesTree = dropboxFilesList(path: "")
        
        DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                      controller: self,
                                                      openURL: { (url: URL) -> Void in
                                                        UIApplication.shared.openURL(url)
        })
        
        view.backgroundColor = .white
        
        pages.append(FileViewController(backgroundColor: .white))
        
        pageView = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageView.delegate = self
        pageView.dataSource = self
        pageView.setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
        
        pageView.view.frame = CGRect(x: 0, y: 0, width: 320, height: 568)
        view.addSubview(pageView.view)
        
        // Navigation bar
        navigationItem.title = defaultTitle
        let selectButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(self.selectFiles(sender:)))
        navigationItem.leftBarButtonItem = selectButton
        let signoutButton = UIBarButtonItem(title: "Sign out", style: .plain, target: self, action: #selector(self.signOut(sender:)))
        navigationItem.leftBarButtonItem = selectButton
        navigationItem.rightBarButtonItem = signoutButton
        
        //customNavigationBar()
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func customNavigationBar() {
        ViewController.navBarHeight = 90.0
        navigationController?.navigationBar.sizeToFit()
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: ViewController.navBarHeight))
        
        ViewController.accountLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 30)
        ViewController.accountLabel.textAlignment = .center
        titleView.addSubview(ViewController.accountLabel)
        
        let dropboxLabel = UILabel(frame: CGRect(x: 0, y: 30, width: view.frame.width, height: 30))
        dropboxLabel.textAlignment = .center
        dropboxLabel.text = "Dropbox"
        titleView.addSubview(dropboxLabel)
        
        navigationController!.navigationBar.topItem!.titleView = titleView
    }
    
    //override func viewDidAppear(_ animated: Bool) {
    //    <#code#>
    //}
    
    func selectFiles(sender: UIBarButtonItem) {
        //customNavigationBar()
        let filesListController = FilesListViewController(mainController: self, filesTree: filesTree)
        navigationController?.pushViewController(filesListController, animated: true)
    }
}

