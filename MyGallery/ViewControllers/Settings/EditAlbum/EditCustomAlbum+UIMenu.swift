//
//  EditCustomAlbum+UIMenu.swift
//  MyGallery
//
//  Created by Christos Petimezas on 30/6/21.
//

import UIKit

extension EditCustomAlbumVC {
    
    @available(iOS 14.0, *)
    func addMenuItemsToDotsView() -> UIMenu {
        // Create actions
        let deleteAlbum = UIAction(title: "Delete album", image: UIImage(systemName: "photo"), handler: { [weak self] _ in
            self?.viewModel.deleteAlbum()
        })
        
        let deleteAlbumAndCollection = UIAction(title: "Delete all assets from collection", image: UIImage(systemName: "cube"), handler: { [weak self] _ in
            guard let indexPaths = self?.getAllIndexPaths() else { return }
            self?.viewModel.deleteImages(indexPaths: indexPaths)
        })
        
        // Use the .displayInline option to avoid displaying the menu as a submenu,
        // and to separate it from the other menu elements using a line separator.
        let menu = UIMenu(title: "", options: .displayInline, children: [deleteAlbum, deleteAlbumAndCollection])
        
        return menu
    }
    
    @available(iOS 14.0, *)
    func addMenuItemsToTrashView() -> UIMenu {
        // Create actions
        let deleteAlbum = UIAction(title: "Delete assets from album", image: UIImage(systemName: "photo"), handler: { [weak self] _ in
            guard let indexPaths = self?.selectedIndexPaths else { return }
            self?.viewModel.deleteImagesFromAlbum(indexPaths: indexPaths)
        })
        
        let deleteAlbumAndCollection = UIAction(title: "Delete assets from collection", image: UIImage(systemName: "cube"), handler: { [weak self] _ in
            guard let indexPaths = self?.selectedIndexPaths else { return }
            self?.viewModel.deleteImages(indexPaths: indexPaths)
        })
        
        // Use the .displayInline option to avoid displaying the menu as a submenu,
        // and to separate it from the other menu elements using a line separator.
        let menu = UIMenu(title: "", options: .displayInline, children: [deleteAlbum, deleteAlbumAndCollection])
        
        return menu
    }
    
    func addDropDownMenuForDotsView() {
        dropDownForDotsView.anchorView = self.navigationItem.rightBarButtonItem
        dropDownForDotsView.dataSource = ["Delete album", "Delete all assets from collection"]
        dropDownForDotsView.cellConfiguration = { (index, item) in return "\(item)"}
        dropDownForDotsView.selectionBackgroundColor = .clear
    }
    
    func addDropDownMenuForTrashView() {
        dropDownForTrashView.anchorView = self.navigationItem.rightBarButtonItem
        dropDownForTrashView.dataSource = ["Delete assets from album", "Delete assets from collection"]
        dropDownForTrashView.cellConfiguration = { (index, item) in return "\(item)"}
        dropDownForTrashView.selectionBackgroundColor = .clear
    }
    
    /// #Drop down menu for iOS 13
    func dropDownForDotsMenuTapped() {
        dropDownForDotsView.selectionAction = { (index: Int, _) in
            if index == 0 {
                self.viewModel.deleteAlbum()
            } else {
                self.viewModel.deleteImages(indexPaths: self.getAllIndexPaths())
            }
        }
        
        dropDownForDotsView.width = 250
        dropDownForDotsView.bottomOffset = CGPoint(x: 0, y: self.navigationController?.navigationBar.bounds.height ?? UIApplication.topSafeAreaHeight)
        dropDownForDotsView.show()
    }
    
    func dropDownForTrashMenuTapped() {
        dropDownForTrashView.selectionAction = { (index: Int, _) in
            if index == 0 {
                self.viewModel.deleteImagesFromAlbum(indexPaths: self.selectedIndexPaths)
            } else {
                self.viewModel.deleteImages(indexPaths: self.selectedIndexPaths)
            }
        }
        
        dropDownForTrashView.width = 230
        dropDownForTrashView.bottomOffset = CGPoint(x: 0, y: self.navigationController?.navigationBar.bounds.height ?? UIApplication.topSafeAreaHeight)
        dropDownForTrashView.show()
    }
    
    @objc func willShowMenu() {
        print("kati")
    }
}
