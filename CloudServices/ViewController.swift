//
//  ViewController.swift
//  CloudServices
//
//  Created by Nikolay Taran on 24.10.18.
//  Copyright © 2018 Nikolay Taran. All rights reserved.
//

import UIKit
import SwiftyDropbox

class ViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    // Page view для прокрутки выбранных файлов
    var pageView: UIPageViewController!
    var pages: [UIViewController] = []
    let pageControl = UIPageControl()
    
    // Navigation bar
    let defaultTitle = "Cloud Services"
    
    // Превью для файлов
    var filesTree = FilesTree(isDirectory: true, name: "Dummy")
    
    // Список выбранных файлов
    var selectedFiles: [FilesTree] = []
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    }
    
    // Метод Page View dataSource для перехода к предыдущему выбранному файлу
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.index(of: viewController)!
        if currentIndex == 0 {
            return nil
        }
        let previousIndex = abs((currentIndex - 1) % pages.count)
        return pages[previousIndex]
    }
    
    // Метод Page View dataSource для перехода к следующему выбранному файлу
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
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
    
    // Dropbox API отдает приложению результаты запроса в некотором json-подобном формате, который не десериализируется через jsonDecoder.
    // Следовательно нам необходимо сделать собственный десериалайзер
    func customDeserialization(client: DropboxClient, filesList: Files.ListFolderResultSerializer.ValueType, filesTree: FilesTree, path: String) -> FilesTree {
        
        let tags = filesList.description.components(separatedBy: [" ", ";"])
        var isDirectory: [Bool] = []
        var size: [Int?] = []
        var dateString: [String] = []
        var urlString: [String] = []
        for i in 0..<tags.count {
            if tags[i].hasPrefix("folder") {
                isDirectory.append(true)
            } else if tags[i].hasPrefix("file") {
                isDirectory.append(false)
            } else if tags[i].hasPrefix("size") {
                size.append(Int(tags[i + 2]))
            } else if tags[i].hasPrefix("\"server_modified\"") {
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
            }
        }
        
        var fileSizeIndex = 0
        for i in 0..<filesList.entries.count {
            
            var child = FilesTree(isDirectory: isDirectory[i], name: filesList.entries[i].name)
            if !isDirectory[i] {
                
                
                child.size = size[fileSizeIndex]
                child.dateString = dateString[fileSizeIndex]
                fileSizeIndex += 1
            } else {
                
                child = dropboxFilesList(path: path + "/" + filesList.entries[i].name)
                child.name = filesList.entries[i].name
            }
            child.file = DropboxFile(name: filesList.entries[i].name)
            child.urlString = urlString[i]
            if urlString[i].hasSuffix("jpg") || urlString[i].hasSuffix("png") {

                // Download to Data
                client.files.download(path: urlString[i])
                    .response { response, error in
                        if let response = response {
                            _ = response.0
                            let fileContents = response.1
                            child.preview = UIImage(data: fileContents)
                        } else if let error = error {
                            print(error)
                        }
                    }
                    .progress { progressData in
                }
            }
            
            filesTree.childFiles.append(child)
        }
        
        return filesTree
    }
    
    // Файлы и папки в приложении хранятся в виде дерева.
    // Для построения дерева используем рекурсию
    func dropboxFilesList(path: String) -> FilesTree {
        var filesTree = FilesTree(isDirectory: true, name: "")
        
        // Reference after programmatic auth flow
        let client = DropboxClientsManager.authorizedClient
        
        client?.files.listFolder(path: path).response(queue: DispatchQueue(label: "MyCustomSerialQueue")) { response, error in
            if let result = response {
                filesTree = self.customDeserialization(client: client!, filesList: result, filesTree: filesTree, path: path)
            }
        }

        return filesTree
    }
    
    // Modality view, которое появляется, если пользователь тапнул по кнопке разлогина
    func signOut(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: AppDelegate.dropboxEmail ?? "", message: "Are you sure you want to log out from Dropbox?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action: UIAlertAction!) in
        }))
        alert.addAction(UIAlertAction(title: "Log out", style: .default, handler: {(action: UIAlertAction!) in
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Аутентификация пользователя
        /*DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                      controller: self,
                                                      openURL: { (url: URL) -> Void in
                                                        UIApplication.shared.openURL(url)
        })*/
        
        // Построение дерева файлов
        filesTree = dropboxFilesList(path: "")
        
        view.backgroundColor = .white
        
        pages.append(FileViewController(backgroundColor: .white))
        
        pageView = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageView.delegate = self
        pageView.dataSource = self
        pageView.setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
        
        pageView.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(pageView.view)
        
        // Navigation bar
        navigationItem.title = defaultTitle
        let selectButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(self.selectFiles(sender:)))
        navigationItem.leftBarButtonItem = selectButton
        let signoutButton = UIBarButtonItem(title: "Sign out", style: .plain, target: self, action: #selector(self.signOut(sender:)))
        navigationItem.leftBarButtonItem = selectButton
        navigationItem.rightBarButtonItem = signoutButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Селектор для появления экрана выбора файлов, пользователь попадает в корневую директорию
    func selectFiles(sender: UIBarButtonItem) {
        let filesListController = FilesListViewController(mainController: self, filesTree: filesTree)
        navigationController?.pushViewController(filesListController, animated: true)
    }
    
    // Метод используется при обновлении дерева файлов в приложении, пользователь попадает в корневую директорию
    func selectFiles() {
        let filesListController = FilesListViewController(mainController: self, filesTree: filesTree)
        navigationController?.pushViewController(filesListController, animated: true)
    }
}

