//
//  Ext_UIView.swift
//  MyGallery
//
//  Created by Christos Petimezas on 25/6/21.
//

import UIKit

extension UIView {
    
    func applyGradient(isVertical: Bool, colorArray: [UIColor]) {
        layer.sublayers?.filter({ $0 is CAGradientLayer }).forEach({ $0.removeFromSuperlayer() })
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colorArray.map({ $0.cgColor })
        if isVertical {
            //top to bottom
            gradientLayer.locations = [0.0, 1.0]
        } else {
            //left to right
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        }
        
        backgroundColor = .clear
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    //MARK: - Automatically add constraints
    func addExclusiveConstraints(superview: UIView, top: (anchor: NSLayoutYAxisAnchor, constant: CGFloat)? = nil, bottom: (anchor: NSLayoutYAxisAnchor, constant: CGFloat)? = nil, left: (anchor: NSLayoutXAxisAnchor, constant: CGFloat)? = nil, right: (anchor: NSLayoutXAxisAnchor, constant: CGFloat)? = nil, width: CGFloat? = nil, height: CGFloat? = nil, centerX: NSLayoutXAxisAnchor? = nil, centerY: NSLayoutYAxisAnchor? = nil) {
        self.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(self)
        if let top = top {
            self.topAnchor.constraint(equalTo: top.anchor, constant: top.constant).isActive = true
        }
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom.anchor, constant: -bottom.constant).isActive = true
        }
        if let left = left {
            self.leadingAnchor.constraint(equalTo: left.anchor, constant: left.constant).isActive = true
        }
        if let right = right {
            self.trailingAnchor.constraint(equalTo: right.anchor, constant: -right.constant).isActive = true
        }
        if let width = width {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = height {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        if let centerX = centerX {
            self.centerXAnchor.constraint(equalTo: centerX).isActive = true
        }
        if let centerY = centerY {
            self.centerYAnchor.constraint(equalTo: centerY).isActive = true
        }
    }
    
}
