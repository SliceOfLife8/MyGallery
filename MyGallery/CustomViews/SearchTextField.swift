//
//  SearchTextField.swift
//  MyGallery
//
//  Created by Christos Petimezas on 25/6/21.
//

import UIKit

@IBDesignable
class SearchTextField: UITextField {
    
    // Provides left padding for images
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += leftPadding
        return textRect
    }
    
    @IBInspectable var leftImage: UIImage? {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var leftPadding: CGFloat = 0
    
    @IBInspectable var color: UIColor = UIColor(hexString: "#e6e6e6") {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        if let image = leftImage {
            leftViewMode = .always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            // Note: In order for your image to use the tint color, you have to select the image in the Assets.xcassets and change the "Render As" property to "Template Image".
            imageView.tintColor = color
            leftView = imageView
        } else {
            leftViewMode = .never
            leftView = nil
        }
        
        // Placeholder text color
        attributedPlaceholder = NSAttributedString(string: placeholder != nil ?  placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: color])
        // Change caret color
        self.tintColor = UIColor(hexString: "#e6e6e6")
        self.setupRightImage(image: UIImage(systemName: "clear"))
    }
    
}

extension UITextField {
    func setupRightImage(image: UIImage?){
        let imageView = UIImageView(frame: CGRect(x: 8, y: 8, width: 16, height: 16))
        imageView.isUserInteractionEnabled = true
        imageView.image = image
        imageView.contentMode = .center
        let imageContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        imageContainerView.addSubview(imageView)
        rightView = imageContainerView
        rightViewMode = .whileEditing
        self.tintColor = .lightGray
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rightViewTapped)))
    }
    
    @objc func rightViewTapped() {
        self.text?.removeAll()
    }
}
