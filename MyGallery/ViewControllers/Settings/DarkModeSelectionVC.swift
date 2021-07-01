//
//  DarkModeSelectionVC.swift
//  MyGallery
//
//  Created by Christos Petimezas on 29/6/21.
//

import UIKit

class DarkModeSelectionVC: UIViewController {
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.identifier)
        return table
    }()
    
    var models = [Section]()
    let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "dark_mode".localized()
        let backButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = backButton
        configure()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    /// #Detect when darkMode changed
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.tableView.reloadData()
        }
    }
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func configure() {
        let status = getDarkModeStatus()
        models.append(Section(title: nil, bottomTitle: "choose_system".localized() + "\(appName)" + "device_settings".localized(), options: [
            SettingsOption(title: "activation".localized(), icon: UIImage(systemName: "moon.fill"), iconBackgroundColor: UIColor(named: "LightBlue"), accessoryType: (status == 2) ? .checkmark : .none, handle: { [weak self] in
                self?.updateDarkMode(.dark)
            }),
            SettingsOption(title: "deactivation".localized(), icon: UIImage(systemName: "sun.min.fill"), iconBackgroundColor: UIColor(named: "LightBlue"), accessoryType: (status == 1) ? .checkmark : .none, handle: { [weak self] in
                self?.updateDarkMode(.light)
            }),
            SettingsOption(title: "system".localized(), icon: UIImage(systemName: "circle.lefthalf.fill"), iconBackgroundColor: UIColor(named: "LightBlue"), accessoryType: (status == 0) ? .checkmark : .none, handle: { [weak self] in
                self?.updateDarkMode(.unspecified)
            })
        ]))
    }
    
    private func getDarkModeStatus() -> Int{
        // unspecified = 0, light = 1, dark = 2
        let style = UserDefaults.standard.overridedUserInterfaceStyle
        return style.rawValue
    }
    
    private func updateDarkMode(_ style: UIUserInterfaceStyle) {
        UIApplication.shared.override(style)
        UserDefaults.standard.overridedUserInterfaceStyle = style
    }
    
}

// MARK: - UITableView Delegates
extension DarkModeSelectionVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].options.count
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let section = models[section]
        return section.bottomTitle
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section].options[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.identifier, for: indexPath) as? SettingsCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Update datasource
        for (index, _) in models[indexPath.section].options.enumerated() {
            models[indexPath.section].options[index].accessoryType = (index == indexPath.row) ? .checkmark : .none
        }
        tableView.reloadData()
        let model = models[indexPath.section].options[indexPath.row]
        model.handle()
    }
}
