//
//  HomePage+UIContextMenu.swift
//  MyGallery
//
//  Created by Christos Petimezas on 24/6/21.
//

import UIKit
import LinkPresentation
import Photos

/*
 UIContextMenuInteraction: Adds a context menu to a view.
 UIContextMenuConfiguration: Builds a UIMenu with actions and configures its behavior.
 UIContextMenuInteractionDelegate: Manages the lifecycle of the context menu, such as building the UIContextMenuConfiguration.
 */

extension HomeVC: UIContextMenuInteractionDelegate {
    
    /**
     UIContextMenuConfiguration parameters
     - Parameter identifier: Use the identifier to keep track of multiple context menus.
     - Parameter previewProvider: A closure that returns a UIViewController. If you set this to nil, the default preview will display for your menu, which is just the view you tapped. You’ll use this later to show a preview that’s more appealing to the eye.
     - Parameter actionProvider: Each item in a context menu is an action. This closure is where you actually build your menu. You can build a UIMenu with UIActions and nested UIMenus. The closure takes an array of suggested actions provided by UIKit as an argument. This time, you’ll ignore it as your menu will have your own custom items.
     */
    
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint)
    -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil, /// pass nil, if custom preview not needed
            actionProvider: { _ in
                let children: [UIMenuElement] = []
                return UIMenu(title: "", children: children)
            })
    }
    
    /**
     contextMenuConfigurationForItemAt parameters
     - Parameter collectionView: The collection view containing the item.
     - Parameter indexPath: The index path of the item for which a configuration is being requested.
     - Parameter point: The location of the interaction in the collection view's coordinate space.
     - Returns a context menu configuration for the item at a point.
     */
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let index = indexPath.row
        self.getSingleHQImage(index)
        
        let identifier = "\(index)" as NSString
        
        return UIContextMenuConfiguration(
            identifier: identifier,
            previewProvider: nil) { _ in
            /// #Create multiple actions with callbacks
            let copyAction = UIAction(
                title: "Αντιγραφή",
                image: UIImage(systemName: "doc.on.doc")) { _ in
                if let image = self.sharedImage { /// Copy image to clipboard
                    self.copyImageToClipboard(for: image)
                }
            }
                let downloadAction = UIAction(
                    title: "Αποθήκευση",
                    image: UIImage(systemName: "square.and.arrow.down")) { _ in
                    if let image = self.sharedImage { /// Download image
                        self.downloadAsset(for: image)
                    }
                }
                /// #Share selectedImage to other apps.
            let shareAction = UIAction(
                title: "Κοινή χρήση",
                image: UIImage(systemName: "square.and.arrow.up")) { _ in
                
                let activityViewController = UIActivityViewController(activityItems: [self], applicationActivities: nil)
                //Excluded Activities
                activityViewController.excludedActivityTypes = [
                    .saveToCameraRoll,
                    .addToReadingList,
                    .openInIBooks,
                    .markupAsPDF
                ]
                activityViewController.popoverPresentationController?.sourceView = self.view
                self.present(activityViewController, animated: true, completion: nil)
            }
                
                return UIMenu(title: "", image: nil, children: [copyAction, downloadAction, shareAction])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return self.makeTargetedPreview(for: configuration)
    }
    
    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return self.makeTargetedPreview(for: configuration)
    }
    
    private func makeTargetedPreview(for configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        // Ensure we can get the expected identifier
        guard let identifier = configuration.identifier as? String,
              let index = Int(identifier),
              let cell = collectionView?.cellForItem(at: IndexPath(row: index, section: 0))
                as? PhotoCell,
              let image = cell.imageView
        else {
            return nil
        }
        
        // Return the custom targeted preview
        return UITargetedPreview(view: image)
    }
    
    /* We need to fetch high quality images for those who was selected by user. */
    private func getSingleHQImage(_ index: Int) {
        let elementURL = viewModel.photos[index].src.large2X
        if let url = URL(string: elementURL) {
            UIImage.loadFrom(url: url, completion: { image in
                self.sharedImage = image
                let size = image?.getSizeIn(.megabyte) ?? ""
                self.sharedImageInfo = (size, self.viewModel.photos[index].photographer)
            })
        }
    }
    
    private func copyImageToClipboard(for image: UIImage) {
        guard let type = UIPasteboard.typeListImage[0] as? String else { return }
        if !type.isEmpty, let data = image.pngData() {
            UIPasteboard.general.setData(data, forPasteboardType: type)
        }
    }
    
    private func downloadAsset(for image: UIImage) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized, .limited:
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (newStatus) in
                DispatchQueue.main.async {
                    if newStatus == .authorized {
                        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                    }
                }
            }
        default:
            //Create Alert Controller
            let alert = UIAlertController(title: "Access to photos no granted!", message: nil, preferredStyle: .alert)
            //Action 1
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            //Action 2
            alert.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: { (_) in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: nil)
                }
            }))
            
            self.present(alert, animated: true)
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showAlertWith(title: "Save error", message: error.localizedDescription)
        } else {
            showAlertWith(title: "Image was saved!")
        }
    }
    
    private func showAlertWith(title: String, message: String? = nil) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
}

// MARK: - UIActivityItemSource delegate methods
extension HomeVC: UIActivityItemSource {
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return UIImage() // an empty UIImage is sufficient to ensure share sheet shows right actions
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return self.sharedImage
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        guard let selectedImage = sharedImage, let info = sharedImageInfo else { return nil }
        let linkMetaData = LPLinkMetadata()
        
        // Thumbnail
        linkMetaData.iconProvider = NSItemProvider(object: selectedImage)
        
        // Title
        linkMetaData.title = info.photographer
        
        // Subtitle with file size
        //👇
        linkMetaData.originalURL = URL(fileURLWithPath: "Size: \(info.sizePerMb) Mb")
        
        return linkMetaData
    }
    
}
