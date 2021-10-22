//
//  AlbumFooterView.swift
//  MyGallery
//
//  Created by Petimezas, Chris, Vodafone on 21/10/21.
//

import UIKit

protocol AlbumFooterViewDelegate: AnyObject {
    func footerDidTapped()
}

class AlbumFooterView: UICollectionReusableView {
    static let identifier = "AlbumFooterView"
    weak var delegate: AlbumFooterViewDelegate?

    private let label: GradientLabel = {
        let label = GradientLabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.text = "album_footer".localized()
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.gradientColors = [UIColor(hexString: "#0C7BB3").cgColor, UIColor(hexString: "#F2BAE8").cgColor]
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.addExclusiveConstraints(superview: self, bottom: (self.bottomAnchor, 16), left: (self.leadingAnchor, 8), right: (self.trailingAnchor, 8))

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(footerViewTapped))
        self.isUserInteractionEnabled = true
        addGestureRecognizer(tapGesture)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    @objc func footerViewTapped()  {
        self.delegate?.footerDidTapped()
    }
}
