//
//  PhotoCell.swift
//  MyGallery
//
//  Created by Christos Petimezas on 24/6/21.
//
// Check this website for gradientColor combinations -> https://digitalsynopsis.com/design/beautiful-color-ui-gradients-backgrounds/

import UIKit
import SDWebImage

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
        imageView.sd_imageTransition = .fade
        imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
    }
    
}
