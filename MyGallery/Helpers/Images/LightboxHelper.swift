//
//  LightboxHelper.swift
//  MyGallery
//
//  Created by Petimezas, Chris, Vodafone on 23/10/21.
//

import Lightbox
import LinkPresentation

class LightboxHelper: NSObject {

    static func show() {
        var images: [LightboxImage] = []

        for (index, element) in PhotoService.shared.images.enumerated() {
            var date = String()
            if let assetDate = PhotoService.shared.photoAssets[index].creationDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/YYYY"
                date = dateFormatter.string(from: assetDate)
            }

            images.append(LightboxImage(image: element, text: date))
        }

        // Create an instance of LightboxController.
        let controller = LightboxController(images: images)
        // Configuration
        LightboxConfig.DeleteButton.enabled = true
        LightboxConfig.DeleteButton.text = "Share"
        LightboxConfig.DeleteButton.textAttributes = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.white,
            .paragraphStyle: {
                let style = NSMutableParagraphStyle()
                style.alignment = .center
                return style
            }()
        ]

        controller.headerView.deleteButton.removeTarget(nil, action: nil, for: .touchUpInside)
        controller.headerView.deleteButton.addAction {
            self.shareDidPress()
        }
        controller.dynamicBackground = true
        // Present your controller.
        UIApplication.topViewController()?.present(controller, animated: true, completion: nil)
    }

    static private func shareDidPress() {
        guard let controller = UIApplication.topViewController(), controller is LightboxController else { return }
        let activityViewController = UIActivityViewController(activityItems: [controller], applicationActivities: nil)
        //Excluded Activities
        activityViewController.excludedActivityTypes = [
            .saveToCameraRoll,
            .addToReadingList,
            .openInIBooks,
            .markupAsPDF
        ]
        activityViewController.popoverPresentationController?.sourceView = UIApplication.topViewController()?.view

        UIApplication.shared.sceneDelegate.window?.rootViewController?.presentedViewController?.present(activityViewController, animated: true, completion: nil)
    }

}

// MARK: - UIActivityItemSource delegate methods
extension LightboxController: UIActivityItemSource {

    public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return UIImage() // an empty UIImage is sufficient to ensure share sheet shows right actions
    }

    public func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        let currentImage = self.images[safe: self.currentPage]?.image ?? PhotoService.shared.images.first

        return currentImage
    }

    public func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let currentImage = self.images[safe: self.currentPage]?.image ?? PhotoService.shared.images.first
        guard let selectedImage = currentImage, let info = currentImage?.getSizeIn(.megabyte) else { return nil }

        let linkMetaData = LPLinkMetadata()
        linkMetaData.iconProvider = NSItemProvider(object: selectedImage)
        linkMetaData.originalURL = URL(fileURLWithPath: "Size: \(info) Mb")

        return linkMetaData
    }
    
}

extension UIControl {
    func addAction(for controlEvents: UIControl.Event = .touchUpInside, _ closure: @escaping()->()) {
        addAction(UIAction { (action: UIAction) in closure() }, for: controlEvents)
    }
}
