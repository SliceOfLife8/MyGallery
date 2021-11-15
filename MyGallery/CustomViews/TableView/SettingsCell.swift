//
//  SettingsCell.swift
//  MyGallery
//
//  Created by Christos Petimezas on 29/6/21.
//

import UIKit

protocol SettingsCellDelegate: AnyObject {
    func didSwitchChanged(_ status: Bool, cell: SettingsCell)
}

class SettingsCell: UITableViewCell {
    static let identifier = "SettingsCell"
    weak var delegate: SettingsCellDelegate?
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size: CGFloat = contentView.frame.size.height - 12
        iconContainer.frame = CGRect(x: 15, y: 6, width: size, height: size)
        
        let imageSize: CGFloat = size/1.5
        iconImageView.frame = CGRect(x: (size-imageSize)/2, y: (size-imageSize)/2, width: imageSize, height: imageSize)
        
        label.frame = CGRect(x: 25 + iconContainer.frame.size.width,
                             y: 0,
                             width: contentView.frame.size.width - 20 - iconContainer.frame.size.width,
                             height: contentView.frame.size.height)

        separatorInset = UIEdgeInsets(top: 0, left: 25 + iconContainer.frame.size.width, bottom: 0, right: 0)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        label.text = nil
        iconContainer.backgroundColor = nil
    }
    
    public func configure(with model: SettingsOption) {
        label.text = model.title
        iconImageView.image = model.icon
        iconContainer.backgroundColor = model.iconBackgroundColor
        if let value = model.switchValue {
            addSwitch(value)
        } else {
            accessoryType = model.accessoryType
        }
    }

    private func addSwitch(_ value: Bool) {
        let lightSwitch = UISwitch(frame: .zero) as UISwitch
        lightSwitch.isOn = value
        lightSwitch.addTarget(self, action: #selector(switchTriggered), for: .valueChanged)
        accessoryView = lightSwitch
    }

    @objc func switchTriggered(sender: UISwitch) {
        self.delegate?.didSwitchChanged(sender.isOn, cell: self)
    }
    
}
