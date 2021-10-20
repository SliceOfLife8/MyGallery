//
//  EditCustomAlbum+UIMenu.swift
//  MyGallery
//
//  Created by Christos Petimezas on 30/6/21.
//

import UIKit

extension EditCustomAlbumVC {

    func addMenuItemsToDotsView() -> UIMenu {
        // Create actions
        let deleteAlbum = UIAction(title: "delete_album".localized(), image: UIImage(systemName: "photo"), handler: { [weak self] _ in
            self?.viewModel.deleteAlbum()
        })
        
        let deleteAlbumAndCollection = UIAction(title: "delete_all_assets".localized(), image: UIImage(systemName: "cube"), handler: { [weak self] _ in
            guard let indexPaths = self?.getAllIndexPaths() else { return }
            self?.viewModel.deleteImages(indexPaths: indexPaths)
        })
        
        // Use the .displayInline option to avoid displaying the menu as a submenu,
        // and to separate it from the other menu elements using a line separator.
        let menu = UIMenu(title: "", options: .displayInline, children: [deleteAlbum, deleteAlbumAndCollection])
        
        return menu
    }

    func addMenuItemsToTrashView() -> UIMenu {
        // Create actions
        let deleteAlbum = UIAction(title: "delete_assets_album".localized(), image: UIImage(systemName: "photo"), handler: { [weak self] _ in
            guard let indexPaths = self?.selectedIndexPaths else { return }
            self?.viewModel.deleteImagesFromAlbum(indexPaths: indexPaths)
        })
        
        let deleteAlbumAndCollection = UIAction(title: "delete_assets".localized(), image: UIImage(systemName: "cube"), handler: { [weak self] _ in
            guard let indexPaths = self?.selectedIndexPaths else { return }
            self?.viewModel.deleteImages(indexPaths: indexPaths)
        })
        
        // Use the .displayInline option to avoid displaying the menu as a submenu,
        // and to separate it from the other menu elements using a line separator.
        let menu = UIMenu(title: "", options: .displayInline, children: [deleteAlbum, deleteAlbumAndCollection])
        
        return menu
    }
    
}
