//
//  SoundSettingsVC.swift
//  MyGallery
//
//  Created by Petimezas, Chris, Vodafone on 24/10/21.
//

import UIKit

class SoundSettingsVC: BaseVC {

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.identifier)
        return table
    }()

    var models = [Section]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupTV()
    }

    private func setupNavBar() {
        let backButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = backButton
        self.title = "sounds_haptics".localized()
    }

    private func setupTV() {
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
        models.removeAll()
        models.append(Section(title: nil, bottomTitle: nil, options: [
            SettingsOption(title: "sounds".localized(), icon: "🔈".image(), iconBackgroundColor: .white, accessoryType: .none, switchValue: Settings.shared.retrieveState(forKey: .sound), handle: {}),
            SettingsOption(title: "haptics".localized(), icon: "📳".image(), iconBackgroundColor: .clear, accessoryType: .none, switchValue: Settings.shared.retrieveState(forKey: .vibration), handle: {})
        ]))
    }
    
}

// MARK: - UITableView Delegates
extension SoundSettingsVC: UITableViewDelegate, UITableViewDataSource, SettingsCellDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section].options[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.identifier, for: indexPath) as? SettingsCell else {
            return UITableViewCell()
        }

        cell.configure(with: model)
        cell.delegate = self
        return cell
    }

    func didSwitchChanged(_ status: Bool, cell: SettingsCell) {
        guard let row = self.tableView.indexPath(for: cell)?.row else { return }
        if row == 0 {
            Settings.shared.updateSetting(state: status, key: .sound)
        } else {
            Settings.shared.updateSetting(state: status, key: .vibration)
        }
    }
}
