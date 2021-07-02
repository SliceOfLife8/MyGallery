//
//  LanguageSelectionVC.swift
//  MyGallery
//
//  Created by Christos Petimezas on 1/7/21.
//

import UIKit

class LanguageSelectionVC: BaseVC {
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.identifier)
        return table
    }()
    
    var models = [Section]()
    
    private var greekEnabled: Bool {
        get {
            let lan = UserDefaults.standard.value(forKeyPath: "AppleLanguages") as? [String]
            return lan?.first == "el-GR"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "choose_language".localized()
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
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func configure() {
        models.append(Section(title: nil, bottomTitle: "change_language_desc".localized(), options: [
            SettingsOption(title: "english".localized(), icon: "🇬🇧".image(), iconBackgroundColor: .clear, accessoryType: (greekEnabled) ? .none : .checkmark, handle: { [weak self] in
                self?.changeLanguage(lan: "en")
            }),
            SettingsOption(title: "greek".localized(), icon: "🇬🇷".image(), iconBackgroundColor: .clear, accessoryType: (greekEnabled) ? .checkmark : .none, handle: { [weak self] in
                self?.changeLanguage(lan: "el-GR")
            })
        ]))
    }
    
    private func changeLanguage(lan: String) {
        UserDefaults.standard.set([lan], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
}

// MARK: - UITableView Delegates
extension LanguageSelectionVC: UITableViewDelegate, UITableViewDataSource {
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

