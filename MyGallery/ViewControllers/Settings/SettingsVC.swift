//
//  SettingsVC.swift
//  MyGallery
//
//  Created by Christos Petimezas on 29/6/21.
//

import UIKit
import Photos

class SettingsVC: BaseVC {
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.identifier)
        return table
    }()
    
    var models = [Section]()
    private var showAlbum: Bool = false
    private var appVersion: String {
        get {
            "version".localized() + " \(AppConfig.appVersion)"
        }
    }
    private var greekSupported: Bool {
        get {
            Locale.current.regionCode == "GR"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(albumCreatedNotification), name: .didAlbumCreated, object: nil)
    }
    
    override func languageDidChange() {
        super.languageDidChange()
        self.title = self.tabBarController?.tabBar.selectedItem?.title
        configure()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.deleteLoafView()
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
    
    /// #Create Setting Options for tableView
    func configure() {
        models.removeAll()
        /// #Apperance
        var apperanceOptions: [SettingsOption] = [SettingsOption(title: "dark_mode".localized(), icon: UIImage(systemName: "moon.circle.fill"), iconBackgroundColor: UIColor(named: "Black"), accessoryType: .disclosureIndicator, handle: {
            let darkModeVC = DarkModeSelectionVC()
            let navigationController = UINavigationController(rootViewController: darkModeVC)
            darkModeVC.modalPresentationStyle = .popover
            self.present(navigationController, animated: true)
        })]
        if greekSupported {
            apperanceOptions.append(SettingsOption(title: "languages".localized(), icon: UIImage(systemName: "globe"), iconBackgroundColor: UIColor(named: "DarkBlue"), accessoryType: .disclosureIndicator, handle: {
                let languageVC = LanguageSelectionVC()
                let navigationController = UINavigationController(rootViewController: languageVC)
                languageVC.modalPresentationStyle = .popover
                self.present(navigationController, animated: true)
            }))
        }
        models.append(Section(title: "appearance".localized(), bottomTitle: nil, options: apperanceOptions))
        /// #General
        models.append(Section(title: "general".localized(), bottomTitle: (getStatus() ? nil : appVersion), options: [
            SettingsOption(title: "find_me_on_social".localized(), icon: UIImage(systemName: "link.circle"), iconBackgroundColor: UIColor(named: "LightBlue"), accessoryType: .disclosureIndicator, handle: {
                /// #Open linkedinApp if it's available on phone. Otherwise open custom webView.
                if let url = URL(string: "linkedin://profile/christos-petimezas"), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    return
                }
                
                guard let url = URL(string: "https://www.linkedin.com/in/christos-petimezas/") else { return }
                
                let webView = WebPreviewVC(with: url)
                webView.modalPresentationStyle = .popover
                self.present(webView, animated: true)
            }),
            SettingsOption(title: "share_app".localized(), icon: UIImage(systemName: "square.and.arrow.up"), iconBackgroundColor: .link, accessoryType: .disclosureIndicator, handle: {
                self.shareApp()
            }),
            SettingsOption(title: "review_app".localized(), icon: UIImage(systemName: "star.circle.fill"), iconBackgroundColor: UIColor(hexString: "#43cea2"), accessoryType: .disclosureIndicator, handle: {
                StoreReviewHelper.requestReview()
            })
        ]))
        /// #Show custom album only if authorizationStatus is authorized.
        if getStatus() {
            models.append(Section(title: "\(AppConfig.albumName) " + "album".localized(), bottomTitle: appVersion, options: [
                SettingsOption(title: "edit_album".localized(), icon: UIImage(systemName: "photo.fill"), iconBackgroundColor: UIColor(named: "Purple"), accessoryType: .disclosureIndicator, handle: {
                    let editAlbumVC = EditCustomAlbumVC(EditAlbumViewModel())
                    editAlbumVC.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(editAlbumVC, animated: true)
                }),
                SettingsOption(title: "show_album".localized(), icon: UIImage(systemName: "photo.on.rectangle.angled"), iconBackgroundColor: UIColor(named: "LightPurple"), accessoryType: .disclosureIndicator, handle: {
                    self.showAlbum = true
                    PhotoService.shared.delegate = self
                    PhotoService.shared.fetchCustomAlbumPhotos()
                })
            ]))
        }
    }
    
    private func getStatus() -> Bool {
        let status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        return (status == .authorized) ? true : false
    }
    
    // TODO: check again this func
    private func shareApp() {
        if let urlStr = URL(string: "https://apps.apple.com/us/app/id1535629801") {
            let activityVC = UIActivityViewController(activityItems: [urlStr], applicationActivities: nil)
            
            self.present(activityVC, animated: true, completion: nil)
        }
    }

    @objc func albumCreatedNotification() {
        configure()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}

// MARK: - UITableView Delegates
extension SettingsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].options.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = models[section]
        return section.title
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        (view as? UITableViewHeaderFooterView)?.textLabel?.textAlignment = .center
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
        let model = models[indexPath.section].options[indexPath.row]
        model.handle()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 80
    }
}

extension SettingsVC: PhotoServiceDelegate {
    func didGetImages() {
        if showAlbum {
            LightboxHelper.show()
        }
        showAlbum = false
    }
}
