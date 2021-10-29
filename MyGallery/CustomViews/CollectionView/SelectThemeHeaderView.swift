//
//  SelectThemeHeaderView.swift
//  MyGallery
//
//  Created by Petimezas, Chris, Vodafone on 28/10/21.
//

import UIKit

class SelectThemeHeaderView: UICollectionReusableView {
    static let identifier = "SelectThemeHeaderView"

    private let label: GradientLabel = {
        let label = GradientLabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.text = "theme_header".localized()
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.gradientColors = [UIColor(hexString: "#02aab0").cgColor, UIColor(hexString: "#00cdac").cgColor]
        label.sizeToFit()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.addExclusiveConstraints(superview: self, top: (self.topAnchor, 8), bottom: (self.bottomAnchor, 8), left: (self.leadingAnchor, 8), right: (self.trailingAnchor, 8))
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}
