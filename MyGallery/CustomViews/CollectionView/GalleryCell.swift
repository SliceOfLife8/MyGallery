//
//  GalleryCell.swift
//  MyGallery
//
//  Created by Christos Petimezas on 30/6/21.
//

import UIKit
import FirebaseStorageUI
import SDWebImage

protocol GalleryCellDelegate: AnyObject {
    func didReceiveError(code: Int, message: String)
}

public class GalleryCell: UICollectionViewCell {

    public var cellIdentifier = "GalleryCell"
    weak var delegate: GalleryCellDelegate?
    
    override public var isSelected: Bool {
        didSet {
            self.imageView?.layer.borderWidth = 5.0
            self.imageView?.layer.borderColor = isSelected ? bgColor : UIColor.clear.cgColor
            if !isSelected {
                removeCircle()
            }
        }
    }

    public override var isHighlighted: Bool {
        didSet {
            onHighlightChanged()
        }
    }
    
    weak public var imageView: UIImageView?
    public var bgColor: CGColor? = UIColor(named: "GreenBlue")?.cgColor
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        
        let imageView = UIImageView(frame: .zero)
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.addExclusiveConstraints(superview: self, top: (topAnchor, 0), bottom: (bottomAnchor, 0), left: (leadingAnchor, 0), right: (trailingAnchor, 0))
        self.imageView = imageView
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        imageView?.image = nil
        imageView?.sd_cancelCurrentImageLoad()
    }

    func loadFBStorageImage(_ index: Int) {
        let child = FirebaseStorageManager.shared.childs[index - 1]
        imageView?.sd_imageTransition = .flipFromBottom
        imageView?.sd_setImage(with: child, placeholderImage: UIImage(named: "placeholder"), completion: { _, error, _, _ in
            if case .storage(let code, let errorMessage) = error as? FirebaseError {
                self.delegate?.didReceiveError(code: code, message: errorMessage)
            }
        })
    }

    private func onHighlightChanged() {
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut], animations: {
            self.imageView?.alpha = self.isHighlighted ? 0.9 : 1.0
            self.imageView?.transform = self.isHighlighted ?
                CGAffineTransform.identity.scaledBy(x: 0.95, y: 0.95) :
                CGAffineTransform.identity
        })
    }
    
    /**
     Create circle which is indicating the number of selected images.
     */
    public func createCircle(with number: Int) {
        let size: CGSize = (number > 9) ? CGSize(width: 32, height: 32) : CGSize(width: 24, height: 24)
        
        let countLabel = UILabel(frame: CGRect(origin: .zero, size: size))
        countLabel.text = String(number)
        countLabel.textColor = .white
        countLabel.font = UIFont.boldSystemFont(ofSize: 14)
        countLabel.textAlignment = .center
        countLabel.layer.cornerRadius = size.width / 2
        countLabel.layer.backgroundColor = UIColor.black.cgColor
        countLabel.addExclusiveConstraints(superview: self, top: (topAnchor, 12), right: (trailingAnchor, 12), width: size.width, height: size.height)
    }
    
    private func removeCircle() {
        self.subviews.forEach { subview in
            if subview is UILabel {
                subview.removeFromSuperview()
            }
        }
    }
    
}
