//
//  FilesListViewController.swift
//  CloudServices
//
//  Created by Nikolay Taran on 24.10.18.
//  Copyright © 2018 Nikolay Taran. All rights reserved.
//

import UIKit
import SwiftyDropbox

class FilesListViewController: UIViewController, UISearchBarDelegate {
    
    var refreshControl = UIRefreshControl()
    
    // Контроллер входного экрана
    var mainController: ViewController?
    
    // Email пользователя
    let emailLabel = UILabel()
    
    // Search bar
    let searchBar = UISearchBar()
    
    // Список файлов
    var filesTree: FilesTree?
    
    // И Table View для него
    let filesTableView = UITableView()
    var filesDelegateDataSource: FilesDelegateDataSource?
    
    // Кнопка множественного прикрепления
    let attachButton = UIButton()
    
    // Строка, означающая что текущая папка пуста
    // Появляется только если она дйствительно пуста
    let emptyFolder = UILabel()
    
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
    }
    
    // Обход дерева файлов для поиска по названию
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
    
    // Пользователь нажал кнопку поиска файлов по названию, начинаем поиск и выводим все найденные файлы в отдельном списке
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        
        var found: [FilesTree] = []
        found = searchForText(text: searchBar.text!, files: filesTree!, found: &found)
        
        let searchController = SearchViewController(searchText: searchBar.text!, files: found, mainController: mainController!)
        navigationController?.pushViewController(searchController, animated: true)
        searchBar.text = ""
    }
    
    // Пользователь нажал кнопку возврата при неснятом выделении, спрашивем действительно ли он хочет продолжить
    func cancelAction(sender: UIBarButtonItem) {
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
    
    // Пользователь нажал кнопку выхода из аккаунта Dropbox, спрашивем действительно ли он хочет продолжить
    func signOut(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: AppDelegate.dropboxEmail ?? "", message: "Are you sure you want to log out from Dropbox?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action: UIAlertAction!) in
        }))
        alert.addAction(UIAlertAction(title: "Log out", style: .default, handler: {(action: UIAlertAction!) in
            DropboxClientsManager.unlinkClients()
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
        }
        let signoutButton = UIBarButtonItem(title: "Sign out", style: .plain, target: self, action: #selector(self.signOut(sender:)))
        navigationItem.rightBarButtonItem = signoutButton
        
        // Search bar
        searchBar.delegate = self
        view.addSubview(searchBar)
        ViewController.performAutolayoutConstants(subview: searchBar, view: view, left: 0.0, right: 0.0, top: 0.0, bottom: -(view.frame.height - 100))
        
        
        // Строка, означающая что текущая папка пуста
        // Появляется только если она дйствительно пуста
        emptyFolder.textAlignment = .center
        emptyFolder.text = "Folder is empty"
        emptyFolder.numberOfLines = 0
        emptyFolder.textColor = .lightGray
        
        view.addSubview(emptyFolder)
        ViewController.performAutolayoutConstants(subview: emptyFolder, view: view, left: 0.0, right: 0.0, top: view.frame.height / 2 - view.frame.height / 2 / 3, bottom: -view.frame.height / 2)
        
        appendUI()
    }
    
    // Селектор обновления дерева файлов в приложении
    func refreshAction(sender: UIRefreshControl) {
        mainController?.filesTree = (mainController?.dropboxFilesList(path: ""))!
        
        let interval: TimeInterval = 10
        _ = DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + interval, execute: {
            self.mainController?.selectFiles()
        })
    }
    
    // Метод размещает список файлов и кнопку множественного прикрепления на экране
    func appendUI() {
    
        filesTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshAction(sender:)), for: .valueChanged)
        
        filesTableView.tableFooterView = UIView(frame: .zero)
        filesDelegateDataSource = FilesDelegateDataSource(filesTree: filesTree!, controller: self, mainController: mainController!, filesListController: self)
        filesTableView.delegate = filesDelegateDataSource
        filesTableView.dataSource = filesDelegateDataSource
        view.addSubview(filesTableView)
        
        // Применяем autolayout для списка файлов
        ViewController.performAutolayoutConstants(subview: filesTableView, view: view, left: 0.0, right: 0.0, top: 35.0, bottom: 0.0)
        
        attachButton.backgroundColor = .white
        attachButton.setTitle("Attach", for: .normal)
        attachButton.setTitleColor(.red, for: .normal)
        attachButton.isHidden = true
        attachButton.addTarget(self, action: #selector(multipleSelection(sender:)), for: .touchUpInside)
        
        view.addSubview(attachButton)
        ViewController.performAutolayoutConstants(subview: attachButton, view: view, left: 0.0, right: 0.0, top: view.frame.height - 100, bottom: 0.0)
    }
    
    // Селектор для прикрепления множества файлов, возвращает пользователя на входной экран
    func multipleSelection(sender: UIButton) {
        var selected: [FilesTree] = []
        for i in 0..<filesTree!.childFiles.count {
            if (filesDelegateDataSource?.selectionCheckbox[i].isChecked)! {
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
        
        _ = navigationController?.popToViewController(mainController!, animated: true)
    }
}
