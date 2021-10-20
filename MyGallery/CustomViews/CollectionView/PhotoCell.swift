//
//  PhotoCell.swift
//  MyGallery
//
//  Created by Christos Petimezas on 24/6/21.
//
// Check this website for gradientColor combinations -> https://digitalsynopsis.com/design/beautiful-color-ui-gradients-backgrounds/

import UIKit
import Nuke

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var photographer: UILabel!
    @IBOutlet weak var nameLbl: GradientLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 6
        containerView.layer.masksToBounds = true
        photographer.font = UIFont.systemFontItalic(size: 14.0, fontWeight: .black)
        nameLbl.gradientColors = [UIColor(hexString: "#2b5876").cgColor, UIColor(hexString: "#4e4376").cgColor]
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        photographer.text = nil
    }
    
    func setupCell(_ url: URL?, photographerName: String, containerBGColor: UIColor? = UIColor(hexString: "#999999")) {
        containerView.backgroundColor = containerBGColor
        nameLbl.text = photographerName
        photographer.text = "photographer".localized()
        loadImage(with: url)
    }

    private func loadImage(with url: URL?) {
        let options = ImageLoadingOptions(
            placeholder: UIImage(named: "placeholder"),
          transition: .fadeIn(duration: 0.3)
        )

        Nuke.loadImage(with: url, options: options, into: imageView)
    }
    
}

extension UIFont {
    static func systemFontItalic(size fontSize: CGFloat = 17.0, fontWeight: UIFont.Weight = .regular) -> UIFont {
        let font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        return UIFont(descriptor: font.fontDescriptor.withSymbolicTraits(.traitItalic)!, size: fontSize)
    }
}
